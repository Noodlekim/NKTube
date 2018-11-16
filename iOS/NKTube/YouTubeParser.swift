//
//  YouTubeParser.swift
//  YellowTube
//
//  Created by NoodleKim on 2017/01/21.
//  Copyright © 2017年 NoodleKim. All rights reserved.
//

import Foundation
import Alamofire

enum YouTubeRequestType {
    case videoInfo
    case html
    case javaScript
    case embed
}

class YouTubeParser {
    
    var webpage: YouTubeWebPage!
    var javaScriptPlayer: YouTubeJavaScriptPlayer!
    
    var languageIdentifier = { () -> String in
        let preferredLocalizations = Bundle.main.preferredLocalizations
        let preferredLocalization = preferredLocalizations.first ?? "en"
        return Locale.canonicalIdentifier(from: preferredLocalization)
    }()

    var videoId: String = ""
    
    var handler: ((_ videos: Dictionary<String, URL>?) -> Void)?
    
    convenience init(videoId: String) {
        self.init()

        self.videoId = videoId
        
//        self.startWatchPageRequest()
    }
    var requestCount: Int = 0
    
    // Html Request
    func startWatchPageRequest() {
        let query: [String : Any] = [
            "v": self.videoId,
            "hl": self.languageIdentifier,
            "has_verified": "true"
        ]
        if let queryString = self.setParam(param: query) {
            if let webPageURL = URL.init(string: "https://www.youtube.com/watch?".appending(queryString)) {
                KLog("webPageURL >> \(webPageURL)")
                
                let request = NSMutableURLRequest.init(url: webPageURL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
                request.setValue(self.languageIdentifier, forHTTPHeaderField: "Accept-Language")
                
                let session = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                    
                    if error != nil {
                        KLog("error >> \(error!)")
                        if let handler = self.handler {
                            handler(nil)
                        }
                    } else {
                        if let data = data, let response = response {
                            self.handleSuccessData(requestType: YouTubeRequestType.html, data: data, response: response)
                        }
                    }
                })
                task.resume()
            }
        }
    }
    
    
    func handleSuccessData(requestType: YouTubeRequestType, data: Data, response: URLResponse) {
        
        let textEncodingName: String = response.textEncodingName ?? ""
        let encoding: CFStringEncoding = CFStringConvertIANACharSetNameToEncoding(textEncodingName as CFString!)
        
        var bytes = [UInt8](data)
        bytes = data.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }
        if let responseString = CFStringCreateWithBytes(
            kCFAllocatorDefault,
            bytes,
            CFIndex.init((data as NSData).length),
            encoding != kCFStringEncodingInvalidId ? encoding :  CFStringBuiltInEncodings.macRoman.rawValue, false) {
            
            
            switch requestType {
            case .videoInfo:
                self.handleVideoInfo(info: dictionary(with: responseString as String), response: response)
            case .html:
                self.handleWebPage(with: responseString)
            case .javaScript:
                self.handleJavaScriptPlayer(with: responseString)
            case .embed:
                break
            }

        }

        
    }
    
    // responseString 핸들링
    func handleWebPage(with html: NSString) {
        self.webpage = YouTubeWebPage.init(with: html)

        if let javaScriptPlayerURL = self.webpage.javaScriptPlayerURL() {
            
            self.startRequestJavaScript(url: javaScriptPlayerURL)
        } else {
            if self.webpage.isAgeRestricted() {
                if let handler = self.handler {
                    handler(nil)
                }
                KLog("연령 제한이면 임베디드 파싱을 해야함.")
            } else {
                KLog("어떻게 해야함?")
            }
        }
    }
    
    func handleJavaScriptPlayer(with script: NSString) {
        
        self.javaScriptPlayer = YouTubeJavaScriptPlayer.init(string: script)

        // TODO: 이쪽 파싱 확인해야함.
        if self.webpage.isAgeRestricted() {

            let eurl = "https://youtube.googleapis.com/v/".appending(self.videoId)
            let stsDic = self.webpage.playConfiguration()
            var sts = ""
            if let value = stsDic?["sts"] {
                sts = "\(value)"
            }
            let query = [ "video_id": self.videoId,
                          "hl": self.languageIdentifier,
                          "eurl": eurl,
                          "sts": sts]
            let query2 = queryString(with: query as NSDictionary)
            KLog("query >> \(query2)")
            if let videoInfoUrl = URL.init(string: "https://www.youtube.com/get_video_info?"+(query2 as String)) {
                KLog("videoInfoUrl >> \(videoInfoUrl)")
                self.startRequestVideoInfo(with: videoInfoUrl)
            }
            
        } else {
            
            self.handleVideoInfo(info: self.webpage.videoInfo(), response: nil)
        }
    }
    
    func startRequestVideoInfo(with url: URL) {
        
        let request = NSMutableURLRequest.init(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
        request.setValue(self.languageIdentifier, forHTTPHeaderField: "Accept-Language")
        
        let session = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                KLog("error >> \(error!)")
                if let handler = self.handler {
                    handler(nil)
                }
            } else {
                if let response = response, let data = data {
                    self.handleSuccessData(requestType: .videoInfo, data: data, response: response)
                }
            }
        })
        task.resume()

    }
    
    func handleVideoInfo(info: NSDictionary, response: URLResponse?) {
        
        let video: YouTubeVideo = YouTubeVideo.init(videoId: self.videoId, info: info, playerScript: self.javaScriptPlayer, response: response, error: nil)

        if let streamURLs = video.streamURLs, streamURLs.count > 0 {
            KLog("파싱된 스트림 url>> \(streamURLs)")
            if let handler = self.handler {
                handler(video.streamURLs)
            }
        } else {
            KLog("videoInfo 스트림 URL취득 실패!!")
            if let handler = self.handler {
                handler(nil)
            }
        }
    }
    
    // 자바스크립트 핸들?
    func startRequestJavaScript(url: URL) {
        
        let request = NSMutableURLRequest.init(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
        request.setValue(self.languageIdentifier, forHTTPHeaderField: "Accept-Language")
        
        let session = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let error = error {
                KLog("error >> \(error)")
                if let handler = self.handler {
                    handler(nil)
                }
            } else {
                
                if let response = response, let data = data {

                    self.handleSuccessData(requestType: YouTubeRequestType.javaScript, data: data, response: response)

//                    let encoding: CFStringEncoding = CFStringConvertIANACharSetNameToEncoding(response.textEncodingName! as CFString!)
//                    
//                    var bytes = [UInt8](data!)
//                    bytes = data!.withUnsafeBytes {
//                        [UInt8](UnsafeBufferPointer(start: $0, count: data!.count))
//                    }
//                    if let responseString = CFStringCreateWithBytes(
//                        kCFAllocatorDefault,
//                        bytes,
//                        CFIndex.init((data! as NSData).length),
//                        encoding != kCFStringEncodingInvalidId ? encoding :  CFStringBuiltInEncodings.macRoman.rawValue, false) {
//                        
//                    }
                    
                }
            }
        })
        task.resume()

    }

    
    private func rquestYouTubePage() {
        
        // 여기서부터 웹페이지 파싱
    }
    
    private func setParam(param: Dictionary<String, Any>) -> String? {
        
        let keys = param.keys
        var query = ""
        for key in keys {
            if query.characters.count > 0 {
                query.append("&")
            }
            query = query.appendingFormat("%@=%@", key, param[key] as! CVarArg)
        }
        
        return query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
}
