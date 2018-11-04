//
//  NKChannelCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/03.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

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
    
    func setData(_ snippet: MABYT3_SubscriptionSnippet) {
        
        if let thumbnail = snippet.thumbnails["default"] as? MABYT3_Thumbnail
            , let imageUrl = URL(string: thumbnail.url) {
            olThumbnail.sd_setImage(with: imageUrl, placeholderImage: NKImage.defaultThumbnail)
        }

        olTitle.text = snippet.title
    }
    
    class func height() -> CGFloat {
        
        return 60.0
    }
}
