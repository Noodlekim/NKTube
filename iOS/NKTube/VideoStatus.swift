//
//  VideoStatus.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 5. 23..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import Foundation
import ObjectMapper

class VideoStatus : Mappable {
    
    var embeddable: String?
    var license : String?
    var privacyStatus : String?
    var publicStatsViewable : String?
    var uploadStatus: String?
    
    class func newInstance(map: Map) -> Mappable?{
        return VideoStatus(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        embeddable <- map["embeddable"]
        license <- map["license"]
        privacyStatus <- map["privacyStatus"]
        publicStatsViewable <- map["publicStatsViewable"]
        uploadStatus <- map["uploadStatus"]
    }
}
