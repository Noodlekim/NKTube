//
//  RecommandVideo.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 5. 27..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import Foundation

import UIKit
import ObjectMapper

class RecommandVideo: Mappable {
    
    var videoId: String?
    
    class func newInstance(map: Map) -> Mappable?{
        return RecommandVideo(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        videoId <- map["contentDetails.upload.videoId"]
    }
}
