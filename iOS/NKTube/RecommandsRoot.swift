//
//  RecommandsList.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 5. 27..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import Foundation
import ObjectMapper

class RecommandsRoot: Mappable {
    
    var etag: String?
    var items: [RecommandVideo]?
    var kind: String?
    var nextPageToken: String?
    var pageInfo: PageInfo?
    
    var title: String?
    
    class func newInstance(map: Map) -> Mappable?{
        return RecommandsRoot(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        etag <- map["etag"]
        items <- map["items"]
        kind <- map["kind"]
        nextPageToken <- map["nextPageToken"]
        pageInfo <- map["pageInfo"]
        
    }    
}
