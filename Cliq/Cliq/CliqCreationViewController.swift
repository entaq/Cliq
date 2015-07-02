import UIKit
import GoogleMaps
import Photos
//import ImagePickerSheetController

class CliqCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var place: GMSPlace?
    var cliqGroup: PFObject?
    
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var locationField: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let place = place {
            self.place = place
            if let name = place.name {
                nameField.text = name
            }
            locationField.text = " ".join(place.formattedAddress.componentsSeparatedByString(", "))
        } else {
            println("No place selected")
            println("")
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        var cliq = PFObject(className:"CliqAlbum")
        cliq["name"] = place!.name
        cliq["address"] = "\n".join(place!.formattedAddress.componentsSeparatedByString(", "))
        cliq["caption"] = self.captionField.text
        cliq.saveInBackground()
        cliqGroup = cliq
    }

    @IBAction func uploadPhoto(sender: AnyObject) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                dispatch_async(dispatch_get_main_queue()) {
                    self.uploadPhoto(sender)
                }
            }
            return
        }

        if authorization == .Authorized {
            let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
                let controller = UIImagePickerController()
                controller.delegate = self
                var sourceType = source
                if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                    sourceType = .PhotoLibrary
                    println("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
                }
                controller.sourceType = sourceType
                
                self.presentViewController(controller, animated: true, completion: nil)
            }

            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Add comment", comment: "Action Title"), handler: { _ in
                presentImagePickerController(.Camera)
                }, secondaryHandler: { _, numberOfPhotos in
                    println("Comment \(numberOfPhotos) photos")
            }))
            controller.addAction(ImageAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title"), $0) as String}, handler: { _ in
                presentImagePickerController(.PhotoLibrary)
                }, secondaryHandler: { _, numberOfPhotos in
                    controller.getSelectedImagesWithCompletion() { images in
                        for image in images {
                            if let image = image {
                                let imageData = UIImageJPEGRepresentation(image, 0.55)
                                let imageFile = PFFile(name:"image.jpeg", data:imageData)
                                var userPhoto = PFObject(className:"UserPhoto")
                                userPhoto["creator"] = PFUser.currentUser()!
                                if let cliqGroup = self.cliqGroup {
                                    userPhoto["cliqGroup"] = cliqGroup
                                }
                                userPhoto["imageFile"] = imageFile
                                userPhoto.saveInBackground()
                            }
                        }
                    }
            }))
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
                println("Cancelled")
            }))
            
            presentViewController(controller, animated: true, completion: nil)
        }
        else {
            let alertView = UIAlertView(title: NSLocalizedString("An error occurred", comment: "An error occurred"), message: NSLocalizedString("ImagePickerSheet needs access to the camera roll", comment: "ImagePickerSheet needs access to the camera roll"), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK"))
            alertView.show()
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}