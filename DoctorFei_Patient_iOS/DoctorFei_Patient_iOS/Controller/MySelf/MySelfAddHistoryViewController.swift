//
//  MySelfAddHistoryViewController.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/12/15.
//
//

import UIKit

class MySelfAddHistoryViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var images:NSMutableArray?
    private let collectionViewIdentifier = "HistoryCollectionCellIdentifier"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.images = NSMutableArray()
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let a=images{
            return a.count + 1
        } else{
            return 1
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewIdentifier, forIndexPath: indexPath) as MySelfRecordAddCollectionViewCell
        if let tImages=images{
            if indexPath.row < tImages.count{
                cell.contentImage.image = tImages[indexPath.row] as? UIImage
            } else{
                cell.contentImage.image = UIImage(named: "add-picture_btn.png")
            }
        }else{
            cell.contentImage.image = UIImage(named: "add-picture_btn.png")
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(60, 60)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.images!.count{
            var actionSheet = swiftActionSheet()
            actionSheet.father = self.view
            actionSheet.delegate = self
            actionSheet.show()
        }
    }

    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        var sourceType = UIImagePickerControllerSourceType.Camera
        switch (buttonIndex){
        case 0:
            sourceType = UIImagePickerControllerSourceType.Camera
        case 1:
            sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        default:
            sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        }
        var imagePickController = UIImagePickerController()
        imagePickController.allowsEditing = true
        imagePickController.delegate = self
        imagePickController.sourceType = sourceType
        self.presentViewController(imagePickController, animated: true, completion: {
            
        })
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
