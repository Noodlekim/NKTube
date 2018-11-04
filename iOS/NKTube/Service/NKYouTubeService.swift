//
//  NKYouTubeService.swift
//  NKTube
//
//  Created by GibongKim on 2016/01/17.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import Alamofire
import XCDYouTubeKit
import CoreData
import RNCryptor

//https://www.googleapis.com/youtube/v3/search?part=snippet&q=%EC%98%A4%EB%A0%8C%EC%A7%80%EC%B9%B4%EB%9D%BC%EB%A9%9C&key={YOUR_API_KEY}
class NKYouTubeService: NSObject {
    
    var streamData: NSMutableData?
    var pageToken: String?
    var downloadRequest: Request?
    var downloadingVideo: NKVideo?
    
    static var sharedInstance = NKYouTubeService()
    
    fileprivate lazy var backgroundManager: SessionManager = {
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.kjcode.kktube")
        return Alamofire.SessionManager(configuration: configuration)

    }()
    
    var backgroundCompletionHandler: (() -> Void)? {
        get {
            return backgroundManager.backgroundCompletionHandler
        }
        set {
            backgroundManager.backgroundCompletionHandler = newValue
        }
    }

    
    // MARK: ## 리퀘스트 ##
    // MARK: 유투브 키워드로 VideoId들 요청
    // TODO: 페이징 처리 필요.
    func getChannelSections(_ channelId: String, nextPageToken: String? = nil, complete: @escaping (_ videos: [NKVideo], _ nextPageToken: String?, _ error: NSError?, _ canPaging: Bool) -> Void) {

        var url: String = "https://www.googleapis.com/youtube/v3/search?&channelId="+channelId+"&part=snippet,id&order=date&maxResults="+maxResults+"&key="+youTubeAPIKey
        if let nextPageToken = nextPageToken  {
            url = url + "&pageToken=" + nextPageToken
        }

        Alamofire.request(url).responseJSON { (response) -> Void in
            KLog("JSON \(response.result.value)")
            
            var canPaging: Bool = true
            if let data = response.result.value as? Dictionary<String, AnyObject> {
                
                let videoIds = self.parserWithSearchedData(data)
                
                let nextPageToken: String? = data["nextPageToken"] as? String
                // nextPageToken이 있어도 더이상 없는 경우가 있음.
                if let pageInfo = data["pageInfo"] as? Dictionary<String, Any>, let perPage = pageInfo["totalResults"] as? Int{
                    if Int(maxResults)! > perPage {
                        canPaging = false
                    }
                }
                
                self.getVideoDetailLists(videoIds, complete: { (videos, detailError) -> Void in
                    complete(videos, nextPageToken, detailError, canPaging)
                })
            } else {
                complete([], nil, NSError(domain: "Fail to get video detail data", code: 1999, userInfo: nil), canPaging)
            }

        }
        
    }

    // 나중에 보기
    // TODO: 페이징 처리 필요.
    func getWatchLater(_ accessToken: String, playlistId: String, nextPageToken: String? = nil, completion: @escaping (_ videos: [NKVideo], _ nextPageToken: String?, _ error: NSError?, _ canPaging: Bool) -> Void) {

        var url: String = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults="+maxResults+"&playlistId="+playlistId+"&key="+youTubeAPIKey
        if let nextPageToken = nextPageToken  {
            url = url + "&pageToken=" + nextPageToken
        }

        let accessToken = "Bearer \(accessToken)"        
        Alamofire.request(url, headers: ["Authorization": accessToken]).responseJSON { (response) -> Void in
            KLog("JSON \(response.result.value)")
            
            var canPaging: Bool = true

            if let data = response.result.value as? Dictionary<String, AnyObject> {
                let videoIds = self.parserFromMyYouTubeList(data)
                let nextPageToken: String? = data["nextPageToken"] as? String
                if let pageInfo = data["pageInfo"] as? Dictionary<String, Any>, let perPage = pageInfo["totalResults"] as? Int{
                    if Int(maxResults)! > perPage {
                        canPaging = false
                    }
                }

                self.getVideoDetailLists(videoIds, complete: { (videos, detailError) -> Void in
                    completion(videos, nextPageToken, detailError, canPaging)
                })
            } else {
                completion([], nil, NSError(domain: "Fail to get video detail data", code: 1999, userInfo: nil), canPaging)
            }
        }

    }
    
