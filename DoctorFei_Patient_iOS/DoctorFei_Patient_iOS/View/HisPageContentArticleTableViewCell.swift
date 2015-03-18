//
//  HisPageContentArticleTableViewCell.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 3/17/15.
//
//

import UIKit

class HisPageContentArticleTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    var _daylog = DayLog()
    var daylog:DayLog {
        get {
            return _daylog
        }
        set (newValue){
            _daylog = newValue
            self.titleLabel.text = _daylog.title
            self.timeLabel.text = _daylog.createTime.timeAgoSinceNow()
            self.contentLabel.text = _daylog.content
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
