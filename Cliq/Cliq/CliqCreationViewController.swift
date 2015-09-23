import UIKit
import GoogleMaps
import Photos

class CliqCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var place: GMSPlace?
    var cliqGroup: PFObject?
    var userSelectedImages = [PFObject]()
    
    var imageForNameCollection : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let place = place {
//            self.place = place
//            if let name = place.name {
//                nameField.text = name
//            }
//            locationField.text = " ".join(place.formattedAddress.componentsSeparatedByString(", "))
//        } else {
//            println("No place selected")
//            println("")
//        }
//
//        let fbid = PFUser.currentUser()?.objectForKey("facebookId") as! String
//        let url = NSURL(string: "https://graph.facebook.com/\(fbid)/picture?type=large")
//        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
//        profilePic.clipsToBounds = true
//        profilePic.sd_setImageWithURL(url)
//
        self.uploadPhoto()
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        
        // TODO: [Anar] Don't upload these details
        // TODO: [Anar] Send either cliq object or the individual details to the CliqNameCollectionViewController
        
        var cliq = PFObject(className:"CliqAlbum")
        cliq["name"] = place!.name
        cliq["address"] = "\n".join(place!.formattedAddress.componentsSeparatedByString(", "))
        //cliq["caption"] = self.captionField.text
        cliq.saveInBackground()
        cliqGroup = cliq
    }

    
    func uploadPhoto() {
        let authorization = PHPhotoLibrary.authorizationStatus()
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                dispatch_async(dispatch_get_main_queue()) {
                    self.uploadPhoto()
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
            controller.addAction(ImageAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("Send %lu Photo", comment: "Action Title"), $0) as String}, handler: { _ in
                presentImagePickerController(.PhotoLibrary)
                }, secondaryHandler: { _, numberOfPhotos in
                    controller.getSelectedImagesWithCompletion() { images in
                        
                        // [Anar] running a loop on the images that were selected by the user
                        
                        for image in images {
                            if let image = image {
                                
                                // [Anar] Capturing image for subsequent view controller, which would be the last image in the iteration
                                // [Anar] Actually, the first image is always used for the cover photo in the next VC, why??
                                self.imageForNameCollection = image
                                
                                let imageData = UIImageJPEGRepresentation(image, 0.55)
                                let imageFile = PFFile(name:"image.jpeg", data:imageData)
                                var userPhoto = PFObject(className:"UserPhoto")
                                userPhoto["creator"] = PFUser.currentUser()!
                                
                                userPhoto["imageFile"] = imageFile
                                
                                // [Anar] save images to an array
                                self.userSelectedImages.append(userPhoto)
                            }
                        }
                        
                        // [Anar] create cliq object, ready to sent over to the next vc
                        var cliq = PFObject(className:"CliqAlbum")
                        cliq["name"] = self.place!.name
                        cliq["address"] = "\n".join(self.place!.formattedAddress.componentsSeparatedByString(", "))
                        self.cliqGroup = cliq
                        
                        // [Anar] advance to the next vc
                        
                        self.performSegueWithIdentifier("applyDetailsSegue", sender: nil)

                    }
            }))
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
                println("Cancelled")
                
                // TODO: [Anar] go back to choosing a location
                
                self.navigationController?.popViewControllerAnimated(true)
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
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var nameCollectionVC : CliqNameCollectionViewController = segue.destinationViewController as! CliqNameCollectionViewController
        
        nameCollectionVC.imageForCoverPhoto = self.imageForNameCollection
        nameCollectionVC.cliqGroup = self.cliqGroup
        nameCollectionVC.userPhotos = self.userSelectedImages
        
    }
}