    // MARK: - 추천, 인기 영상
    // TODO: 페이징 처리 필요.
    func getRecommandVideos(_ accessToken: String, nextPageToken: String? = nil, completion: @escaping (_ videos: [NKVideo], _ nextPageToken: String?, _ error: NSError?, _ canPaging: Bool) -> Void) {
        
        var url: String = "https://www.googleapis.com/youtube/v3/activities?part=id,snippet,contentDetails&home=true&key="+youTubeAPIKey+"&maxResults="+maxResults
        if let nextPageToken = nextPageToken  {
            url = url + "&pageToken=" + nextPageToken
        }

        let accessToken = "Bearer \(accessToken)"
        Alamofire.request(url, headers: ["Authorization": accessToken]).responseJSON { (response) -> Void in
            KLog("Recommand JSON \(response.result.value)")
            
            var canPaging: Bool = true

            if let data = response.result.value as? Dictionary<String, AnyObject> {
                let videoIds = self.parserWithRecommandedData(data)
                let nextPageToken: String? = data["nextPageToken"] as? String
                if let pageInfo = data["pageInfo"] as? Dictionary<String, Any>, let perPage = pageInfo["totalResults"] as? Int{
                    if Int(maxResults)! > perPage {
                        canPaging = false
                    }
                }

                self.getVideoDetailLists(videoIds, complete: { (videos, detailError) -> Void in
                    completion(videos, nextPageToken, detailError, canPaging)
                })
            } else {
                completion([], nil, NSError(domain: "Fail to get video detail data", code: 1999, userInfo: nil), canPaging)
            }
        }
        
    }
    
    // TODO: 페이징 처리 필요.
    func getPopularVideos(_ nextPageToken: String? = nil, completion: @escaping (_ videos: [NKVideo], _ nextPageToken: String?, _ error: NSError?, _ canPaging: Bool) -> Void) {
        
        // https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&key=AIzaSyBTXM066IdBgr8M6h-zfDB4VDbIDGrF0B0&part=snippet&maxResults=4
        var url: String = "https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&key="+youTubeAPIKey+"&part=snippet&regionCode=jp&maxResults="+maxResults
        if let nextPageToken = nextPageToken  {
            url = url + "&pageToken=" + nextPageToken
        }

        Alamofire.request(url).responseJSON { (response) -> Void in
            KLog("Popular videos JSON \(response.result.value)")
            var canPaging: Bool = true

            if let data = response.result.value as? Dictionary<String, AnyObject> {
                let videoIds = self.parserWithMostPopularData(data)
                let nextPageToken: String? = data["nextPageToken"] as? String
                if let pageInfo = data["pageInfo"] as? Dictionary<String, Any>, let perPage = pageInfo["totalResults"] as? Int{
                    if Int(maxResults)! > perPage {
                        canPaging = false
                    }
                }

                self.getVideoDetailLists(videoIds, complete: { (videos, detailError) -> Void in
                    completion(videos, nextPageToken, detailError, canPaging)
                })
            } else {
                completion([], nil, NSError(domain: "Fail to get video detail data", code: 1999, userInfo: nil), canPaging)
            }
        }        
    }

    
    
    func getUserInfo(_ accessToken: String) {
        let url: String = "https://www.googleapis.com/youtube/v3/channels?part=id,snippet,auditDetails,brandingSettings,contentDetails,invideoPromotion,statistics,status,topicDetails&mine=true&mySubscribers=true&key="+youTubeAPIKey

        let accessToken = "Bearer \(accessToken)"
        Alamofire.request(url, headers: ["Authorization": accessToken]).responseJSON { (response) -> Void in
            KLog("JSON \(response.result.value)")

        }

    }
    
