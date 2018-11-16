//
//  AdNative.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 7. 20..
//  Copyright © 2017년 GibongKim. All rights reserved.
//

import Foundation
import ObjectMapper

class AdNative : Mappable {
    
    var isShow: Bool? = true
    var firstTimeInterval: TimeInterval?
    var timeInterval: TimeInterval?
    var type: String?
    
    class func newInstance(map: Map) -> Mappable?{
        return AdNative(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        isShow <- map["isShow"]
        firstTimeInterval <- map["first_time_interval"]
        timeInterval <- map["time_interval"]
        type <- map["type"]
    }
}
