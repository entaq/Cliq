//
//  CliqNameCollectionViewController.swift
//  Cliq
//
//  Created by Anar Enhsaihan on 7/7/15.
//  Copyright (c) 2015 Arun Nagarajan. All rights reserved.
//
// Provide metadata for your cliq album

import UIKit

class CliqNameCollectionViewController: UIViewController {
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    @IBOutlet weak var nameCollectionTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // Switches
    
    @IBOutlet weak var privateCollectionSwitch: UISwitch!
    @IBOutlet weak var customDateTimeSwitch: UISwitch!
    @IBOutlet weak var inviteFriendsAtLocationSwitch: UISwitch!
    
    var cliqGroup : PFObject?
    
    var imageForCoverPhoto : UIImage!
    
    var userPhotos = [PFObject]()
    
    var activityIndicator : UIActivityIndicatorView?
    
    override func viewDidLoad() {
        
        coverPhotoImageView.image = imageForCoverPhoto
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CREATE", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("uploadCollection"))
        
        // make placeholder text color white
        nameCollectionTextField.attributedPlaceholder = NSAttributedString(string: "Name your collection", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Give a short description if you like", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
    }
    
    // [Question to Arun] Should the argument be optional?
    func uploadCliqWithCoverPhoto(userPhoto: PFObject) {
        
        let user = PFUser.currentUser()! as PFObject
        
        let cliq = self.cliqGroup!
        
        cliq["facebookId"] = user["facebookId"]
        cliq["coverPhoto"] = userPhoto // [Anar] Pointer to the last userPhoto that was just created
        cliq.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            // [Anar] allow user inputs again
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (success) {
                    print("Saved cliq successfully")
                    
                    // [Anar] pop to home, and then advance to list photos VC
                    
                    let listPhotosVC : CliqListPhotosViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListPhotosVC") as! CliqListPhotosViewController
                    listPhotosVC.cliqId = cliq.objectId!
                    
                    if let navController : UINavigationController = self.navigationController {
                        navController.popToRootViewControllerAnimated(false)
                        navController.pushViewController(listPhotosVC, animated: false) // [Anar] play around with true/false to your liking
                    }
                    
                    
                } else {
                    
                    // TODO: [Anar] might be nice to let the user know with an alert controller
                    
                    print(error)
                }
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator!.stopAnimating()
            })
            
        })
    }
    
    func uploadPhotos() {
        
        // [Anar] stop gap measure to prevent multiple uploads of cliq until we find a way to just use the photo the user selected as a cover
        let lastPhoto = userPhotos.last
        
        for userPhoto in userPhotos {
                        
            let cliq = self.cliqGroup!
            
            userPhoto["creator"] = PFUser.currentUser()
            userPhoto["cliqGroup"] = cliq // [Anar] Pointer to the cliqGroup to which the photo belongs
            userPhoto.saveInBackgroundWithBlock({ (success, error) -> Void in
                if (success) {
                    print("Saved photo successfully")
                    
                    // TODO: upload cliq with the photo which the user selected as the cover photo
                    
                    if userPhoto == lastPhoto
                    {
                        self.uploadCliqWithCoverPhoto(userPhoto)
                    }
                    
                    
                } else {
                    
                    // TODO: [Anar] might be a good idea to let user know with an alert controller
                    
                    print(error)
                    
                    // [Anar] allow user inputs again
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        self.activityIndicator!.stopAnimating()
                    })
                }
            })
        }
    }
    
    func uploadCollection() {
        
        // prevent user from interacting with the app during creation of the cliq
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        // superimpose a spinning indicator while the cliq is being created
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
        activityIndicator!.center = self.view.center
        activityIndicator!.hidesWhenStopped = true
        activityIndicator!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
        
        // TODO: once cliq is created, revert user to home view controller
        
        let cliq = self.cliqGroup!
        cliq["collectionName"] = nameCollectionTextField.text
        cliq["description"] = descriptionTextField.text
        cliq["private"] = privateCollectionSwitch.on
        cliq["customDateTime"] = customDateTimeSwitch.on
        cliq["inviteFriends"] = inviteFriendsAtLocationSwitch.on
        cliq.saveInBackground()
        
        uploadPhotos()
        
    }
    
}
