//
//  YouTubeService.swift
//  YellowTube
//
//  Created by NoodleKim on 2016/01/17.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import AppAuth
import ObjectMapper

enum VideoQulity: String {
    case small = "240p"
    case medium = "360p"
    case hd = "720p (HD)"
    
    
    static let allQulity: [VideoQulity] = [.small, .medium, .hd]
    func qulityNumber() -> String {
        switch self {
        case .small:
            return "36"
        case .medium:
            return "18"
        case .hd:
            return "22"
        }
    }
    
    static func getVideoQulity(string: String) -> VideoQulity? {
        switch string {
        case "240p":
            return .small
        case "360p":
            return .medium
        case "720p (HD)":
            return .hd
        default:
            return nil
        }
    }
    
    static func getQulityNumber(string: String) -> String? {
        return VideoQulity.getVideoQulity(string: string)?.qulityNumber()
    }
    /*
     struct NKVideoQulity {
     static let Small240 = NSNumber(value: 36 as Int32)
     static let Medium360 = NSNumber(value: 18 as Int32)
     static let HD720 = NSNumber(value: 22 as Int32)
     }
     */
}


extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}


class YouTubeService2: NSObject {
    
    var streamData: NSMutableData?
    var pageToken: String?
    var authErrorCount: Int = 0
    
    static var shared = YouTubeService2()
    
    /// 백그라운드 재생을 위한 세션 매니저
    fileprivate lazy var backgroundManager: SessionManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.noodlekim")
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    var backgroundCompletionHandler: (() -> Void)? {
        get { return backgroundManager.backgroundCompletionHandler }
        set { backgroundManager.backgroundCompletionHandler = newValue }
    }
    
    /// 공통 리퀘스트 부분
    private func fetch<E: BaseMappable>(path: APIPath, parameters: [String: Any], isNeedsToken: Bool = true, completion: @escaping (_ result: E?, _ error: PTError?) -> Void) {
        
        var url = YouTubeURL.baseURL + path.rawValue
        
        if !parameters.isEmpty {
            url += "?"
            url += parameters.map({ (k: String, v: Any) -> String in "\(k)=\(v)" }).joined(separator: "&")
            url += "&key=" + apiKey
        }
        guard let encodingUrl = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            completion(nil, nil)
            return
        }
        
