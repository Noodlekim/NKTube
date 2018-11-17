//
//  Video.swift
//  YellowTube
//
//  Created by NoodleKim on 2016/02/01.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import ObjectMapper

class Video: NSObject, Mappable, VideoProtocol {
    var commonId: String?    
    
    var caption: String?
    var definition: String?
    var dimension: String?
    var duration: String?
    var licensedContent: String?
    var projection: String?
    
    var etag: String?
    var videoId: String?
    var categoryId: String?
    var channelId: String?
    var channelTitle: String?
    var defaultAudioLanguage: String?
    var descriptions: String? // NSObject의 description과 겹쳐서
    var liveBroadcastContent: String?

    var publishedAt: String?
    var defaultThumb: String?
    var highThumb: String?
    var mediumThumb: String?
    var standardThumb: String?
    var title: String?
    
    var statistics: Statistics?
    var status: VideoStatus?
    
    class func newInstance(map: Map) -> Mappable?{
        return Video(map: map)
    }
    override init() { }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        caption <- map["contentDetails.caption"]
        definition <- map["contentDetails.definition"]
        dimension <- map["contentDetails.dimension"]
        duration <- map["contentDetails.duration"]
        licensedContent <- map["contentDetails.licensedContent"]
        projection <- map["contentDetails.projection"]
        
        etag <- map["etag"]
        videoId <- map["id"]
        
        categoryId <- map["snippet.categoryId"]
        channelId <- map["snippet.channelId"]
        channelTitle <- map["snippet.channelTitle"]
        defaultAudioLanguage <- map["snippet.defaultAudioLanguage"]
        descriptions <- map["snippet.description"]
        liveBroadcastContent <- map["snippet.liveBroadcastContent"]
        
        publishedAt <- map["snippet.publishedAt"]
        etag <- map["etag"]
        defaultThumb <- map["snippet.thumbnails.default.url"]
        highThumb <- map["snippet.thumbnails.high.url"]
        mediumThumb <- map["snippet.thumbnails.medium.url"]
        standardThumb <- map["snippet.thumbnails.standard.url"]
        title <- map["snippet.title"]

        statistics <- map["statistics"]
        status <- map["status"]
    }
    
    class func copyVideo(with favoriteVideo: FavoriteVideo) -> Video {
        let video = Video.init()
        video.videoId = favoriteVideo.videoId
        video.title = favoriteVideo.title
        video.defaultThumb = favoriteVideo.defaultThumb
        video.highThumb = favoriteVideo.highThumb
        video.mediumThumb = favoriteVideo.mediumThumb
        video.standardThumb = favoriteVideo.standardThumb
        video.channelId = favoriteVideo.channelId
        video.channelTitle = favoriteVideo.channelTitle
        video.duration = favoriteVideo.duration
        
        return video
    }
}
