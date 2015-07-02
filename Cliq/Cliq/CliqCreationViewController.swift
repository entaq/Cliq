import UIKit
import GoogleMaps

class CliqCreationViewController: UIViewController, DBCameraViewControllerDelegate {
    var place: GMSPlace?

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
    }

    @IBAction func uploadPhoto(sender: AnyObject) {
        var cameraContainer = DBCameraContainerViewController(delegate: self)
        cameraContainer.setFullScreenMode()

        var nav = UINavigationController(rootViewController: cameraContainer)
        nav.setNavigationBarHidden(true, animated: true)
        self.presentViewController(nav, animated: true, completion: nil)
    }

    func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
        let imageData = UIImageJPEGRepresentation(image, 0.55)

        let imageFile = PFFile(name:"image.jpeg", data:imageData)

        var userPhoto = PFObject(className:"UserPhoto")
        userPhoto["creator"] = PFUser.currentUser()!
        if let cliqGroup = cliqGroup {
            userPhoto["cliqGroup"] = cliqGroup
        }
        userPhoto["imageFile"] = imageFile
        userPhoto.saveInBackground()
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func dismissCamera(cameraViewController: AnyObject!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
