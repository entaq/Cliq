import UIKit
import GoogleMaps

class CliqHomeViewController : UIViewController, PFLogInViewControllerDelegate, UICollectionViewDataSource {
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
                            self.loadPhotos()
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

    var photos = [PFObject]()
    @IBOutlet weak var collectionView: UICollectionView!

    func loadPhotos() {
        var query = PFQuery(className: "UserPhoto")
        query.orderByDescending("createdAt")

        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in

            if error == nil {
                if let objects = objects as? [PFObject] {
                    self.photos = objects
                    self.collectionView.reloadData()
                }
            }
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PFCollectionViewCell

        cell.imageView.file = photos[indexPath.row]["imageFile"] as? PFFile
        cell.imageView.loadInBackground { (_, _) -> Void in
            cell.setNeedsLayout()
        }

        cell.textLabel.text = photos[indexPath.row]["userName"] as? String

        return cell
    }

    var placePicker: GMSPlacePicker?
    var cliqGroup : PFObject?
    var selectedPlace : GMSPlace?

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
                self.selectedPlace = place
                self.performSegueWithIdentifier("Create Cliq", sender: nil)
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Create Cliq" {
            var cliqCreationVC = segue.destinationViewController as! CliqCreationViewController
            cliqCreationVC.place = self.selectedPlace
        }
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