    func getVideoIdWithKeyword(_ keyword: String, nextPageToken: String? = nil, complete: @escaping (_ videos: [NKVideo], _ nextPageToken: String?, _ error: NSError?, _ canPaging: Bool) -> Void) {
        
        var url: String = "https://www.googleapis.com/youtube/v3/search?part=snippet&q="+keyword+"&key="+youTubeAPIKey+"&maxResults="+maxResults+"&type=video"
        if let nextPageToken = nextPageToken  {
            url = url + "&pageToken=" + nextPageToken
        }
        
        if let url = url.addingPercentEscapes(using: String.Encoding.utf8) {
            //        if let url = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
            Alamofire.request(url).responseJSON { (response) -> Void in
                if let error = response.result.error {
                    KLog("request error \(error)")
                    complete([], nil, error as NSError?, false)
                } else {
                    KLog("JSON \(response.result.value)")
                    
                    var canPaging: Bool = true
                    if let data = response.result.value as? Dictionary<String, AnyObject> {
                        
                        let nextPageToken: String? = data["nextPageToken"] as? String
                        if let pageInfo = data["pageInfo"] as? Dictionary<String, Any>, let perPage = pageInfo["totalResults"] as? Int{
                            if Int(maxResults)! > perPage {
                                canPaging = false
                            }
                        }
                        
                        let videoIds = self.parserWithSearchedData(data)
                        
                        self.getVideoDetailLists(videoIds, complete: { (videos, detailError) -> Void in
                            
                            complete(videos, nextPageToken, detailError, canPaging)
                        })
                    } else {
                        complete([], nil, NSError(domain: "Fail to get video detail data", code: 1999, userInfo: nil), canPaging)
                    }
                    
                }
            }
        }
    }
    
    
    // MARK: 관련 영상 가져오기
    func getRelatedVideoIds(_ videoId: String, nextPage: String?, complete: @escaping (_ videos: [NKVideo]?, _ pageToken: String?, _ error: NSError?, _ canPaging: Bool) -> Void) {
        
        var url: String = "https://www.googleapis.com/youtube/v3/search?part=snippet&relatedToVideoId="+videoId+"&type=video&key="+youTubeAPIKey+"&maxResults="+maxResults
        if let nextPageToken = nextPage {
            url = url + "&pageToken=" + nextPageToken
        }
        
        if let url = url.addingPercentEscapes(using: String.Encoding.utf8) {
            Alamofire.request(url).responseJSON { (response) -> Void in
                if let error = response.result.error {
                    KLog("request error \(error)")
                    complete(nil, nil, error as NSError?, false)
                } else {
                    KLog("JSON \(response.result.value)")
                    
                    var canPaging: Bool = true
                    if let data = response.result.value as? Dictionary<String, AnyObject> {
                        
                        let nextPage: String? = data["nextPageToken"] as? String
                        if let pageInfo = data["pageInfo"] as? Dictionary<String, Any>, let perPage = pageInfo["totalResults"] as? Int{
                            if Int(maxResults)! > perPage {
                                canPaging = false
                            }
                        }
                        let videoIds = self.parserWithSearchedData(data)
                        self.getVideoDetailLists(videoIds, complete: { (videos, detailError) -> Void in
                            complete(videos, nextPage, detailError, canPaging)
                        })
                    } else {
                        complete([], nil, nil, false)
                    }
                }
            }
        }
    }
    
    
    
    
    // MARK: 유투브 상세 리스트 요청 (videoIds)
    func getVideoDetailLists(_ videoIds: [String], complete: @escaping (_ videos: [NKVideo], _ detailError: NSError?) -> Void) {
        
        let paramVideoIds = videoIds.joined(separator: ",")
        KLog("paramVideoIds >> \(paramVideoIds)")
        
        let url: String = "https://www.googleapis.com/youtube/v3/videos?part=snippet%2C+contentDetails%2C+status%2C+statistics&id="+paramVideoIds+"&key="+youTubeAPIKey
        
//        KLog("videoDetail url >> \(url)")
        Alamofire.request(url).responseJSON { (response) -> Void in
            if let error = response.result.error {
                KLog("request error \(error)")
                complete([], error as NSError?)
            } else {
                KLog("JSON \(response.result.value)")
                
                if let data = response.result.value as? Dictionary<String, AnyObject> {
                    
                    let videos = self.parserWithVideoDetailData(data)
                    complete(videos, nil)
                } else {
                    complete([], nil)
                }
            }
        }
    }
    
