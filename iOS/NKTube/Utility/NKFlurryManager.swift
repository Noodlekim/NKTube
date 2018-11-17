//
//  NKFlurryManager.swift
//  NKTube
//
//  Created by NoodleKim on 2016/07/01.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

protocol NKFlurryManagerProtocol {
    func flurryDictionary() -> [String: String]
}

class NKFlurryManager {

    static let sharedInstance: NKFlurryManager = NKFlurryManager()
    
    /*
     view:MyMenu
     view:PlayerMenu
     view:SearchMenu
     
     // 구체적으로 무슨 기능을 하기 위해서 열었는지 그것까지 파악되면 더 좋을 듯.
     
     view:YoutubeMenu/LoginStep1
     view:YoutubeMenu/LoginStep2
     view:YoutubeMenu/ChannelList
     view:YoutubeMenu/ChannelDetail
     view:YoutubeMenu/WatchAfter
     view:YoutubeMenu/PopularVideos
     view:YoutubeMenu/RecommandVideos
     
     view:Credit
     view:Setting/List
     view:Setting/??
     
     
     action:YouTube/Login
     action:Youtube/Logout
     
     비디오 재생 (타이틀, 화질, 재생시간, 비디오아이디) 타입?
     action:PlayVideo/Cache/MyCacheList
     action:PlayVideo/Cache/YouTubeMenu/Channel
     action:PlayVideo/Cache/YouTubeMenu/WatchAfter
     action:PlayVideo/Cache/YouTubeMenu/Popular
     action:PlayVideo/Cache/CenterRecommand
     action:PlayVideo/Cache/CenterPopular
     action:PlayVideo/Cache/SearchMenu
     
     action:PlayVideo/NoCache/YouTubeMenu/Channel
     action:PlayVideo/NoCache/YouTubeMenu/WatchAfter
     action:PlayVideo/NoCache/YouTubeMenu/Popular
     action:PlayVideo/NoCache/CenterRecommand
     action:PlayVideo/NoCache/CenterPopular
     action:PlayVideo/NoCache/SearchMenu
     
     action:PlayVideo/NoCache/YouTubeMenu/Channel
     action:PlayVideo/NoCache/YouTubeMenu/WatchAfter
     action:PlayVideo/NoCache/YouTubeMenu/Popular
     action:PlayVideo/NoCache/CenterRecommand
     action:PlayVideo/NoCache/CenterPopular
     action:PlayVideo/NoCache/SearchMenu
     
     // 타이틀, 화질, 재생시간, 비디오 아이디, 타입?
     action:Download/YouTubeMenu/Channel
     action:Download/YouTubeMenu/WatchAfter
     action:Download/YouTubeMenu/Popular
     action:Download/CenterRecommand
     action:Download/CenterPopular
     action:Download/SearchMenu
     
     // 검색 (키워드)
     action:Search
     */
    func viewForMyMenu() {
        track("view:MyMenu")
    }
    
    // view:PlayerMenu
    func viewForPlayerMenu() {
        track("view:PlayerMenu")
    }
    
    // view:SearchMenu
    func viewForSearchMenu() {
        track("view:SearchMenu")
    }
    
    // view:YoutubeMenu/Login
    func viewForYouTubeMenuLogin() {
        track("view:YoutubeMenu/Login")
    }
    
    // view:YoutubeMenu/ChannelList
    func viewForYouTubeMenuChannelList() {
        track("view:YoutubeMenu/ChannelList")
    }
    
    // view:YoutubeMenu/ChannelDetail
    func viewForYoutubeMenuChannelDetail() {
        track("view:YoutubeMenu/ChannelDetail")
    }
    
    // view:YoutubeMenu/WatchAfter
    func viewForYoutubeMenuWatchAfter() {
        track("view:YoutubeMenu/WatchAfter")
    }

    // view:YoutubeMenu/PopularVideos
    func viewForYoutubeMenuPopularVideos() {
        track("view:YoutubeMenu/PopularVideos")
    }

    // view:YoutubeMenu/RecommandVideos
    func viewForYoutubeMenuRecommandVideos() {
        track("view:YoutubeMenu/RecommandVideos")
    }
    
    // view:YoutubeMenu/Good
    func viewForYoutubeMenuGood() {
        track("view:YoutubeMenu/Good")
    }


    // view:Credit
    func viewForCredits() {
        track("view:Credit")
    }
    
    // view:Setting/List
    func viewForSettingList() {
        track("view:SettingList")
    }
    
    // view:Setting/List
    func viewForFeedback() {
        track("view:Feedback")
    }

    
    // view:Setting/??
    
    
    // MARK: - Action
    
    // action:Youtube/Login
    func actionForYoutubeLoginSuccess() {
        track("action:Youtube/LoginSuccess")
    }
    
    // action:Youtube/LoginFail
    func actionForYoutubeLoginFailGetToken() {
        track("action:Youtube/LoginFailGetToken")
    }
    
    // action:Youtube/LoginFail
    func actionForYoutubeLoginFailHttpError() {
        track("action:Youtube/LoginFailHttpError")
    }


