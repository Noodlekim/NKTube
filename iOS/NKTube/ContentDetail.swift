//
//	ContentDetail.swift
//
//	Create by GiBong Kim on 21/5/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class ContentDetail : NSObject, NSCoding, Mappable{

	var activityType : String?
	var newItemCount : Int?
	var totalItemCount : Int?


	class func newInstance(map: Map) -> Mappable?{
		return ContentDetail()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		activityType <- map["activityType"]
		newItemCount <- map["newItemCount"]
		totalItemCount <- map["totalItemCount"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         activityType = aDecoder.decodeObject(forKey: "activityType") as? String
         newItemCount = aDecoder.decodeObject(forKey: "newItemCount") as? Int
         totalItemCount = aDecoder.decodeObject(forKey: "totalItemCount") as? Int

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if activityType != nil{
			aCoder.encode(activityType, forKey: "activityType")
		}
		if newItemCount != nil{
			aCoder.encode(newItemCount, forKey: "newItemCount")
		}
		if totalItemCount != nil{
			aCoder.encode(totalItemCount, forKey: "totalItemCount")
		}

	}

}