//
//  RelatedVideoRoot.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 5. 28..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import Foundation

import ObjectMapper

class RelatedVideoRoot: Mappable {
    
    var etag: String?
    var videos: [RelatedVideo]?
    var kind: String?
    var nextPageToken: String?
    var pageInfo: PageInfo?
    
    class func newInstance(map: Map) -> Mappable?{
        return VideoRoot(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        etag <- map["etag"]
        videos <- map["items"]
        kind <- map["kind"]
        nextPageToken <- map["nextPageToken"]
        pageInfo <- map["pageInfo"]
    }
}
