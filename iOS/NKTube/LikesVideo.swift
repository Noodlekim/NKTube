//
//  LikesVideo.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 5. 27..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import UIKit
import ObjectMapper

class LikesVideo: Mappable /*, // FlurryManagerProtocol*/ {
    
    var etag: String?
    var id: String?
    var videoId: String?
    var channelId: String?
    var channelTitle: String?
    var description: String?
    
    var playlistId: String?
    var position: String?
    var kind: String?
    
    var publishedAt: String?
    var defaultThumb: String?
    var highThumb: String?
    var mediumThumb: String?
    var standardThumb: String?
    
    var title: String?
    
    class func newInstance(map: Map) -> Mappable?{
        return LikesVideo(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        etag <- map["etag"]
        id <- map["id"]
        videoId <- map["contentDetails.videoId"]
        publishedAt <- map["contentDetails.videoPublishedAt"]
        channelId <- map["snippet.channelId"]
        channelTitle <- map["snippet.channelTitle"]
        description <- map["snippet.description"]
        
        playlistId <- map["snippet.playlistId"]
        position <- map["snippet.position"]
        kind <- map["snippet.resourceId.kind"]
        
        defaultThumb <- map["snippet.thumbnails.default.url"]
        highThumb <- map["snippet.thumbnails.high.url"]
        mediumThumb <- map["snippet.thumbnails.medium.url"]
        standardThumb <- map["snippet.thumbnails.standard.url"]
        title <- map["snippet.title"]
    }
    
}
