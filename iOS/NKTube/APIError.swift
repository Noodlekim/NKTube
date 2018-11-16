//
//  APIError.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 6. 7..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import Foundation
import ObjectMapper

public class APIError : Mappable {
    
    /// 에러코드
    var code : Int?
    /// 도메인
    var domain : String?
    /// 로케이션
    var location: String?
    /// 로케이션타이프
    var locationType : String?
    /// 썸네일 default
    var message: String?
    /// 썸네일 medium
    var reason: String?
    
    class public func newInstance(map: Map) -> Mappable? {
        return APIError(map: map)
    }
    required public init?(map: Map){ }
    
    public func mapping(map: Map)
    {
        code <- map["error.code"]
        domain <- map["error.errors.0.domain"]
        location <- map["error.errors.0.location"]
        locationType <- map["error.errors.0.locationType"]
        message <- map["error.errors.0.message"]
        reason <- map["error.errors.0.reason"]
    }
}
