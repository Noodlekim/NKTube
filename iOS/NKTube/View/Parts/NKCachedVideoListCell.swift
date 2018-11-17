//
//  NKCachedVideoListCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/02/03.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import SDWebImage

typealias DeleteCachedVideoBlock = () -> ()

class NKCachedVideoListCell: UITableViewCell {

    @IBOutlet weak var olThumbnail: UIImageView!
    @IBOutlet weak var olTitleLabel: UILabel!
    @IBOutlet weak var olViewCountLabel: UILabel!
    @IBOutlet weak var olLikeLabel: UILabel!
    @IBOutlet weak var olUnLikeLabel: UILabel!
    @IBOutlet weak var olCachedButton: UIButton!
    
    @IBOutlet weak var olChargeView: UIImageView!
    @IBOutlet weak var olLeftMargin: NSLayoutConstraint!
    
    @IBOutlet weak var olDeleteButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var olHDLabel: UILabel!
    @IBOutlet weak var olDurationLabel: NKLabel!

    @IBOutlet weak var olWidthHDLabel: NSLayoutConstraint!
    
    var deleteBlock: DeleteCachedVideoBlock?
    var cachedVideo: CachedVideo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        NKUtility.viewAnimation {
            if editing {
                self.olDeleteButtonWidth.constant = 32.0
            } else {
                self.olDeleteButtonWidth.constant = 0.0
            }
            self.layoutIfNeeded()
        }
    }
        
    // MARK: - Action
    @IBAction func acDeleteCachedVideo(_ sender: AnyObject) {

        if let video = self.cachedVideo {
            let alert = UIAlertController(title: "削除", message: "この動画を削除しますか？", preferredStyle: .alert)
            let okButton: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                if let videoId = video.videoId {
                    if NKFileManager.deleteCachedFile(videoId) {
                        if #available(iOS 9.0, *) {
                            NKCoreDataCachedVideo.sharedInstance.removeCachedVideoForSpotlight(video)
                        }
                        NKVideoStatusManager.sharedInstance.didRemoveCahceVideo(video, complete: { (isSuccess) in
                            isSuccess ? KLog("파일 삭제 성공!" as AnyObject?) : KLog("파일 삭제 실패!")
                        })
                    } else {
                        KLog("파일 삭제 실패!" as AnyObject?)
                    }
                }
            })
            let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(okButton)
            alert.addAction(cancelButton)
            if let mainVC = AppDelegate.mainVC() {
                mainVC.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setCachedVideoCellData(_ video: CachedVideo) {
        
        self.cachedVideo = video

        if let url = video.thumbMedium, let imageUrl = URL(string: url) {
            self.olThumbnail.sd_setImage(with: imageUrl, placeholderImage: NKImage.defaultThumbnail)
        }
        
        if let title = video.title, let _ = video.order {
            self.olTitleLabel.text = title
        }
        
        if let definition = video.definition, definition == "hd"  {
            self.olHDLabel.text = definition.uppercased()
            olWidthHDLabel.constant = 28
        } else {
            olWidthHDLabel.constant = 0
        }

        if let duration = video.duration {
            self.olDurationLabel.isHidden = false
            self.olDurationLabel.text = duration.formatDurations()
        } else {
            self.olDurationLabel.isHidden = true
        }
        self.layoutIfNeeded()
    }

    // MARK: - Height
    class func height() -> CGFloat {
        return 60.0
    }

}
