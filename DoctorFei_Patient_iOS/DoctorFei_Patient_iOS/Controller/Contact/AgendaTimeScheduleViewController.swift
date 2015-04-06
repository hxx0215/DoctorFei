//
//  AgendaTimeScheduleViewController.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/15/15.
//
//

import UIKit

class AgendaTimeScheduleViewController: UIViewController {
    var doctorId = NSNumber()
    
    
    @IBOutlet weak var scheduleTableBackImage: UIImageView!
    var scheduleMap = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scheduleTableBackImage.layer.cornerRadius = 5.0;
        self.scheduleTableBackImage.layer.masksToBounds = true;
        self.scheduleMap = [ "Monday_AM": NSNumber(integer: 11),
                         "Monday_PM": NSNumber(integer: 12),
                         "Tuesday_AM": NSNumber(integer: 13),
                         "Tuesday_PM": NSNumber(integer: 14),
                         "Wednesday_AM":NSNumber(integer: 15),
                         "Wednesday_PM":NSNumber(integer: 16),
                         "Thursday_AM":NSNumber(integer: 17),
                         "Thursday_PM":NSNumber(integer: 18),
                         "Friday_AM":NSNumber(integer: 19),
                         "Friday_PM":NSNumber(integer: 20),
                         "Saturday_AM":NSNumber(integer: 21),
                         "Saturday_PM":NSNumber(integer: 22),
                         "Sunday_AM":NSNumber(integer: 23),
                         "Sunday_PM":NSNumber(integer: 24)] as NSDictionary
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadSchedule()
    }
    func test(){
        test()
    }
    func testCallByName(bl: Bool,testfunc: @autoclosure ()->Void ){
        if bl {
            println("yes")
        }else {
            println("no")
        }
    }
    func testCallByValue(bl: Bool,testfunc:Void ){
        if bl{
            println("yes")
        }
        else{
            println("no")
        }
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
//        testCallByName(true, testfunc: test())
//        testCallByValue(true, testfunc: test())
        self.navigationController?.popViewControllerAnimated(true)
    }
    func loadSchedule() {
        let params = [ "doctorid" : self.doctorId] as NSDictionary
        MemberAPI.getDoctorScheduleWithParameters(params, success: {
            operation, responseObject in
            NSLog("%@", responseObject as NSArray)
            if (responseObject as NSArray).count > 0 {
                for (key,value) in (responseObject? as NSArray).firstObject as NSDictionary{
                    NSLog("%@:%@", key as NSObject,value as NSObject)
                    if let tTag: AnyObject = self.scheduleMap.objectForKey(key){
                        let tag = tTag as NSNumber
                        var btn = self.view.viewWithTag(tag.integerValue)? as UIButton?
                        btn?.selected = (value as NSNumber).integerValue == 1
                    }
                }
            }
            }, failure: {
                operation, error in
                NSLog("%@", error)
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
