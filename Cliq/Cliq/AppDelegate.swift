import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyARWlypKPlMgxJDCgTJZUEGRVUxAtAm1qo")
        Parse.setApplicationId("a1PPRqrWNi69aExmxnkCNmRabf13nMoWeduYY3SB", clientKey: "dKEPhkmMHpkQWy2Fo3M7d0tdvNirhzbU5StL3Adu")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)

        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // if "content_available" was used to trigger a background push we skip tracking avoid double counting
            if let options = launchOptions {
                if options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
                    PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
                }
            }
        }
        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock(nil)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: nil)
        }
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
}

