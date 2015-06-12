//
//  HisPageViewController.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/15/15.
//
//

import UIKit

class HisPageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
//    var doctorID = NSNumber()
    var doctor:Friends!
    private var myContentArray = NSMutableArray()
    private var repostContentArray = NSMutableArray()
    private var currentIndexPath = NSIndexPath()
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var contentTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var departAndJobLabel: UILabel!
    @IBOutlet weak var approvedStatus: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.avatarImageView.sd_setImageWithURL(NSURL(string: self.doctor.icon))
        self.nameLabel.text = self.doctor.realname
        self.hospitalLabel.text = self.doctor.hospital
        var depart = self.doctor.department
        if depart == nil {
            depart = ""
        }
        var job = self.doctor.jobTitle
        if job == nil {
            job = ""
        }
        self.departAndJobLabel.text = depart + " " + job
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadAllShuoshuoAndDaylog()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.myContentArray.removeAllObjects()
        self.repostContentArray.removeAllObjects()
    }
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        self.contentTableView.reloadData()
    }
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func likeIt(sender: UIButton) {
        let parma = ["doctorId" : self.doctor.userId,
            "userid" : NSUserDefaults.standardUserDefaults().objectForKey("UserId") as! NSNumber]
        MemberAPI.likeItWithParameters(parma, success: {
            operation, responseObject in
            sender.enabled = false
            var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.dimBackground = true
            hud.mode = MBProgressHUDMode.Text
            hud.labelText = ((responseObject as! NSArray).firstObject as! NSDictionary).objectForKey("msg") as! String
            hud.hide(true, afterDelay: 0.5)
            }, failure: {
                operation, error in
                
        })
    }
    func loadAllShuoshuoAndDaylog() {
        if self.doctor.userId.integerValue == 0{
            return
        }
        let params = ["doctorid" : self.doctor.userId]
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        MemberAPI.getDoctorShuoShuoWithParameters(params, success: {
            operation, responseObject in
            for iter in responseObject as! NSArray {
                let dict = iter as! NSDictionary
                if dict["type"] as! Int == 1 {
                    var date = dict.objectForKey("createtime" as NSString) as! Double
//                    var shuoshuo = ShuoShuo(shuoShuoId: dict.objectForKey("id" as! NSString) as! NSNumber!,
//                        doctorId: NSNumber(integer: ((dict["doctorid"] as! NSString).integerValue)),//这里这么写都是服务器的锅为毛doctorid返回的是个字符串！
//                        title: dict.objectForKey("title" as! NSString) as! NSString!,
//                        content: dict.objectForKey("content" as! NSString) as! NSString!,
//                        createTime: NSDate(timeIntervalSince1970: date as NSTimeInterval))
                    var shuoshuo = ShuoShuo(shuoShuoId: dict.objectForKey("id") as! NSNumber,
                        doctorId: NSNumber(integer: (dict.objectForKey("doctorid") as! String).toInt()!),
                        title: dict.objectForKey("title") as! String,
                        content: dict.objectForKey("content") as! String,
                        createTime: NSDate(timeIntervalSince1970: date as NSTimeInterval))
                    if (dict["sourceid"] as! Int == 0){
                        self.myContentArray.addObject(shuoshuo)
                    }else {
                        self.repostContentArray.addObject(shuoshuo)
                    }
                } else if dict["type"] as! Int == 2 {
                    NSLog("%@", dict)
//                    var daylog = DayLog(dayLogId: dict["id"] as! NSNumber,
//                        doctorId:NSNumber(integer: ((dict["doctorid"] as! NSString).integerValue)),
//                        title: dict["title"] as NSString!,
//                        content: dict["content"] as NSString!,
//                        createTime: NSDate(timeIntervalSince1970: dict["createtime"] as! NSTimeInterval))
                    var daylog = DayLog(dayLogId: dict["id"] as! NSNumber,
                        doctorId: NSNumber(integer: (dict.objectForKey("doctorid") as! String).toInt()!),
                        title: dict.objectForKey("title") as! String,
                        content: dict.objectForKey("content") as! String,
                        createTime: NSDate(timeIntervalSince1970: dict["createtime"] as! NSTimeInterval))
                    if (dict["sourceid"] as! Int == 0){
                        self.myContentArray.addObject(daylog)
                    }else {
                        self.repostContentArray.addObject(daylog)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    hud.hide(false)
                    self.contentTableView.reloadData()
                    });
            }
            }, failure: {
                operation, error in
                hud.mode = MBProgressHUDMode.Text
                hud.labelText = "错误"
                hud.detailsLabelText = (error as NSError).localizedDescription
                hud.hide(true, afterDelay: 1.5)
        })
    }
    // MARK: - TableViewDelegate && DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.contentTypeSegmentControl.selectedSegmentIndex > 0 {
            return repostContentArray.count
        } else {
            return myContentArray.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let HisPageContentTalkTableViewCellIdentifier = "UserPageContentTalkTableViewCellIdentifier"
        let HisPageContentArticleTableViewCellIdentifier = "UserPageContentArticleTableViewCell"
        var content:NSObject
        if self.contentTypeSegmentControl.selectedSegmentIndex > 0 {
            content = repostContentArray[indexPath.row] as! NSObject
        }else{
            content = myContentArray[indexPath.row] as! NSObject
        }
        if content.isKindOfClass(ShuoShuo) {
            var cell = tableView.dequeueReusableCellWithIdentifier(HisPageContentTalkTableViewCellIdentifier, forIndexPath: indexPath) as! HisPageContentTalkTableViewCell
            cell.doctor = self.doctor
            cell.shuoshuo = content as! ShuoShuo
            return cell
        } else if content.isKindOfClass(DayLog){
            var cell = tableView.dequeueReusableCellWithIdentifier(HisPageContentArticleTableViewCellIdentifier, forIndexPath: indexPath) as! HisPageContentArticleTableViewCell
            cell.daylog = content as! DayLog
            return cell
        }
        var cell = UITableViewCell()
        return cell
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        currentIndexPath = indexPath
        return indexPath
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "ShowHisDalylogDetailSegueIdentifier"){
            var vc = segue.destinationViewController as! HisPageDetailViewController
            if (self.contentTypeSegmentControl.selectedSegmentIndex > 0){
                vc.daylog = repostContentArray[currentIndexPath.row] as! DayLog
            }else {
                vc.daylog = myContentArray[currentIndexPath.row] as! DayLog
            }
        }
    }

}
