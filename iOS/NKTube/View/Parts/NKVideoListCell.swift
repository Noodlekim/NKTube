//
//  NKVideoListCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/02/03.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import SDWebImage

class NKVideoListCell: UITableViewCell {

    @IBOutlet weak var olAniView: UIImageView!
    @IBOutlet weak var olThumbnail: UIImageView!
    @IBOutlet weak var olTitleLabel: UILabel!
    @IBOutlet weak var olViewCountLabel: UILabel!
    @IBOutlet weak var olLikeLabel: UILabel!
    @IBOutlet weak var olCachedButton: NKStatusButton!
    @IBOutlet weak var olDurationLabel: NKLabel!
    
    @IBOutlet weak var olChargeView: UIImageView!
    @IBOutlet weak var olLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var olHDLabel: UILabel!
    @IBOutlet weak var olWidthHDLabel: NSLayoutConstraint!
    
    var video: NKVideo?
    var location: DownloadLocation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Action
    @IBAction func acStartCacheVideo(_ sender: AnyObject) {

        if let video = video {            
            NKVideoStatusManager.sharedInstance.didStartDownload(video, location: location!)
        }
    }
    
    // MARK: - Set Data
    func setVideoCellData(_ video: NKVideo, location: DownloadLocation) {
        
        func setStyle(_ label: UILabel) {
            let attributedText = NSMutableAttributedString(string: label.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.2
            paragraphStyle.lineBreakMode = .byTruncatingTail
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
            
            label.attributedText = attributedText
        }

        self.location = location
        self.video = video
        if let url = video.thumbMedium, let imageUrl = URL(string: url) {
            olThumbnail.sd_setImage(with: imageUrl, placeholderImage: NKImage.defaultThumbnail, options: [], completed: { (_, _, _, _) in
                self.olAniView.stopAnimating()
            })
        }

        if let title = video.title {
            if let definition = video.definition, definition == "hd"  {
                olTitleLabel.text = "　　 "+title
            } else {
                olTitleLabel.text = title
            }
            setStyle(olTitleLabel)
        }
        
        if let viewCount = video.viewCount {
            olViewCountLabel.text = viewCount.decimal()
        }

        if let like = video.likeCount, let unLike = video.dislikeCount {
            if like == "0" || unLike == "0" {
                olLikeLabel.text = "--%"
            } else {
                olLikeLabel.text = "\(Int(Float(like)!/(Float(like)!+Float(unLike)!)*100))%"
            }
        }
        
        
        // 비디오 상태에 따른 버튼 상태 처리
        self.olCachedButton.videoStatus = VideoQuality.statusFromVideo(video)
        
        if let definition = video.definition, definition == "hd"  {
            olHDLabel.text = definition.uppercased()
            olWidthHDLabel.constant = 28
        } else {
            olWidthHDLabel.constant = 0
        }
        
        if let duration = video.duration {
            olDurationLabel.text = duration.formatDurations()
        }
        
        self.layoutIfNeeded()
    }
    
    // MARK: - Height
    class func cellHeight() -> CGFloat {
        return 60.0
    }

}
