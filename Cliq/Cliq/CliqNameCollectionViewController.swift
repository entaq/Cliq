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
    }
    
    // TODO: create a photo to be uploaded to parse
    // TODO: create the album with all the properties of this viewController, plus a pointer to the photo that was just created
}
