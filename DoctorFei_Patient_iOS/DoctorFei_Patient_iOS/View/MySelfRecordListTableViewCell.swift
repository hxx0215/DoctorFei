//
//  MySelfRecordListTableViewCell.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/10/15.
//
//

import UIKit

class MySelfRecordListTableViewCell: UITableViewCell {
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViews: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var recordDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private var _imageUrl:NSArray = []
    var imageUrl:NSArray{
        get {
            return _imageUrl
        }
        set {
            _imageUrl = newValue.copy() as! NSArray
            let arr = self.imageViews.subviews as NSArray
            for i in 0..<arr.count{
                let v = arr[i] as! UIView
                v.removeFromSuperview()
            }
            self.imageHeightConstraint.constant = CGFloat(_imageUrl.count) * 134.0
            for i in 0..<_imageUrl.count{
                var image = UIImageView()
                image.sd_setImageWithURL(NSURL(string: _imageUrl[i]["img"] as! String ))
                self.imageViews.addSubview(image)
                image.frame = CGRectMake(0, CGFloat(i)*134, 100, 134)
            }
        }
    }
}
