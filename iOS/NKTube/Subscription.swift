//
//	Subscriptions.swift
//
//	Create by GiBong Kim on 21/5/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class Subscription : Mappable {

//	var etag : String?
	var channels : [Channel]?
	var kind : String?
	var nextPageToken : String?
	var pageInfo : PageInfo?
	var youtube : String?
    
	class func newInstance(map: Map) -> Mappable?{
		return Subscription(map: map)
	}
	required init?(map: Map){ }

	func mapping(map: Map) {
		channels <- map["items"]
		kind <- map["kind"]
		nextPageToken <- map["nextPageToken"]
		pageInfo <- map["pageInfo"]
		youtube <- map["youtube"]
	}
}
