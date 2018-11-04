//
//  NKVideo.swift
//  NKTube
//
//  Created by GibongKim on 2016/02/01.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKVideo: NSObject, VideoProtocol, NKFlurryManagerProtocol {
    
    var commonId: String? {
        get {
            return videoId
        }
    }

    
    var videoId: String?
    var title: String?
    var videoDescription: String?
    var channelId: String?
    var channelTitle: String?
    var viewCount: String?
    var likeCount: String?
    var dislikeCount: String?
    var favoriteCount: String?
    var commentCount: String?
    var embedHtml: String?
    
    var duration: String?
    
    var thumbDefault: String?
    var thumbMedium: String?
    var thumbHigh: String?
    var thumbStandard: String?
    var thumbMaxres: String?
    
    var channelThumbDefault: String?
    var channelThumbMedium: String?
    var channelThumbHigh: String?
    
    var cachedPercentage: CGFloat = 0
    var indexPath: IndexPath?
    var videoQulity: String?
    var license: String?
    var privacyStatus: String?
    var publicStatsViewable: NSNumber?
    var definition: String?
    var binaryData: Data?
    
    
    func flurryDictionary() -> [String: String] {
        // isCached? title, qulity, playTime, videoId
        var param: [String: String] = [:]
        let isCachedVideo = NKFileManager.checkCachedVideo(self.videoId!)
        param["isCached"] = isCachedVideo ? "YES" : "NO"
        
        if let videoId = self.videoId {
            param["videoId"] = videoId
        }
        if let title = self.title {
            param["title"] = title
        }
        if let qulity = self.videoQulity {
            param["qulity"] = qulity
        }
        
        if let playTime = self.duration {
            param["playTime"] = playTime
        }
        return param
    }
}
