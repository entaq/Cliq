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
    
    var imageForCoverPhoto : UIImage!
    
    override func viewDidLoad() {
        
        coverPhotoImageView.image = imageForCoverPhoto
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CREATE", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        // make placeholder text color white
        nameCollectionTextField.attributedPlaceholder = NSAttributedString(string: "Name your collection", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Give a short description if you like", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
    }
}
