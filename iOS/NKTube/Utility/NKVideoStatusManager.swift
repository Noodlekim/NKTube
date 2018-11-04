//
//  NKVideoStatusManager.swift
//  NKTube
//
//  Created by NoodleKim on 2016/07/03.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

enum DownloadLocation {
    case youtubeChannel
    case youtubeWatchAfter
    case youtubeGood
    case youtubePopular
    case youtubeRecommand
    case centerPlayer
    case centerRecommand
    case centerPopular
    case searchMenu
}

class NKVideoStatusManager: NSObject {

    static let sharedInstance: NKVideoStatusManager = NKVideoStatusManager()

    func didStartDownload(_ video: NKVideo, location: DownloadLocation) {
        switch location {
        case .youtubeChannel:
            NKFlurryManager.sharedInstance.actionForDownloadOnYouTubeMenuChannel(video)
        case .youtubeWatchAfter:
            NKFlurryManager.sharedInstance.actionForDownloadOnYouTubeMenuWatchAfter(video)
        case .youtubeGood:
            NKFlurryManager.sharedInstance.actionForDownloadOnYouTubeMenuGood(video)
        case .youtubePopular:
            NKFlurryManager.sharedInstance.actionForDownloadOnYouTubeMenuPopular(video)
        case .youtubeRecommand:
            NKFlurryManager.sharedInstance.actionForDownloadCenterRecommand(video)
        case .centerPlayer:
            NKFlurryManager.sharedInstance.actionForDownloadOnCenterPlayer(video)
        case .centerRecommand:
            NKFlurryManager.sharedInstance.actionForDownloadCenterRecommand(video)
        case .centerPopular:
            NKFlurryManager.sharedInstance.actionForDownloadOnCenterPopular(video)
        case .searchMenu:
            NKFlurryManager.sharedInstance.actionForDownloadOnSearchMenu(video)
        default:
            break
        }
        NKDownloadManager.sharedInstance.addQue(video)
        // 메인스레드로 통지안하면 바로바로 갱신이 안됨.
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "changeVideoStatus"), object: nil)
        }
    }
    
    func didFinishDownloadCacheVideo(_ video: NKVideo) {

        // 다운로드 받은 비디오 재정렬 + 디비저장
        if let newCachedVideo = CachedVideo.setCacheDataWithVideo(video) {
            NKOrderManager.sharedInstance.addNewVideo(newCachedVideo, complete: { (isSuccess) in
                
                if isSuccess {
                    NKCoreDataCachedVideo.sharedInstance.updateProperties({
                        
                        // 메인스레드로 통지안하면 바로바로 갱신이 안됨.
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "changeVideoStatus"), object: nil)
                            

                            // 하단에 다운로드 완료 얼럿 표시
                            NKAlertManager.showFinishDownloadAlert(video)

                            // 로컬 다운로드 완료 표시
                            if let title = video.title {
                                NKNotification.sharedInstance.postLocalNotification(title, userInfo: ["videoId": video.videoId!])
                            }
                            
                        }
                    })
                }
            })
        }
    }

    func didRemoveCahceVideo(_ video: VideoProtocol, complete:(_ isSuccess: Bool) -> ()) {
        if let videoId = video.commonId {
            NKCoreDataCachedVideo.sharedInstance.removeCacheVideo(videoId, complete: { (isSuccess) in
                if isSuccess {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "didRemovePlayingVideo"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "changeVideoStatus"), object: nil)
                }
                complete(isSuccess)
            })
        } else {
            complete(false)
        }
    }
    
}
