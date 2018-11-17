//
//  NKVideo.swift
//  NKTube
//
//  Created by NoodleKim on 2016/02/01.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKVideo: NSObject, VideoProtocol {
    
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
    
    override init() {
        
    }
    
    init(_ video: Video) {
        
        self.videoId = video.videoId
        self.title = video.title
        self.videoDescription = video.descriptions
        self.channelId = video.channelId
        self.channelTitle = video.channelTitle
        self.viewCount = video.statistics?.viewCount
        self.likeCount = video.statistics?.likeCount
        self.dislikeCount = video.statistics?.dislikeCount
        self.favoriteCount = video.statistics?.favoriteCount
        self.commentCount = video.statistics?.commentCount
        self.embedHtml = video.status?.embeddable // ?
        self.duration = video.duration
        self.thumbDefault = video.defaultThumb
        self.thumbMedium = video.mediumThumb
        self.thumbHigh = video.highThumb
        self.thumbStandard = video.standardThumb
//        self.thumbMaxres = ??
//        var channelThumbDefault: String?
//        var channelThumbMedium: String?
//        var channelThumbHigh: String?

        self.videoQulity = video.status?.uploadStatus
        self.license = video.status?.license
        /*
         var embeddable: String?
         var license : String?
         var privacyStatus : String?
         var publicStatsViewable : String?
         var uploadStatus: String?

         */
        self.privacyStatus = video.status?.privacyStatus
//        self.publicStatsViewable = NSNumber.init(value: video.status!.publicStatsViewable == "1")
        self.definition = video.definition
//        self.binaryData =
    }    
}
