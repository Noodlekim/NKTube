//
//  AuthResults.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 6. 7..
//  Copyright © 2017년 NoodleKim. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthResults : Mappable {
    
    /// 액서스 토큰
    var access_token : String?
    /// 만료
    var expires_in : Int?
    /// 토큰 타입
    var token_type: String?
    
    class func newInstance(map: Map) -> Mappable? {
        return AuthResults(map: map)
    }
    required init?(map: Map){ }
    
    func mapping(map: Map)
    {
        access_token <- map["access_token"]
        expires_in <- map["expires_in"]
        token_type <- map["token_type"]
    }
}