    // action:Youtube/Logout
    func actionForYoutubeLogout() {
        track("action:Youtube/Logout")
    }
    
    // action:PlayVideo/MyCacheList
    func actionForPlayVideoOnMyCacheList(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/MyCacheList", params: video.flurryDictionary())
    }
    
    // action:PlayVideo/YoutubeMenu/Channel
    func actionForPlayVideoOnYoutubeMenuChannel(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/YoutubeMenu/Channel", params: video.flurryDictionary())
    }

    // action:PlayVideo/YoutubeMenu/WatchAfter
    func actionForPlayVideoOnYoutubeMenuWatchAfter(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/YoutubeMenu/WatchAfter", params: video.flurryDictionary())
    }
    
    // action:PlayVideo/YoutubeMenu/Popular
    func actionForPlayVideoOnYoutubeMenuPopular(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/YoutubeMenu/Popular", params: video.flurryDictionary())
    }
    
    // action:PlayVideo/YoutubeMenu/Recommand
    func actionForPlayVideoOnYoutubeMenuRecommand(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/YoutubeMenu/Recommand", params: video.flurryDictionary())
    }

    // action:PlayVideo/CenterRecommand
    func actionForPlayVideoOnCenterRecommand(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/CenterRecommand", params: video.flurryDictionary())
    }
    
    // action:PlayVideo/CenterPopular
    func actionForPlayVideoOnCenterPopular(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/CenterPopular", params: video.flurryDictionary())
    }
    
    // action:PlayVideo/SearchMenu
    func actionForPlayVideoOnSearchMenu(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/SearchMenu", params: video.flurryDictionary())
    }
    
    // action:PlayVideo/Cache/SearchMenu
    func actionForPlayVideoOnCacheSearchMenu(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/Cache/SearchMenu", params: video.flurryDictionary())
    }

    
    // action:PlayVideo/YouTubeMenu/Good
    func actionForPlayVideoOnYouTubeMenuGood(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/YouTubeMenu/Good", params: video.flurryDictionary())
    }
    
    // action:PlayVideo/AlertView
    func actionForPlayVideoOnAlertview(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/AlertView", params: video.flurryDictionary())
    }

    // action:PlayVideo/Spotlight
    func actionForPlayVideoWithSpotlight(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/Spotlight", params: video.flurryDictionary())
    }

    // action:PlayVideo/LocalNotification
    func actionForPlayVideoWithLocalNotification(_ video: NKFlurryManagerProtocol) {
        track("action:PlayVideo/LocalNotification", params: video.flurryDictionary())
    }

    
    // 타이틀, 화질, 재생시간, 비디오 아이디, 타입?
    // action:Download/YouTubeMenu/Channel
    func actionForDownloadOnYouTubeMenuChannel(_ video: NKFlurryManagerProtocol) {
        track("action:Download/YouTubeMenu/Channel", params: video.flurryDictionary())
    }
    
    // action:Download/YouTubeMenu/WatchAfter
    func actionForDownloadOnYouTubeMenuWatchAfter(_ video: NKFlurryManagerProtocol) {
        track("action:Download/YouTubeMenu/WatchAfter", params: video.flurryDictionary())
    }
    
    // action:Download/YouTubeMenu/Good
    func actionForDownloadOnYouTubeMenuGood(_ video: NKFlurryManagerProtocol) {
        track("action:Download/YouTubeMenu/Good", params: video.flurryDictionary())
    }

    // action:Download/YouTubeMenu/CenterPlayer
    func actionForDownloadOnCenterPlayer(_ video: NKFlurryManagerProtocol) {
        track("action:Download/CenterPlayer", params: video.flurryDictionary())
    }
    
    // action:Download/YouTubeMenu/Popular
    func actionForDownloadOnYouTubeMenuPopular(_ video: NKFlurryManagerProtocol) {
        track("action:Download/YouTubeMenu/Popular", params: video.flurryDictionary())
    }
    
    // action:Download/CenterRecommand
    func actionForDownloadCenterRecommand(_ video: NKFlurryManagerProtocol) {
        track("action:Download/CenterRecommand", params: video.flurryDictionary())
    }
    
    // action:Download/CenterPopular
    func actionForDownloadOnCenterPopular(_ video: NKFlurryManagerProtocol) {
        track("action:Download/CenterPopular", params: video.flurryDictionary())
    }
    
    // action:Download/SearchMenu
    func actionForDownloadOnSearchMenu(_ video: NKFlurryManagerProtocol) {
        track("action:Download/SearchMenu", params: video.flurryDictionary())
    }
    
    // 검색 (키워드)
    // action:Search
    func actionForSearch(_ keyword: String) {
        track("action:Search", params: ["keyword": keyword])
    }
    
    // Feedback
    func actionForFeedback(_ title: String, content: String) {
        track("action:Feedback", params: ["title": title, "content": content])
    }
    
    
    fileprivate func track(_ event: String, params: [String: String]? = nil) {
        if params != nil {
            Flurry.logEvent(event, withParameters: params!)
            KLog("[Event] " + event + ": \(params!)")
        } else {
            Flurry.logEvent(event)
            KLog("[Event] " + event)
        }
    }

}
