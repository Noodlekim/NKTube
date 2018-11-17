//
//  NKYouTubeMenuCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/03.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKYouTubeMenuCell: UITableViewCell {

    @IBOutlet weak var olThumbnail: UIImageView!
    @IBOutlet weak var olTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setData(_ item: Dictionary<String, AnyObject>) {
        
        olThumbnail.image = Array(item.values)[0] as? UIImage
        olTitle.text = Array(item.keys)[0]
    }
    
    class func height() -> CGFloat {
        
        return 40.0
    }

}
