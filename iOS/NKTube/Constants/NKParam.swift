//
//  NKParam.swift
//  NKTube
//
//  Created by GibongKim on 2016/02/01.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

struct NKURL {
    static let SearchURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&q="
}

let youTubeAPIKey: String = "AIzaSyBTXM066IdBgr8M6h-zfDB4VDbIDGrF0B0"
let maxResults = "15"

let defaultGroupName: String = "最近ダウンロードした動画"
let clientId = "972534134760-gs90o7lio2gutc528fv4gr0j6ikn4d67.apps.googleusercontent.com"
let scope = "https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/youtube.readonly https://www.googleapis.com/auth/youtubepartner https://www.googleapis.com/auth/youtubepartner-channel-audit https://www.googleapis.com/auth/youtube.upload";
let adUnitID = "ca-app-pub-6328027725562599/7793470065"
//"ca-app-pub-6328027725562599/5597530066"
//ca-app-pub-6328027725562599~3363270461

let baseSpace: CGFloat = 30.0
let aniDuration: TimeInterval = 0.25
let pw = "asjdfpaoiweurp0127uoij"

let inAppItem1 = "com.kktube.item.iap_item1"

let FlurryAPIKey = "HSTH3M93HCDN5YFG32YD"

struct NKKey {
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

struct NKImage {
    static let defaultThumbnail: UIImage = UIImage(named: "background_default_thumb")!
    static let defaultProfile: UIImage = UIImage(named: "test_profile")!
    
}

let apiKey: String = "AIzaSyBTXM066IdBgr8M6h-zfDB4VDbIDGrF0B0"
