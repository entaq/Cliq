class CliqCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var cliqImage: PFImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
    }

    func setCliqCreator(fbid: String) {
//        let fbid = PFUser.currentUser()?.objectForKey("facebookId") as! String
        let url = NSURL(string: "https://graph.facebook.com/\(fbid)/picture?type=large")
        profileImage.sd_setImageWithURL(url)
    }
    
    override func prepareForReuse() {
        profileImage.image = nil
    }
}