//
//  FavoriteVideo.swift
//  YellowTube
//
//  Created by NoodleKim on 2017/06/02.
//  Copyright © 2017年 NoodleKim. All rights reserved.
//

import Foundation

/**
 
 */
class FavoriteVideo: VideoProtocol {
    var commonId: String?
    
    @objc dynamic var videoId: String?
    @objc dynamic var order: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var defaultThumb: String?
    @objc dynamic var highThumb: String?
    @objc dynamic var mediumThumb: String?
    @objc dynamic var standardThumb: String?
    @objc dynamic var channelId: String?
    @objc dynamic var channelTitle: String?
    @objc dynamic var createAt: NSDate?
    @objc dynamic var uniqueId: String?
    @objc dynamic var duration: String?

    
    convenience required init(video: Video) {
        self.init()
        
        self.videoId = video.videoId
        self.order = 0
        self.title = video.title
        self.defaultThumb = video.defaultThumb
        self.highThumb = video.highThumb
        self.mediumThumb = video.mediumThumb
        self.standardThumb = video.standardThumb
        self.channelId = video.channelId
        self.channelTitle = video.channelTitle
        self.createAt = NSDate.init()
        self.uniqueId = ""
        self.duration = video.duration
    }

    convenience required init(favoriteVideo: FavoriteVideo) {
        self.init()
        
        self.videoId = favoriteVideo.videoId
        self.order = favoriteVideo.order
        self.title = favoriteVideo.title
        self.defaultThumb = favoriteVideo.defaultThumb
        self.highThumb = favoriteVideo.highThumb
        self.mediumThumb = favoriteVideo.mediumThumb
        self.standardThumb = favoriteVideo.standardThumb
        self.channelId = favoriteVideo.channelId
        self.channelTitle = favoriteVideo.channelTitle
        self.createAt = NSDate.init()
        self.uniqueId = "" //\(NSDate.init().timeIntervalSince1970)" + "\(+RealmManager.shared.totalVideoListCount + 1)"
        self.duration = favoriteVideo.duration
    }

//    override class func primaryKey() -> String? {
//        return "uniqueId"
//    }

//    class func copyVideo() -> Video {
////        Video.
//    }
    // MEMO: 선택한 영상 + 영상 관련 설명쪽을 매번 fetch안하고 할꺼면 이정도는 취득하는 걸로..
    
}

