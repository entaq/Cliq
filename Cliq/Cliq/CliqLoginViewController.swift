import UIKit

class CliqLoginViewController : UIViewController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let logInViewController = PFLogInViewController()
        logInViewController.facebookPermissions = ["friends_about_me"]
        logInViewController.fields = .Facebook
        
        self.presentViewController(logInViewController, animated: true, completion: nil)
    }
}

