//
//  NKSelectionGroupCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/13.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKSelectionGroupCell: UITableViewCell {

    @IBOutlet weak var olSelection: UIImageView!
    @IBOutlet weak var olTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setData(_ title: String, imageURL: String? = nil) {
        
        olTitle.text = title
    }

}
