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
                            let id = result.valueForKey("id") as! String

                            currentUser["facebookId"] = id
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

    //MARK: Collection view methods
    
    var photos = [PFObject]()
    @IBOutlet weak var collectionView: UICollectionView!

    func loadPhotos() {
        
        // wiring up collection view with custom collection cell
        collectionView!.registerNib(UINib(nibName: "CliqCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")

        // query all the cliqAlbum objects, use cover photos for each collection cell
        var query = PFQuery(className: "CliqAlbum")
        query.includeKey("coverPhoto")
        query.orderByDescending("createdAt")
        
        
//        var query = PFQuery(className: "UserPhoto")
//        query.includeKey("creator")
//        query.orderByDescending("createdAt")

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
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! CliqCollectionViewCell
        
        let cliqAlbum = photos[indexPath.row] as PFObject
        
        // grab pointer to photo in UserPhoto table in cliqAlbum's coverPhoto
        if let coverPhoto = cliqAlbum["coverPhoto"] as? PFObject {
            cell.cliqImage.file = coverPhoto["imageFile"] as? PFFile
            
            cell.cliqImage.loadInBackground { (_, _) -> Void in
                cell.setNeedsLayout()
            }
            
            if let facebookId : String = cliqAlbum["facebookId"] as? String {
                cell.setCliqCreator(facebookId);
            }
            
        }
        

//        cell.cliqImage.file = photos[indexPath.row]["imageFile"] as? PFFile
//        cell.cliqImage.loadInBackground { (_, _) -> Void in
//            cell.setNeedsLayout()
//        }
//
//        let creator = photos[indexPath.row]["creator"] as! PFUser
//        let fbId = creator.objectForKey("facebookId") as! String
//        cell.setCliqCreator(fbId)

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