    fileprivate func parserWithRecommandedData(_ searchedData: Dictionary<String, AnyObject>) -> [String] {
        
        var videoIds: [String] = []
        if let items = searchedData[NKKey.Items] as? [Dictionary<String, Any>] {
            for item in items {
                
                if let contentDetails = item[NKKey.ContentDetails] as? Dictionary<String, Any> {
                    
                    // おすすめ動画
                    if let recommendation = contentDetails[NKKey.Recommendation] as? Dictionary<String, AnyObject> {
                        
                        if let itemId = recommendation[NKKey.ResourceId] as? Dictionary<String, AnyObject> {
                            
                            if let videoId = itemId[NKKey.VideoId] as? String {
                                videoIds.append(videoId)
                            }
                        }
                    }
                    
                    // 最近アップロードされた動画
                    if let upload = contentDetails[NKKey.Upload] as? Dictionary<String, AnyObject> {
                        
                        if let videoId = upload[NKKey.VideoId] as? String {
                            videoIds.append(videoId)
                        }
                    }
                }
            }
        }
        
        KLog("videoIds >> \(videoIds)")
        return videoIds
    }
    
    fileprivate func parserWithMostPopularData(_ searchedData: Dictionary<String, AnyObject>) -> [String] {
        
        var videoIds: [String] = []
        if let items = searchedData[NKKey.Items] as? [Dictionary<String, Any>] {
            
            for item in items {
                
                if let videoId = item[NKKey.Id] as? String {
                    videoIds.append(videoId)
                }
            }
        }
        
        KLog("videoIds >> \(videoIds)")
        return videoIds
    }

    
    // 유투브의 스트림 URL을 다운받기 위한...
    func getStreamURLWithVideoId(_ videoId: String?, quality: NSNumber, complete: @escaping (_ streamURL: URL?) -> Void) {
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId) { (video, error) -> Void in
            if error != nil {
                complete(nil)
                return
            }
            if let video = video {
                let urls: [NSObject : URL] = video.streamURLs as [NSObject : URL]
                if let url = urls[quality] {
                    complete(url)
                } else {
                    // 선택한 해상도의 URL이 없으면 그 아래껄로 다운
                    if let url = urls[NKVideoQulity.Medium360] {
                        complete(url)
                    } else {
                        if let url = urls[NKVideoQulity.Small240] {
                            complete(url)
                        }
                    }                    
                    complete(nil)
                    
                }
            } else {
                complete(nil)
            }
        }
    }
    
    func getChannelThumbInfo(_ video: NKVideo) {
        if let channelId = video.channelId {
            let url: String = "https://www.googleapis.com/youtube/v3/channels?part=snippet&id="+channelId+"&fields=items%2Fsnippet%2Fthumbnails&key="+youTubeAPIKey
            
            Alamofire.request(url).responseJSON { (response) -> Void in
                KLog("JSON \(response.result.value)")
                if let data = response.result.value as? Dictionary<String, AnyObject> {
                    self.parserFromChannelThumbData(data, video: video)
                }
            }
        }
    }


    // MARK: - ## 데이터 파싱 ##
    // MARK: 검색된 JSON데이터 파싱
    fileprivate func parserWithSearchedData(_ searchedData: Dictionary<String, AnyObject>) -> [String] {
        
        var videoIds: [String] = []
        if let items = searchedData[NKKey.Items] as? [Dictionary<String, Any>] {
            
            for item in items {
                
                if let itemId = item[NKKey.Id] as? Dictionary<String, AnyObject> {
                    
                    if let videoId = itemId[NKKey.VideoId] as? String {
                        videoIds.append(videoId)
                    }
                }
            }
        }
        
        KLog("videoIds >> \(videoIds)")
        return videoIds
    }
    
    fileprivate func parserFromMyYouTubeList(_ myData: Dictionary<String, AnyObject>) -> [String] {
        
        var videoIds: [String] = []
        if let items = myData[NKKey.Items] as? [Dictionary<String, Any>] {
            
            for item in items {
                
                if let snippet = item[NKKey.Snippet] as? Dictionary<String, AnyObject> {
                    
                    if let itemId = snippet[NKKey.ResourceId] as? Dictionary<String, AnyObject> {
                        
                        if let videoId = itemId[NKKey.VideoId] as? String {
                            videoIds.append(videoId)
                        }
                    }
                }
            }
        }
        
        KLog("videoIds >> \(videoIds)")
        return videoIds
    }

    // MARK: - 유투브 채널 썸네일 파싱
    fileprivate func parserFromChannelThumbData(_ thumbData: Dictionary<String, AnyObject>, video: NKVideo) {
        
        if let items = thumbData[NKKey.Items] as? [Dictionary<String, Any>] {
            
            for item in items {
                
                if let snippet = item[NKKey.Snippet] as? Dictionary<String, AnyObject> {
                    
                    // thumbnails
                    if let thumbnails = snippet[NKKey.Thumbnails] as? Dictionary<String, AnyObject> {
                        
                        if let thumbDefault = thumbnails[NKKey.Default] as? Dictionary<String, Any>, let thumb = thumbDefault[NKKey.Url] as? String {
                            video.channelThumbDefault = thumb
                        }
                        if let thumbMedium = thumbnails[NKKey.Medium] as? Dictionary<String, Any>, let thumb = thumbMedium[NKKey.Url] as? String {
                            video.channelThumbHigh = thumb
                        }
                        if let thumbHigh = thumbnails[NKKey.High] as? Dictionary<String, Any>, let thumb = thumbHigh[NKKey.Url] as? String {
                            video.channelThumbHigh = thumb
                        }
                    }
                }
            }
        }
    }

    
    
    // MARK: 유투브 상세데이터 파싱
    fileprivate func parserWithVideoDetailData(_ videoDetailDatas: Dictionary<String, AnyObject>) -> [NKVideo] {
        
        var videoObjects: [NKVideo] = []
        if let items = videoDetailDatas[NKKey.Items] as? [Dictionary<String, Any>] {
            
            for item in items {
                
                let video = NKVideo()
                
                if let item = item as? Dictionary<String, AnyObject> {
                    
                    // common
                    if let id = item[NKKey.Id] as? String {
                        video.videoId = id
                    }
                    
                    
                    // statistics
                    if let statistics = item[NKKey.Statistics]  as? Dictionary<String, AnyObject> {
                        
                        if let viewCount = statistics[NKKey.ViewCount] as? String {
                            video.viewCount = viewCount
                        }
                        if let likeCount = statistics[NKKey.LikeCount] as? String {
                            video.likeCount = likeCount
                        }
                        if let dislikeCount = statistics[NKKey.DislikeCount] as? String {
                            video.dislikeCount = dislikeCount
                        }
                        if let favoriteCount = statistics[NKKey.FavoriteCount] as? String {
                            video.favoriteCount = favoriteCount
                        }
                        if let commentCount = statistics[NKKey.CommentCount] as? String {
                            video.commentCount = commentCount
                        }
                    }
                    
                    // player
                    if let player = item[NKKey.Player] as? Dictionary<String, AnyObject> {
                        if let embedHtml = player[NKKey.EmbedHtml] as? String {
                            video.embedHtml = embedHtml
                        }
                    }
                    
                    // snippet
                    if let snippet = item[NKKey.Snippet] as? Dictionary<String, AnyObject> {
                        
                        if let title = snippet[NKKey.Title] as? String {
                            video.title = title
                        }
                        
                        if let description = snippet[NKKey.Description] as? String {
                            video.videoDescription = description
                        }
                        
                        if let channelId = snippet[NKKey.ChannelId] as? String {
                            video.channelId = channelId
                            // 채널 썸네일만 따로 취득
                            self.getChannelThumbInfo(video)
                        }
                        
                        if let channelTitle = snippet[NKKey.ChannelTitle] as? String {
                            video.channelTitle = channelTitle
                        }

                        
                        // thumbnails
                        if let thumbnails = snippet[NKKey.Thumbnails] as? Dictionary<String, AnyObject> {
                            
                            if let thumbDefault = thumbnails[NKKey.Default] as? Dictionary<String, Any>, let thumb = thumbDefault[NKKey.Url] as? String {
                                
                                video.thumbDefault = thumb
                            }
                            if let thumbMedium = thumbnails[NKKey.Medium] as? Dictionary<String, Any>, let thumb = thumbMedium[NKKey.Url] as? String {
                                
                                video.thumbMedium = thumb
                            }
                            if let thumbHigh = thumbnails[NKKey.High] as? Dictionary<String, Any>, let thumb = thumbHigh[NKKey.Url] as? String {
                                
                                video.thumbHigh = thumb
                            }
                            if let thumbStandard = thumbnails[NKKey.Standard] as? Dictionary<String, Any> {
                                
                                video.thumbStandard = thumbStandard[NKKey.Url] as? String
                            }
                            if let thumbMaxres = thumbnails[NKKey.Maxres] as? Dictionary<String, Any> {
                                
                                video.thumbMaxres = thumbMaxres[NKKey.Url] as? String
                            }
                        }
                    }
                    
                    
                    // contentDetails
                    if let contentDetails = item[NKKey.ContentDetails] as? Dictionary<String, AnyObject> {
                        if let duration = contentDetails[NKKey.Duration] as? String {
                            video.duration = duration
                        }
                        // 라이센스: 보통은 youtube
                        if let license = contentDetails[NKKey.License] as? String {
                            video.license = license
                        }
                        if let privacyStatus = contentDetails[NKKey.PrivacyStatus] as? String {
                            video.privacyStatus = privacyStatus
                        }
                        if let publicStatsViewable = contentDetails[NKKey.PublicStatsViewable] as? NSNumber {
                            video.publicStatsViewable = publicStatsViewable
                        }
                        // 화질
                        if let definition = contentDetails[NKKey.Definition] as? String {
                            video.definition = definition
                        }


                    }
                }
                videoObjects.append(video)
            }
        }
        
        KLog("videoObjects >> \(videoObjects)")
        return videoObjects
    }
    
    func playWithCheckingCachedVideo(_ videoId: String, complete: @escaping (_ videoURL: URL?) -> Void) {
        
        let isCachedVideo = NKFileManager.checkCachedVideo(videoId)
        // 캐싱된 영상일 경우
        if isCachedVideo {
            let filePathURL = URL(fileURLWithPath: NKFileManager.getVideoPath(videoId))
            let decryptFileURL = NKFileManager.sharedInstance.getDecryptFile(videoId)
            KLog("decryptFileURL video path : \(filePathURL)")
            complete(decryptFileURL)
        } else {
            // 스트림 영상일 경우
            self.getStreamURLWithVideoId(videoId, quality: NKUserInfo.sharedInstance.videoQulity, complete: { (streamURL) -> Void in
                KLog("stream video url : \(streamURL)")
                complete(streamURL)
            })
        }
    }
    
    func downloadYouTubeWithViedo(_ video: NKVideo, quality: NSNumber, downloadingStatus: @escaping (_ isDownload: Bool, _ totalData: Int, _ currentData: Int, _ error: NSError?) -> Void, complete:@escaping (_ isSuccess: Bool, _ error: NSError?, _ binaryData: Data?) -> Void) {
        
        downloadingVideo = video
        getStreamURLWithVideoId(video.videoId!, quality: quality) { (streamURL) -> Void in
            
            if streamURL == nil {
                complete(false, NSError(domain: "Failed to get stream url", code: 1980, userInfo: nil), nil)
                return
            }
            if let url = streamURL {
                
//                KLog("url > \(url)")
//                KLog("path > \(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String)")
                
                self.streamData = NSMutableData()
                self.downloadRequest = Alamofire.request(url.absoluteString)
                    
                    .stream(closure: { (data) -> Void in
                        if let streamData = self.streamData {
                            streamData.append(data)
//                            print("append data lenth: \(data.length)")
//                            print("result: \(streamData.length)")
                        }
                        
                    })
                    
                    .downloadProgress { progress in
                        
                        let totalBytesExpectedToRead = progress.totalUnitCount
                        let totalBytesRead = progress.completedUnitCount
//                        print("Download Progress: \(progress.totalUnitCount)")
//                    }
//
//                    .progress({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
                        
//                        KLog("operations >>>> \(NKDownloadManager.sharedInstance.operations())")
                        
                        if let streamData = self.streamData {
//                            KLog("=======\(bytesRead)  \(totalBytesRead)  \(totalBytesExpectedToRead)")
                            if totalBytesRead == totalBytesExpectedToRead {
                                downloadingStatus(true, Int(totalBytesExpectedToRead), streamData.length, nil)
                                
                                let path = NKFileManager.getVideoPath(video.videoId!)
                                do {
                                    let attr: NSDictionary = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
                                    KLog("수정된 날짜 \(attr.fileModificationDate())")
                                    KLog("total size \(attr.fileSize())")
                                } catch {
                                    KLog("파일 사이즈 취득 실패")
                                }

                                do {
                                    let encryptData = RNCryptor.encrypt(data: self.streamData! as Data, withPassword: pw)
//                                    self.downloadingVideo?.binaryData = encryptData
                                    KLog("저장 도큐먼트 .. \(path)")
                                    try encryptData.write(to: URL(fileURLWithPath: path), options: NSData.WritingOptions.atomicWrite)
                                    downloadingStatus(false, Int(totalBytesExpectedToRead), streamData.length, nil)
                                    complete(true, nil, self.streamData as Data?)
                                } catch{
                                    downloadingStatus(false, Int(totalBytesExpectedToRead), streamData.length, NSError(domain: "fail downloading", code: 1980, userInfo: nil))
                                    complete(false, NSError(domain: "Failed to write file", code: 1983, userInfo: nil), nil)
                                }
                            } else {
                                
                                downloadingStatus(true, Int(totalBytesExpectedToRead), streamData.length, nil)
                                
                            }
                        }
                    }
                    
//                    .response(completionHandler: { (_, _, data, error) -> Void in
//                        
//                        if let error = error {
//                            KLog("response error \(error)")
//                        } else {
//                            if let data = data {
//                                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//                                
//                                let path = documentsPath+"/\(video.videoId!).mp4"
//                                KLog("path >>> \(path)")
//                                
//                                do {
//                                    try data.writeToFile(path, options: NSDataWritingOptions.AtomicWrite)
//                                    complete(isSuccess: true, error: nil, binaryData: self.streamData)
//                                } catch{
//                                    KLog("Failed to write file")
//                                    complete(isSuccess: false, error: NSError(domain: "Failed to write file", code: 1983, userInfo: nil), binaryData: nil)
//                                }
//                            }
//                        }
//                    })
            }
        }
        
    }

    // MARK: - 자동검색
    //    http://clients1.google.com/complete/search?ds=yt&client=firefox&q=소녀시대
    func getAutoKeyword(_ keyword: String, complete: @escaping (_ keywordList: [String]) -> Void) {
        KLog("키워드: \(keyword)")
        var url: String = "http://clients1.google.com/complete/search?ds=yt&client=firefox&q="+keyword
        
        // 한국어, 일본어, 영어
        // TODO: 중국어도 되는지 알아보고 싶다.
        if !keyword.canBeConverted(to: String.Encoding.ascii) {
            url += "&hl=jp"
        } else {
            url += "&hl=en"
        }
        if let url = url.addingPercentEscapes(using: String.Encoding.utf8) {
            //        if let url = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
            Alamofire.request(url).responseJSON { (response) -> Void in
                if let error = response.result.error {
                    KLog("request error \(error)")
                    complete([])
                } else {
                    KLog("JSON \(response.result.value)")
                    
                    if let keywords = response.result.value as? [AnyObject] {
                        
                        for object in keywords {
                            if let items = object as? [String] {
                                
                                complete(items)
                            }
                        }
                    }
                }
                
            }
        }

        
    }
    
}
