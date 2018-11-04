//
//  NKStatusButton.swift
//  NKTube
//
//  Created by GibongKim on 2016/06/18.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

enum VideoStatus: Int {
    case canDownload = 1000
    case downloaded = 2000
    case inQue = 3000
    
    static func statusFromRawValue(_ value: Int) -> VideoStatus {
        switch value {
        case 1000:
            return .canDownload
        case 2000:
            return .downloaded
        case 3000:
            return .inQue
        default: return .canDownload
        }
    }

    
    static func statusFromVideo(_ video: VideoProtocol) -> VideoStatus {
        if let video = video as? NKVideo, NKDownloadManager.sharedInstance.isInQueVideos.contains(video) {
            return .inQue
        } else {
            let cachedVideoIds = NKCoreDataCachedVideo.sharedInstance.cachedVideoIds
            
            if let videoId = video.commonId, cachedVideoIds.contains(videoId) {
                return .downloaded
            } else {
                return .canDownload
            }
        }
    }
}

class NKStatusButton: UIButton {

    var tempVideoStatus: VideoStatus = .canDownload
    var videoStatus: VideoStatus {
        get {
            return tempVideoStatus
        }
        set (status) {
            tempVideoStatus = status
            switch status {
            case .canDownload:
                self.isUserInteractionEnabled = true
                self.setTitle("", for: UIControlState())
                self.setImage(UIImage(named: NKDesign.iCon.downloadStatusCan), for: UIControlState())
            case .inQue:
                self.isUserInteractionEnabled = false
                self.setTitle("", for: UIControlState())
                self.setImage(UIImage(named: NKDesign.iCon.downloadStatusInQue), for: UIControlState())
            case .downloaded:
                self.isUserInteractionEnabled = false
                self.setImage(UIImage(named: NKDesign.iCon.downloadStatusComplete), for: UIControlState())
            }

        }
    }
    
    
}
