//
//  MySelfAddHistoryViewController.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/12/15.
//
//

import UIKit

class MySelfAddHistoryViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    var images:NSMutableArray?
    private let collectionViewIdentifier = "HistoryCollectionCellIdentifier"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.images = NSMutableArray()
        self.notes.inputAccessoryView = self.keyboardBar
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var keyboardBar: UIToolbar!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func keyboardDone(sender: AnyObject) {
        self.notes.resignFirstResponder()
    }

    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func saveHistory(sender: AnyObject) {
        self.notes.resignFirstResponder()
        var imgUrl = ""
        if (self.images!.count > 0){
            for i in 0..<self.images!.count - 1{
            imgUrl += self.images![i] as! String
            imgUrl += ","
            }
        }
        if let l: AnyObject = self.images!.lastObject {
            imgUrl += l as! String
        }
        let params = ["suid" : NSUserDefaults.standardUserDefaults().objectForKey("UserId")! as! NSNumber ,
            "notes" : self.notes.text,
            "imgs" : imgUrl]
        MemberAPI.setHistoryWithParameters(params,
            success: {
                operation, responseObject in
                let response = (responseObject as! NSArray).firstObject as! NSDictionary
                var hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
                hud.labelText = response.objectForKey("msg") as! String
                hud.dimBackground = true
                hud.hide(true, afterDelay: 0.5)
                hud.mode = MBProgressHUDMode.Text
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    self.navigationController?.popViewControllerAnimated(true)
                    return
                })
            }, failure: {
                operation, error in
        })
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let a=images{
            return a.count + 1
        } else{
            return 1
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewIdentifier, forIndexPath: indexPath) as! MySelfRecordAddCollectionViewCell
        if let tImages=images{
            if indexPath.row < tImages.count{
                cell.contentImage.sd_setImageWithURL(NSURL(string: images![indexPath.row] as! String))
            } else{
                cell.contentImage.image = UIImage(named: "add-picture_btn.png")
            }
        }else{
            cell.contentImage.image = UIImage(named: "add-picture_btn.png")
        }
//        if indexPath.row < images!.count{
//            cell.contentImage.sd_setImageWithURL(NSURL(string: images![indexPath.row] as String))
//        }else{
//            cell.contentImage.image = UIImage(named: "add-picture_btn.png")
//        }
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
            sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        default:
            return
        }
        var imagePickController = UIImagePickerController()
        imagePickController.allowsEditing = true
        imagePickController.delegate = self
        imagePickController.sourceType = sourceType
        self.presentViewController(imagePickController, animated: true, completion: {
            
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = (info as NSDictionary).objectForKey(UIImagePickerControllerEditedImage) as! UIImage?
        picker.dismissViewControllerAnimated(true, completion: {
            if let img = image {
                var hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
                hud.labelText = "上传中"
                MemberAPI.uploadImage(img, success: {
                    operation,responseObject in
                    NSLog("%@", responseObject as! NSObject)
                    self.images!.addObject(((responseObject as! NSArray).firstObject as! NSDictionary).objectForKey("spath")!)
                    hud.hide(true)
                    self.collectionView.reloadData()
                    }, failure: {
                        operation,error in
                        NSLog("%@", error)
                })
            }
        })
    }
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "病历信息" {
            textView.text = ""
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "病历信息"
        }
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
