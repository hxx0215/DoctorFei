//
//  HisPageViewController.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/15/15.
//
//

import UIKit

class HisPageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var doctorID = NSNumber()
    private var myContentArray = NSMutableArray()
    private var repostContentArray = NSMutableArray()
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var contentTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var departAndJobLabel: UILabel!
    @IBOutlet weak var approvedStatus: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    func loadAllShuoshuoAndDaylog() {
        if self.doctorID.integerValue == 0{
            return
        }
        let params = ["doctorId" : self.doctorID]
        var hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        MemberAPI.getDoctorShuoShuoWithParameters(params, success: {
            operation, responseObject in
            for iter in responseObject as NSArray {
                let dict = iter as NSDictionary
                if dict["type"] as Int == 1 {
                    var date = dict.objectForKey("createtime" as NSString) as Double
                    var shuoshuo = ShuoShuo(shuoShuoId: dict.objectForKey("id" as NSString) as NSNumber!,
                        doctorId: dict.objectForKey("doctorId" as NSString) as NSNumber!,
                        title: dict.objectForKey("title" as NSString) as NSString!,
                        content: dict.objectForKey("content" as NSString) as NSString!,
                        createTime: NSDate(timeIntervalSince1970: date as NSTimeInterval))
                    if dict["doctorId"] as Int == self.doctorID as Int {
                        self.myContentArray.addObject(shuoshuo)
                    }else {
                        self.repostContentArray.addObject(shuoshuo)
                    }
                } else if dict["type"] as Int == 2 {
                    var daylog = DayLog(dayLogId: dict.objectForKey("id" as NSString) as NSNumber!,
                        doctorId: dict.objectForKey("doctorId" as NSString) as NSNumber!,
                        title: dict.objectForKey("titile" as NSString) as NSString!,
                        content: dict.objectForKey("content" as NSString) as NSString,
                        createTime: NSDate(timeIntervalSince1970: dict.objectForKey("createtime" as NSString) as NSTimeInterval))
                    if dict["doctorId"] as Int == self.doctorID as Int {
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
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        return cell
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
