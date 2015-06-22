import UIKit
import GoogleMaps

class CliqHomeViewController : UIViewController, PFLogInViewControllerDelegate, DBCameraViewControllerDelegate {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthAndUpdateLocation()
    }

    func checkAuthAndUpdateLocation() {
        if let currentUser = PFUser.currentUser() where PFFacebookUtils.isLinkedWithUser(currentUser) {
            println(currentUser.description)
            let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            request.startWithCompletionHandler { (connection, result, error) -> Void in
                if error == nil {
                    if self.presentedViewController is PFLogInViewController {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    self.requestPushAuthorization()
                    PFGeoPoint.geoPointForCurrentLocationInBackground {
                        (geoPoint: PFGeoPoint?, error: NSError?) in
                        if error == nil {
                            let fullname = result.valueForKey("name") as! String
                            currentUser["fullname"] = fullname
                            currentUser["location"] = geoPoint!
                            currentUser.saveInBackground()
                        } else {
                            println("could not get geopoint \(error?.description)")
                            //TODO: something went wrong
                        }
                    }
                } else {
                    self.showLoginScreen()
                }
            }
        } else {
            showLoginScreen()
        }
    }

    var placePicker: GMSPlacePicker?
    var cliqGroup : PFObject?

    @IBAction func startCliq(sender: UIBarButtonItem) {
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint, error) -> Void in
            let center = CLLocationCoordinate2DMake(geopoint!.latitude, geopoint!.longitude)
            let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
            let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let config = GMSPlacePickerConfig(viewport: viewport)
            self.placePicker = GMSPlacePicker(config: config)

            self.placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
                if let error = error {
                    println("Pick Place error: \(error.localizedDescription)")
                    return
                }

                var cliqCreationVC = self.storyboard?.instantiateViewControllerWithIdentifier("Create Cliq") as! CliqCreationViewController
                cliqCreationVC.place = place

                self.presentViewController(cliqCreationVC, animated: true, completion: nil)
            })
        }
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

    func requestPushAuthorization() {
        let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        checkAuthAndUpdateLocation()
    }

    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println("could not log in \(error?.description)")
        //TODO: something went wrong
    }

    func showLoginScreen() {
        let logInViewController = PFLogInViewController()
        logInViewController.delegate = self
        logInViewController.facebookPermissions = ["public_profile", "user_friends"]
        logInViewController.fields = .Facebook
        logInViewController.logInView?.logo = UIImageView(image: UIImage(named: "cliq_logo.png")!)
        logInViewController.logInView?.facebookButton
        self.presentViewController(logInViewController, animated: true, completion: nil)
    }

}