        var headers: HTTPHeaders?
        if isNeedsToken, let accessToken = NKUserInfo.sharedInstance.accessToken as? String {
            headers = ["Authorization": "Bearer \(accessToken)"]
        }
        Alamofire.request(encodingUrl, headers: headers).responseJSON { (response: DataResponse<Any>) in
            KLog("JSON \(String(describing: response.result.value))")

            // Google API Error
            if let apiError = Mapper<APIError>().map(JSONObject: response.result.value!) {
                // 토큰 유효기간 만료
                if let code = apiError.code {
                    
                    if code == 401 {
                        if self.self.authErrorCount > 5 {
                            completion(nil, PTError.failRefreshToken)
                            // TODO: 얼럿 처리
                            self.authErrorCount = 0 // 이경우 얼럿을 보여주고 Count 초기화
                            return
                        } else {
                            // 리프레쉬 토큰 갱신 처리
                            if let refreshToken = NKUserInfo.sharedInstance.refreshToken as? String {
                                self.updateAPIToken(refreshToken: refreshToken, completion: { auth, error in
                                    if let newAccessToken = auth?.access_token {
                                        NKUserInfo.sharedInstance.setAccessToken(newAccessToken)
                                        completion(nil, PTError.successRefreshToken)
                                    } else {
                                        completion(nil, PTError.failRefreshToken)
                                    }
                                })
                            } else {
                                completion(nil, PTError.failRefreshToken)
                            }
                        }
                    } else {
                        completion(nil, PTError.otherAPIError(error: apiError))
                    }
                // 그밖에
                } else if let error = response.result.error {
                    completion(nil, PTError.alamofireError(error: error))
                // 결과
                } else if let result = Mapper<E>().map(JSONObject: response.result.value) {
                    completion(result, nil)
                // TODO: 그밖에?
                } else {
                    completion(nil, nil) // ??
                }
            }
        }
    }
    
    private func fetch<E: BaseMappable>(path: APIPath, parameters: [String: Any], isNeedsToken: Bool = true, nextPageToken: String?, completion: @escaping (_ result: E?, _ nextPageToken: String?, _ error: PTError?) -> Void) {
        
        var url = YouTubeURL.baseURL + path.rawValue
        
        if !parameters.isEmpty {
            url += "?"
            url += parameters.map({ (k: String, v: Any) -> String in "\(k)=\(v)" }).joined(separator: "&")
            url += "&key=" + apiKey
        }
        var headers: HTTPHeaders?
        if isNeedsToken, let accessToken = NKUserInfo.sharedInstance.accessToken as? String {
            headers = ["Authorization": "Bearer \(accessToken)"]
        }
        Alamofire.request(url, headers: headers).responseJSON { (response: DataResponse<Any>) in
            KLog("JSON \(String(describing: response.result.value))")

            // 에러메세지인가 부터 체크
            if let apiError = Mapper<APIError>().map(JSONObject: response.result.value!) {
                // 토큰유효기간 만료
                if let code = apiError.code {
                    if code == 401 {
                        completion(nil, nextPageToken, PTError.failRefreshToken)
                    // 다른 유형으로 간주
                    } else {
                        completion(nil, nextPageToken, PTError.otherAPIError(error: apiError))
                    }
                } else {
                    // Alamofire에러
                    if let error = response.result.error {
                        completion(nil, nextPageToken, PTError.alamofireError(error: error))
                    // 결과값 체크
                    } else if let result = Mapper<E>().map(JSONObject: response.result.value) {
                        completion(result, nextPageToken, nil)
                        // TODO: 그밖에?
                    } else {
                        completion(nil, nil, nil) // ??
                    }
                }
            }
        }
    }

    func updateAPIToken(refreshToken: String, completion: @escaping (_ result: AuthResults?, _ error: PTError?) -> Void) {
        
        self.authErrorCount += 1

        let url = "https://www.googleapis.com/oauth2/v4/token"

        let headers: HTTPHeaders = ["Host": "www.googleapis.com",
                                    "Content-Type": "application/x-www-form-urlencoded"]
        let parameters = ["client_id": clientId,
                          "refresh_token": refreshToken,
                          "grant_type": "refresh_token"
                          ]
        
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { (response: DataResponse<Any>) in
            KLog("JSON \(String(describing: response.result.value))")
            
            if let result = Mapper<AuthResults>().map(JSONObject: response.result.value) {
                completion(result, nil)
            }
        }
    }

    
    // MARK: - 영상관련 API들
    
    /// 구독리스트
    func getSubscriptions(param: [String: Any], completion: @escaping (_ result: Subscription?, _ error: PTError?) -> Void) {
        
        self.fetch(path: .subscriptions, parameters: param, completion: completion)
    }
    
    // 각 채널 리스트
    func getChannelSections(param: [String: Any], completion: @escaping (_ result: ChannelList?, _ error: PTError?) -> Void) {
        
        self.fetch(path: .search, parameters: param, completion: completion)
    }

    // 비디오 상세정보 with NextPageToken
    func getVideoDetails(param: [String: Any], nextPageToken: String? = nil, completion: @escaping (_ result: VideoRoot?, _ nextPageToken: String? , _ error: PTError?) -> Void) {

        self.fetch(path: .videos, parameters: param, isNeedsToken: false, nextPageToken: nextPageToken, completion: completion)
    }
    
    // 비디오 상세 정보 Fetch
    func getVideoDetails(param: [String: Any], completion: @escaping (_ result: VideoRoot?, _ error: PTError?) -> Void) {
        
        self.fetch(path: .videos, parameters: param, completion: completion)
    }

    /// 유저가 등록한 관련 아이디들 가져오기. ()
    func getUserRelatedPlaylists(param: [String: Any], completion: @escaping (_ result: UserRelatedPlaylists?, _ error: PTError?) -> Void) {
        
        self.fetch(path: .channels, parameters: param, completion: completion)
    }

    /// 이이네 영상 가져오기
    func getLikesForMe(param: [String: Any], completion: @escaping (_ result: VideoRoot?, _ nextPageToken: String?, _ error: PTError?) -> Void) {
                
        self.fetch(path: .playlistItems, parameters: param) { (root: LikeRoot?, error: PTError?) in
            
            if let error = error {
                switch error {
                case .networkError:
                    break
                case .failRefreshToken:
                    break
                // TODO: Alamofire에러 핸들링
                case .alamofireError(error: _):
                    break
                case .successRefreshToken:
                    self.getLikesForMe(param: param, completion: completion)
                    return
                default:
                    break
                }
            }
            guard let items = root?.items else {
                completion(nil, nil, nil)
                return
            }
            let videoIds = items.flatMap({ $0.videoId }).joined(separator: ",")
            self.getVideoDetails(param: self.parameter(forDetailVideo: videoIds), nextPageToken: root?.nextPageToken ,completion: completion)
        }
    }

    /// 추천 영상 가져오기
    func getRecommandVideos(param: [String: Any], completion: @escaping (_ result: VideoRoot?, _ nextPageToken: String?, _ error: PTError?) -> Void) {
        self.fetch(path: .activities, parameters: param, completion: { (root: RecommandsRoot?, error: Error?) in

            guard let items = root?.items else {
                completion(nil, nil, nil)
                return
            }
            
            let videoIds = items.flatMap({ $0.videoId }).joined(separator: ",")
            self.getVideoDetails(param: self.parameter(forDetailVideo: videoIds), nextPageToken: root?.nextPageToken, completion: completion)

        })
    }
    
    /// 인기 영상 가져오기
    func getPopularVideos(param: [String: Any], completion: @escaping (_ result: VideoRoot?, _ nextPageToken: String?, _ error: PTError?) -> Void) {
        self.fetch(path: .videos, parameters: param, completion: { (root: VideoRoot?, error: Error?) in
            
            guard let items = root?.videos else {
                completion(nil, nil, nil)
                return
            }
            
            let videoIds = items.flatMap({ $0.videoId }).joined(separator: ",")
            self.getVideoDetails(param: self.parameter(forDetailVideo: videoIds), nextPageToken: root?.nextPageToken, completion: completion)
        })
    }
    
    /// 관련 영상 가져오기
    func getRelatedVideoIds(param: [String: Any], completion: @escaping (_ result: VideoRoot?, _ nextPageToken: String?, _ error: PTError?) -> Void) {
        self.fetch(path: .search, parameters: param, completion: { (root: RelatedVideoRoot?, error: Error?) in
            
            guard let items = root?.videos else {
                completion(nil, nil, nil)
                return
            }
            
            let videoIds = items.flatMap({ $0.videoId }).joined(separator: ",")
            self.getVideoDetails(param: self.parameter(forDetailVideo: videoIds), nextPageToken: root?.nextPageToken, completion: completion)
        })
    }

    /// 검색
    func getVideoIdWithKeyword(param: [String: Any], completion: @escaping (_ result: VideoRoot?, _ nextPageToken: String?, _ error: PTError?) -> Void) {
        self.fetch(path: .search, parameters: param, isNeedsToken: false, completion: { (root: RelatedVideoRoot?, error: PTError?) in
            
            guard let items = root?.videos else {
                completion(nil, nil, nil)
                return
            }
            
            let videoIds = items.flatMap({ $0.videoId }).joined(separator: ",")
            self.getVideoDetails(param: self.parameter(forDetailVideo: videoIds), nextPageToken: root?.nextPageToken, completion: completion)
        })
    }
    
    // 비디오 정보 
    func getVideoDetailSingle(videoId: String, completion: @escaping (_ result: VideoRoot?, _ nextPageToken: String?, _ error: PTError?) -> Void) {
        self.getVideoDetails(param: self.parameter(forDetailVideo: videoId), nextPageToken: nil ,completion: completion)
    }
    
