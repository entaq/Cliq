import UIKit

class CliqListPhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var cliqId = ""
    
    var photos = [PFObject]()
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.loadPhotos()
    }
    
    func loadPhotos() {
        
        collectionView.registerNib(UINib(nibName: "CliqCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        
        // trying to load all the photos that belong to cliqAlbum
        // id of the cliq album would come in handy for a query of those photos
        
        //query all the user photos that belong to the cliqAlbum which the user originally selected from the home controller
        
        let query = PFQuery(className: "UserPhoto")
        query.whereKey("cliqGroup", equalTo: PFObject(outDataWithClassName: "CliqAlbum", objectId: cliqId))
        
        query.orderByDescending("createdAt")
        query.includeKey("creator")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                if let objects = objects as [PFObject]! {
                    self.photos = objects
                    
                    print(self.photos.count)
                    
                    self.collectionView.reloadData()
                }
            } else {
               
                print(error?.description)
            }
        }
        
        
    }
    
    // MARK: Collection view data source methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! CliqCollectionViewCell
        
        let userPhoto = photos[indexPath.row] as PFObject
        
        if let userPhotoFile = userPhoto["imageFile"] as? PFFile {
            
            cell.cliqImage.file = userPhotoFile
            
            cell.cliqImage.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
                cell.setNeedsLayout()
            })
            
            if let creator = userPhoto["creator"] as? PFObject {
                
                if let facebookId = creator["facebookId"] as? String {
                    cell.setCliqCreator(facebookId)
                }
            }
        }
                
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
