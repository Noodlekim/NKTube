//
//  NKSettingListCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/07/10.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKSettingListCell: UITableViewCell {

    @IBOutlet weak var olTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func heightCell() -> CGFloat {
        return 39.0
    }
}
