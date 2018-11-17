//
//  NKSearchResultCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/03/14.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKSearchResultCell: UITableViewCell {

    @IBOutlet weak var olKeywordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setKeyword(_ keyword: String) {
        self.olKeywordLabel.text = keyword
    }
    
    class func cellHeight() -> CGFloat {
        return 40.0
    }
}
