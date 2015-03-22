//
//  HisPageDetailViewController.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/20/15.
//
//

import UIKit
class ShareBackgroundView: UIView {
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.willHide()
    }
    var willHide:(Void)->() = {
        
    }
}
class HisPageDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareBackgroundView: ShareBackgroundView!
    @IBOutlet weak var shareBottomConstraint: NSLayoutConstraint!

    var daylog = DayLog()
    private var format = NSDateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.format.dateFormat = "yyyy-MM-dd HH:mm:"
        // Do any additional setup after loading the view.
        self.shareBackgroundView.hidden = true
        self.shareBottomConstraint.constant = -240
        weak var weakSelf = self
        self.shareBackgroundView.willHide = {
            var strongSelf = weakSelf
            strongSelf?.showShareView(false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.titleLabel.text = self.daylog.title
        self.createTimeLabel.text = self.format.stringFromDate(self.daylog.createTime)
        self.contentText.text = self.daylog.content
    }
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func shareButtonClicked(sender: AnyObject) {
        self.shareBackgroundView.hidden = false
        self.showShareView(true)
    }
    func showShareView(flag: Bool){
        if flag {
            self.shareBottomConstraint.constant = 0
        } else {
            self.shareBottomConstraint.constant = -240
        }
        self.shareBackgroundView.setNeedsUpdateConstraints()
        if flag{
            UIView.animateWithDuration(0.5, animations: {
                self.shareBackgroundView.layoutIfNeeded()
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.shareBackgroundView.layoutIfNeeded()
                }, completion: { comp in
                    self.shareBackgroundView.hidden = true
            })
        }
    }
    @IBAction func shareAction(sender : UIButton){
        var dic = ["content" : self.contentText.text,
            "vc" : self,
        ]
        ShareUtil.sharedShareUtil().shareTo(shareTypeWeibo, content: dic)
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
