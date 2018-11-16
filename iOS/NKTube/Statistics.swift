//
//  Statistics.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 5. 23..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import Foundation
import ObjectMapper

/*
statistics = {
    commentCount = 237;
    dislikeCount = 5;
    favoriteCount = 0;
    likeCount = 1250;
    viewCount = 20463;
}
 */
class Statistics : Mappable {
    
    var commentCount: String?
    var dislikeCount : String?
    var favoriteCount : String?
    var likeCount : String?
    var viewCount: String?
    
    class func newInstance(map: Map) -> Mappable?{
        return Statistics(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        commentCount <- map["commentCount"]
        dislikeCount <- map["dislikeCount"]
        favoriteCount <- map["favoriteCount"]
        likeCount <- map["likeCount"]
        viewCount <- map["viewCount"]
    }
}
