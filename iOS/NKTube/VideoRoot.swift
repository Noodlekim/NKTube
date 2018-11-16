//
//  Videos.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 5. 23..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import Foundation
import ObjectMapper

class VideoRoot: Mappable {
    
    var etag: String?
    var videos: [Video]?
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
