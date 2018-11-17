//
//  NKFavoriteCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/03.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKFavoriteCell: UITableViewCell {

    @IBOutlet weak var olAniView: UIImageView!
    @IBOutlet weak var olThumbnail: UIImageView!
    @IBOutlet weak var olTitle: UILabel!
    @IBOutlet weak var olCacheButton: UIButton!
    @IBOutlet weak var olDurationLabel: NKLabel!
    @IBOutlet weak var olHDLabel: UILabel!

    @IBOutlet weak var olViewCountLabel: UILabel!
    @IBOutlet weak var olLikeLabel: UILabel!
    @IBOutlet weak var olUnLikeLabel: UILabel!

    var video: NKVideo?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        olAniView.animationImages = [UIImage(named: "ani1")!, UIImage(named: "ani2")!, UIImage(named: "ani3")!, UIImage(named: "ani4")!, UIImage(named: "ani5")!]
        olAniView.animationDuration = 0.4
        olAniView.animationRepeatCount = 0
        olAniView.startAnimating()
    }
    
    func setData(_ video: NKVideo) {
        
        self.video = video
        olAniView.startAnimating()
        if let url = video.thumbMedium, let imageUrl = URL(string: url) {
            olThumbnail.sd_setImage(with: imageUrl, placeholderImage: NKImage.defaultThumbnail, options: [], completed: { (_, _, _, _) -> Void in
                self.olAniView.stopAnimating()
            })
        }

        olTitle.text = video.title
        
        if let viewCount = video.viewCount {
            olViewCountLabel.text = viewCount        }
        
        if let likeCount = video.likeCount {
            olLikeLabel.text = likeCount
        }
        
        if let dislikeCount = video.dislikeCount {
            olUnLikeLabel.text = dislikeCount
        }

        let cachedVideoIds = NKCoreDataCachedVideo.sharedInstance.cachedVideoIds
        if cachedVideoIds.contains(video.videoId!) {
            self.olCacheButton.isSelected = true
        } else {
            self.olCacheButton.isSelected = false
        }
        
        if let duration = video.duration {
            olDurationLabel.text = duration.formatDurations()
        }
        if let definition = video.definition, definition == "hd"  {
            olHDLabel.text = definition.uppercased()
            olHDLabel.isHidden = false
        } else {
            olHDLabel.isHidden = true
        }


    }
    
    class func height() -> CGFloat {
        
        return 60.0
    }

    @IBAction func acStartCaching(_ sender: AnyObject) {
        if let video = self.video {
            NKVideoStatusManager.sharedInstance.didStartDownload(video, location: .youtubeGood)
        }
    }
}

