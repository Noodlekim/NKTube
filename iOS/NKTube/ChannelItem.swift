//
//	ChannelItem.swift
//
//	Create by GiBong Kim on 21/5/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class ChannelItem : Mappable {

    /// 채널아이디
	var channelId : String?
    // 비디오아이디
    var videoId : String?
    /// 타이틀
    var title : String?
    /// 채널 개요
    var description: String?
    /// 발행일
	var publishedAt : String?
    /// 썸네일 default
    var defaultThumb: String?
    /// 썸네일 medium
    var mediumThumb: String?
    /// 써멘일 high
    var highThumb: String?
    var liveBroadcastContent: String?

	class func newInstance(map: Map) -> Mappable? {
		return Channel(map: map)
	}
	required init?(map: Map){ }

	func mapping(map: Map)
	{
		channelId <- map["snippet.resourceId.channelId"]
        videoId <- map["id.videoId"]
        title <- map["snippet.title"]
        description <- map["snippet.description"]
		publishedAt <- map["snippet.publishedAt"]
        defaultThumb <- map["snippet.thumbnails.default.url"] // 120x90
        mediumThumb <- map["snippet.thumbnails.medium.url"] // 320x180
        highThumb <- map["snippet.thumbnails.high.url"] // 480 x 360
	}
}
