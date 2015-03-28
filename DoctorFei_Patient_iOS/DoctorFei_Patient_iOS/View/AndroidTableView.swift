//
//  AndroidTableView.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/28/15.
//
//

import UIKit
@objc protocol androidTableViewDelegate{
    optional func androidTableView(androidTableView:AndroidTableView,didSelectRowAtIndexPath indexPath:NSIndexPath)
}
@objc protocol androidTableViewDataSource{
    func androidTableView(androidTableView:AndroidTableView, numberOfRowsInSection section:Int) -> Int
    func androidTableView(androidTableView:AndroidTableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> String
}
@objc class AndroidTableView: UIView ,UITableViewDelegate,UITableViewDataSource{
    var backgroudView:UIView!
    var horizontalView:UIView!
    var verticalView:UIView!
    var cityButton:UIButton!
    var areaButton:UIButton!
    var tableView:UITableView!
    var delegate:androidTableViewDelegate?
    var dataSource:androidTableViewDataSource?
    let androidTableViewCellIdentifier = "AndroidTableViewCellIdentifier"
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroudView = UIView(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.backgroudView.backgroundColor = UIColor(white: 0.0, alpha: 0.9)
        self.addSubview(self.backgroudView)
        self.tableView = UITableView(frame: frame, style: UITableViewStyle.Plain)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ret = self.dataSource?.androidTableView(self, numberOfRowsInSection: section)
        return ret!
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(androidTableViewCellIdentifier) as UITableViewCell?
        if ((cell) == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: androidTableViewCellIdentifier)
        }
        cell?.textLabel?.text = self.dataSource?.androidTableView(self, cellForRowAtIndexPath: indexPath)
        return UITableViewCell()
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
