//
//  NKDownloadListCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/09.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKDownloadListCell: UITableViewCell {

    
    @IBOutlet weak var olThumbnail: UIImageView!
    @IBOutlet weak var olTitle: UILabel!
//    @IBOutlet weak var olDurationLabel: NKLabel!
//    @IBOutlet weak var olHDLabel: UILabel!

    var index: Int?

    @IBAction func acRemoveFromQue(_ sender: AnyObject) {
        
        NKDownloadManager.sharedInstance.cancelReservedDownloadOperation(index!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func setData(_ video: NKVideo, index: Int) {
        self.index = index
        olTitle.text = video.title!
        if let image = video.thumbDefault {
            olThumbnail.sd_setImage(with: URL(string: image), placeholderImage: NKImage.defaultThumbnail)
        }
        
    }
}
