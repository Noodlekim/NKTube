//
//	ChannelList.swift
//
//	Create by GiBong Kim on 21/5/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class ChannelList : Mappable {

	var etag: String?
	var items : [ChannelItem]?
	var kind : String?
	var nextPageToken : String?
    var regionCode: String?
	var pageInfo : PageInfo?
	var youtube : String?
    
	class func newInstance(map: Map) -> Mappable?{
		return Subscription(map: map)
	}
	required init?(map: Map){ }

	func mapping(map: Map) {
        etag <- map["etag"]
		items <- map["items"]
		kind <- map["kind"]
		nextPageToken <- map["nextPageToken"]
        regionCode <- map["regionCode"]
		pageInfo <- map["pageInfo"]
		youtube <- map["youtube"]
	}
}
