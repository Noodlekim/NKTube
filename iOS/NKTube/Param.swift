//
//  NKParam.swift
//  YellowTube
//
//  Created by NoodleKim on 2016/02/01.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit


struct Key {
//    static let Title: String = "title"
    // items
    static let Items: String = "items"
    static let Id: String = "id"
    static let Recommendation = "recommendation"
    static let Upload = "upload"
    static let ResourceId: String = "resourceId"
    static let VideoId: String = "videoId"
    static let Snippet: String = "snippet"
    static let Title: String = "title"
    static let Description: String = "description"
    
    // thumbnails
    static let Thumbnails: String = "thumbnails"
    static let Default: String = "default"
    static let Medium: String = "medium"
    static let High: String = "high"
    static let Standard: String = "standard"
    static let Maxres: String = "maxres"
    static let Url: String = "url"
    static let ChannelId = "channelId"
    static let ChannelTitle: String = "channelTitle"
    // statistics
    static let Statistics: String = "statistics"
    static let ViewCount: String = "viewCount"
    static let LikeCount: String = "likeCount"
    static let DislikeCount: String = "dislikeCount"
    static let FavoriteCount: String = "favoriteCount"
    static let CommentCount: String = "commentCount"
    
    // player
    static let Player: String = "player"
    static let EmbedHtml: String = "embedHtml"
    
    // contentDetails
    static let ContentDetails: String = "contentDetails"
    static let Duration: String = "duration"
    static let License: String = "license"
    static let PrivacyStatus: String = "privacyStatus"
    static let PublicStatsViewable: String = "publicStatsViewable"
    static let Definition: String = "definition"
    
    static let Dimension: String = "dimension"
    static let Caption: String = "caption"
    static let LicensedContent: String = "licensedContent"
}

struct Image {
    static let defaultThumbnail: UIImage = UIImage()
    static let defaultProfile: UIImage = UIImage()//R.image.test_profile()! // TODO: 이미지 교체
    
}
