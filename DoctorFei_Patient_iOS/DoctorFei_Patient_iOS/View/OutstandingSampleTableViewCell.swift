//
//  OutstandingSampleTableViewCell.swift
//  DoctorFei_Patient_iOS
//
//  Created by shadowPriest on 4/9/15.
//
//

import UIKit

@objc class OutstandingSampleTableViewCell: UITableViewCell {
    @IBOutlet weak var sampleName: UILabel!
    @IBOutlet weak var samplePicture: UIImageView!
    @IBOutlet weak var infomation: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setCellData(data: NSDictionary){
        self.sampleName.text = data.objectForKey("name") as? String
        self.infomation.text = data.objectForKey("info") as? String
        self.samplePicture.sd_setImageWithURL(NSURL(string: (data.objectForKey("picture") as String).urlAutoCompelete()!), placeholderImage:UIImage(named: "hospital_pic.png"))
    }
}
