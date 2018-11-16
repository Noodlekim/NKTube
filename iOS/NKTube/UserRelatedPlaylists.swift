//
//  UserRelatedPlaylists.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 5. 27..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import Foundation
import ObjectMapper

class UserRelatedPlaylists: Mappable {
    
    var favorites: String?
    var likes: String?
    var uploads: String?
    var watchHistory: String?
    var watchLater: String?
    
    class func newInstance(map: Map) -> Mappable?{
        return UserRelatedPlaylists(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        favorites <- map["items.0.contentDetails.relatedPlaylists.favorites"]
        likes <- map["items.0.contentDetails.relatedPlaylists.likes"]
        uploads <- map["items.0.contentDetails.relatedPlaylists.uploads"]
        watchHistory <- map["items.0.contentDetails.relatedPlaylists.watchHistory"]
        watchLater <- map["items.0.contentDetails.relatedPlaylists.watchLater"]
    }
}