//    // 유투브의 스트림 URL을 취득
//    func getStreamURLWithVideoId(_ videoId: String, quality: String, complete: @escaping (_ streamURL: URL?) -> Void) {
//
//        let youTubeParser = YouTubeParser.init(videoId: videoId)
//        youTubeParser.startWatchPageRequest()
//        youTubeParser.handler = { (streamURLs) in
//            
//            if let streamURLs = streamURLs {
//                if let qualityNumber = VideoQulity.getQulityNumber(string: quality), let url = streamURLs[qualityNumber] {
//                    complete(url)
//                } else {
//                    // 선택한 해상도의 URL이 없으면 그 아래껄로 다운
//                    if let url = streamURLs[VideoQulity.medium.qulityNumber()] {
//                        complete(url)
//                        return
//                    } else {
//                        if let url = streamURLs[VideoQulity.small.qulityNumber()] {
//                            complete(url)
//                            return
//                        }
//                    }
//                    complete(nil)
//                }
//            } else {
//                complete(nil)
//            }
//        }
//    }
    
    
    // MARK: - Private
    
    // TODO: 매번 다시 채널 정보 가져오지 말고 다른 방법 강구할 것
    func getChannelThumbInfo(_ video: Video, completion:@escaping (_ default: String?, _ medium: String?, _ hight: String?) -> Void)  {
        if let channelId = video.channelId {
            let url: String = "https://www.googleapis.com/youtube/v3/channels?part=snippet&id="+channelId+"&fields=items%2Fsnippet%2Fthumbnails&key="+apiKey
            
            Alamofire.request(url).responseJSON { (response) -> Void in
                KLog("JSON \(String(describing: response.result.value))")
                if let data = response.result.value as? Dictionary<String, AnyObject> {
                    let thumbs = self.parserFromChannelThumbData(data)
                    completion(thumbs.defaults, thumbs.medium, thumbs.hight)
                }
            }
        }
    }

    /// 비디오 상세 파라미터 취득
    private func parameter(forDetailVideo videoIds: String) -> [String : Any] {
        return [
            "part": "snippet,contentDetails,status,statistics",
            "id": videoIds,
            "maxResults": maxResults
            ] as [String : Any]

    }
    
    /// 유투브 채널 썸네일 파싱
    fileprivate func parserFromChannelThumbData(_ thumbData: Dictionary<String, AnyObject>) -> (defaults: String?, medium: String?, hight: String?) {
        
        if let items = thumbData[Key.Items] as? [Dictionary<String, Any>] {
            
            for item in items {
                
                if let snippet = item[Key.Snippet] as? Dictionary<String, AnyObject> {
                    
                    // thumbnails
                    if let thumbnails = snippet[Key.Thumbnails] as? Dictionary<String, AnyObject>,
                        let thumbDefault = thumbnails[Key.Default] as? Dictionary<String, Any>, let thumbMedium = thumbnails[Key.Medium] as? Dictionary<String, Any>, let thumbHigh = thumbnails[Key.High] as? Dictionary<String, Any> {
                        
                        return (thumbDefault[Key.Url] as? String, thumbMedium[Key.Url] as? String, thumbHigh[Key.Url] as? String)
                    }
                }
            }
        }
        return (nil, nil, nil)
    }
    
    
    /// 자동검색
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
        if let url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            //        if let url = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
            Alamofire.request(url).responseJSON { (response) -> Void in
                if let error = response.result.error {
                    KLog("request error \(error)")
                    complete([])
                } else {
                    KLog("JSON \(String(describing: response.result.value))")
                    
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
