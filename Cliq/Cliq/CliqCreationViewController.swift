import UIKit
import GoogleMaps

class CliqCreationViewController: UIViewController {
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
}
