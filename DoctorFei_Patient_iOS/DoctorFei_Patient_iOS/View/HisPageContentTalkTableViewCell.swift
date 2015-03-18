//
//  HisPageContentTalkTableViewCell.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/17/15.
//
//

import UIKit

class HisPageContentTalkTableViewCell: UITableViewCell {
    var doctor:Friends!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    private var _shuoshuo = ShuoShuo()
    var shuoshuo:ShuoShuo{
        get{
            return _shuoshuo
        }
        set(newValue){
            _shuoshuo = newValue
            self.nameLabel.text = "无姓名"
            self.avatarImageView.image = UIImage(named: "home_user_example_pic.png")
            if let doctorId = _shuoshuo.doctorId {
                if (doctorId.integerValue == self.doctor.userId.integerValue){
                    self.nameLabel.text = self.doctor.realname
                    if (self.doctor.icon as NSString).length > 0 {
                        self.avatarImageView.sd_setImageWithURL(NSURL(string: self.doctor.icon), placeholderImage: UIImage(named: "home_user_example_pic"))
                    } else {
                        self.avatarImageView.image = UIImage(named: "home_user_example_pic")
                    }
                }else {
                    if let friend : Friends = Friends.MR_findFirstByAttribute("userId", withValue: _shuoshuo.doctorId) as? Friends {
                        self.nameLabel.text = friend.realname
                        let icon = friend.icon as NSString
                        if (icon.length > 0){
                            self.avatarImageView.sd_setImageWithURL(NSURL(string: friend.icon), placeholderImage: UIImage(named: "home_user_example_pic"))
                        }
                    }
                    
                }
            }
            self.contentLabel.text = _shuoshuo.content
            self.timeLabel.text = _shuoshuo.createTime.timeAgoSinceNow()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
