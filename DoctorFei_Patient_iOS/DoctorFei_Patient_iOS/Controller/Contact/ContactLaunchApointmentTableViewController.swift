//
//  ContactLaunchApointmentTableViewController.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/13/15.
//
//

import UIKit

class ContactLaunchApointmentTableViewController: UITableViewController,TextBasicInfoVCDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var detailContent: UITextView!
    
    var formatter =  NSDateFormatter()
    weak var currentText: UILabel!
    var ageArray = NSMutableArray()
    var doctorId = NSNumber()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        self.dateLabel.text = self.formatter.stringFromDate(NSDate())
        self.nameLabel.text = ""
        self.mobileLabel.text = ""
        self.ageLabel.text = "18"
        self.maleButton.selected = true
        self.detailContent.text = ""
        for i in 1...200 {
            ageArray.addObject("\(i)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func timeButtonClicked(sender: AnyObject) {
        var actionSheet = ActionSheetDatePicker(title: "", datePickerMode: UIDatePickerMode.DateAndTime, selectedDate: NSDate(), doneBlock: {
            picker, selectedDate, origin in
            self.dateLabel.text = self.formatter.stringFromDate(selectedDate as NSDate)
            }, cancelBlock: {
                picker in
                
        }, origin: sender as UIButton)
        actionSheet.showActionSheetPicker()
    }
    @IBAction func ageButtonClicked(sender: AnyObject) {
        var actionSheet = ActionSheetStringPicker(title: "", rows: self.ageArray, initialSelection: self.ageLabel.text!.toInt()! - 1, doneBlock: {
            picker, selectedIndex, selectedValue in
                self.ageLabel.text = selectedValue as? String 
            }, cancelBlock: {
                picker in
        }, origin: sender as UIButton)
        actionSheet.showActionSheetPicker()
    }
    @IBAction func maleButtonClicked(sender: UIButton) {
        self.maleButton.selected = (sender == self.maleButton)
        self.femaleButton.selected = (sender == self.femaleButton)
    }
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func sendButtonClicked(sender: AnyObject) {
        let uid = NSUserDefaults.standardUserDefaults().objectForKey("UserId") as NSNumber
        let params = ["userid" : uid,
            "doctorid" : self.doctorId,
            "uname" : self.nameLabel.text!,
            "sex" : self.maleButton.selected ? NSNumber(int: 1) : NSNumber(int: 0),
            "old" : self.ageLabel.text!,
            "times" : self.dateLabel.text!,
            "tel" : self.mobileLabel.text!,
            "notes" : self.detailContent.text]
        MemberAPI.setAppointmentWithParameters(params,
            success: {
            operation, responseObject in
                NSLog("%@", responseObject as NSObject)
                var hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
                let msg = (responseObject as NSArray).firstObject?.objectForKey("msg") as String
                hud.labelText = msg
                hud.dimBackground = true
                hud.mode = MBProgressHUDMode.Text
                hud.hide(true, afterDelay: 1.0)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                    self.navigationController?.popViewControllerAnimated(true)
                    return
                    });
            }, failure: {
                operation, error in
                NSLog("%@", error)
        })
    }
    
    func textBasicInfoVC(infoVC: TextBasicInfoViewController!, didClickedConfirmButtonWithText text: String!) {
        currentText?.text = text
    }
    // MARK: - Table view data source
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
//        return 0
//    }

//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "LaunchAppointmentNameSegueIdentifier" {
            var vc = segue.destinationViewController as TextBasicInfoViewController
            vc.delegate = self
            currentText = self.nameLabel
        }
        if segue.identifier == "LaunchAppointmentMobileSegueIdentifier" {
            var vc = segue.destinationViewController as TextBasicInfoViewController
            vc.delegate = self
            currentText = self.mobileLabel
        }
    }
   

}
