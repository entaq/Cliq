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
            userPhoto["creator"] = PFUser.currentUser()
            userPhoto["cliqGroup"] = cliq // [Anar] Pointer to the cliqGroup to which the photo belongs
//            cliq["coverPhoto"] = userPhoto // [Anar] Pointer to the photo that was just created
            userPhoto["imageFile"] = imageFile // [Anar] Save as binary on Parse
            userPhoto.saveInBackground() // [Anar] Not saving here at all for some odd reason, looking into it
            
        }
        
//        let parseObjects : [PFObject] = [cliq]
//        PFObject.saveAllInBackground(parseObjects)
        
        // [Anar] Thought it would make more sense to upload the collection here, considering that we may still have to add a pointer to the photo in the preceding code
        // [Anar] But for some odd reason, it won't save the collection when I save here
    }
    
    // TODO: create a photo to be uploaded to parse
    // TODO: create the album with all the properties of this viewController, plus a pointer to the photo that was just created
}
