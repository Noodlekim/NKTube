//
//  NKChannelCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/03.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import SDWebImage

class NKChannelCell: UITableViewCell {

    @IBOutlet fileprivate weak var olThumbnail: UIImageView!
    @IBOutlet fileprivate weak var olTitle: UILabel!
    
    var video: NKVideo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ channel: Channel) {
        
        if let thumbnail = channel.defaultThumb,
            let url = URL(string: thumbnail) {
            olThumbnail?.sd_setImage(with: url, completed: nil)
        }
        olTitle.text = channel.title
    }
    
    class func height() -> CGFloat {
        
        return 60.0
    }
}
