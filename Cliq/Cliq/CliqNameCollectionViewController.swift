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
    
    override func viewDidLoad() {
        
        coverPhotoImageView.image = imageForCoverPhoto
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CREATE", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("uploadCollection"))
        
        // make placeholder text color white
        nameCollectionTextField.attributedPlaceholder = NSAttributedString(string: "Name your collection", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Give a short description if you like", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
    }
    
    func uploadCollection() {
        
        // prevent user from interacting with the app during creation of the cliq
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        // superimpose a spinning indicator while the cliq is being created
        var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // TODO: once cliq is created, revert user to home view controller
        
        var cliq = PFObject(className: "CliqAlbum")
        cliq["collectionName"] = nameCollectionTextField.text
        cliq["description"] = descriptionTextField.text
        cliq["private"] = privateCollectionSwitch.on
        cliq["customDateTime"] = customDateTimeSwitch.on
        cliq["inviteFriends"] = inviteFriendsAtLocationSwitch.on
        cliq.saveInBackground()
        
        // [Anar] Upload photo and associated data to Parse
        
        var userPhoto : PFObject
        
        if let image = imageForCoverPhoto {
            let imageData = UIImageJPEGRepresentation(image, 0.55)
            let imageFile = PFFile(name: "image.jpeg", data: imageData)
            userPhoto = PFObject(className: "UserPhoto")
            
            let user = PFUser.currentUser()! as PFObject
            
            userPhoto["creator"] = PFUser.currentUser()
            userPhoto["cliqGroup"] = cliq // [Anar] Pointer to the cliqGroup to which the photo belongs
            userPhoto["imageFile"] = imageFile // [Anar] Save as binary on Parse
            userPhoto.saveInBackgroundWithBlock({ (success, error) -> Void in
                if (success) {
                    println("Saved photo successfully")
                    
                    cliq["facebookId"] = user["facebookId"]
                    cliq["coverPhoto"] = userPhoto // [Anar] Pointer to the photo that was just created
                    cliq.saveInBackgroundWithBlock({ (success, error) -> Void in
                        
                        // [Anar] allow user inputs again
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            if (success) {
                                println("Saved cliq successfully")
                                
                                // [Anar] pop to home, and then advance to list photos VC
                                
                                var listPhotosVC : CliqListPhotosViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListPhotosVC") as! CliqListPhotosViewController
                                listPhotosVC.cliqId = cliq.objectId!
                                
                                let navController : UINavigationController = self.navigationController!
                                navController.popToRootViewControllerAnimated(false)
                                navController.pushViewController(listPhotosVC, animated: false) // [Anar] play around with true/false to your liking
                                
                            } else {
                                
                                // TODO: [Anar] might be nice to let the user know with an alert controller
                                
                                println(error)
                            }
                            
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            activityIndicator.stopAnimating()
                        })
                        
                    })
                } else {
                    
                    // TODO: [Anar] might be a good idea to let user know with an alert controller
                    
                    println(error)
                    
                    // [Anar] allow user inputs again
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        activityIndicator.stopAnimating()
                    })
                }
            })
            
        }
        
    }
    
}
