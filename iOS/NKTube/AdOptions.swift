//
//  AdOptions.swift
//  YellowTube
//
//  Created by NoodleKim on 2017. 7. 20..
//  Copyright © 2017년 GibongKim. All rights reserved.
//

import Foundation
//import ObjectMapper

struct AdOptions {

    var relatedViewEnable: Bool = true
    var subscriptionViewEnable: Bool = true
    var likeViewEnable: Bool = true
    var recommendViewEnable: Bool = true
    var popularViewEnable: Bool = true
    var searchViewEnable: Bool = true
    
    var nativeEnable: Bool = true
    var nativeFirstTimeInterval: TimeInterval = 12 * 60 * 60
    var nativeTimeInterval: TimeInterval = 24 * 60 * 60
    var nativeType: String = "admob"

//    var native: AdNative?
    
//    class func newInstance(map: Map) -> Mappable?{
//        return AdOptions(map: map)
//    }
//    required init?(map: Map){ }
//    
//    func mapping(map: Map) {
//        relatedView <- map["banner.related_view.isShow"]
//        subscriptionView <- map["banner.subscription_view.isShow"]
//        likeView <- map["banner.like_view.isShow"]
//        recommendView <- map["banner.recommend_view.isShow"]
//        popularView <- map["banner.popular_view.isShow"]
//        searchView <- map["banner.search_view.isShow"]
//        native <- map["native"]
//    }
}
