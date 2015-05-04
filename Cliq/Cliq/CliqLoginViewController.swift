import UIKit

class CliqLoginViewController : UIViewController, PFLogInViewControllerDelegate {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let currentUser = PFUser.currentUser() where PFFacebookUtils.isLinkedWithUser(currentUser) {
            println(currentUser.description)

            PFGeoPoint.geoPointForCurrentLocationInBackground {
                (geoPoint: PFGeoPoint?, error: NSError?) in
                if error == nil {
                    println("got location \(geoPoint?.description)")
                } else {
                    println("error  \(error?.description)")
                }
            }
        } else {
            let logInViewController = PFLogInViewController()
            logInViewController.delegate = self
            logInViewController.facebookPermissions = ["friends_about_me"]
            logInViewController.fields = .Facebook
            logInViewController.logInView?.logo = UIImageView(image: UIImage(named: "cliq_logo.png")!)
            logInViewController.logInView?.facebookButton
            self.presentViewController(logInViewController, animated: true, completion: nil)
        }
    }

    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        println(user.description)
    }

    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        //TODO: something went wrong
    }
}

