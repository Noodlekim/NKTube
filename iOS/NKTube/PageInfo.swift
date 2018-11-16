//
//	PageInfo.swift
//
//	Create by GiBong Kim on 21/5/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper

class PageInfo : NSObject, NSCoding, Mappable{

	var resultsPerPage : Int?
	var totalResults : Int?


	class func newInstance(map: Map) -> Mappable?{
		return PageInfo()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		resultsPerPage <- map["resultsPerPage"]
		totalResults <- map["totalResults"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         resultsPerPage = aDecoder.decodeObject(forKey: "resultsPerPage") as? Int
         totalResults = aDecoder.decodeObject(forKey: "totalResults") as? Int

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if resultsPerPage != nil{
			aCoder.encode(resultsPerPage, forKey: "resultsPerPage")
		}
		if totalResults != nil{
			aCoder.encode(totalResults, forKey: "totalResults")
		}

	}

}