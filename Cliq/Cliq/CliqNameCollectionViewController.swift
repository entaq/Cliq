//
//  CliqNameCollectionViewController.swift
//  Cliq
//
//  Created by Anar Enhsaihan on 7/7/15.
//  Copyright (c) 2015 Arun Nagarajan. All rights reserved.
//

import UIKit

class CliqNameCollectionViewController: UIViewController {
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    @IBOutlet weak var nameCollectionTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // Switches
    
    @IBOutlet weak var privateCollectionSwitch: UISwitch!
    @IBOutlet weak var customDateTimeSwitch: UISwitch!
    @IBOutlet weak var inviteFriendsAtLocationSwitch: UISwitch!
    
    var imageForCoverPhoto : UIImage!
    
    override func viewDidLoad() {
        
        coverPhotoImageView.image = imageForCoverPhoto
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CREATE", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("uploadCollection"))
        
        // make placeholder text color white
        nameCollectionTextField.attributedPlaceholder = NSAttributedString(string: "Name your collection", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Give a short description if you like", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
    }
    
    func uploadCollection() {
        
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
                        
                        if (success) {
                            println("Saved cliq successfully")
                        } else {
                            println(error)
                        }
                    })
                } else {
                    println(error)
                }
            })
            
        }
        
    }
    
}
