//
//  RelatedVideo.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 5. 28..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import UIKit
import ObjectMapper

class RelatedVideo: Mappable {
    
    var videoId: String?
    
    var title: String?
    
    class func newInstance(map: Map) -> Mappable?{
        return RelatedVideo(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        videoId <- map["id.videoId"]
    }
}

