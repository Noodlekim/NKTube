//
//  YouTubeVideo.swift
//  YellowTube
//
//  Created by NoodleKim on 2017/01/22.
//  Copyright © 2017年 NoodleKim. All rights reserved.
//

import Foundation



func dictionary(with queryString: String) -> NSDictionary {
    let dic = NSMutableDictionary()
    let fields = queryString.components(separatedBy: "&")
    
    for field in fields {
        let pair = field.components(separatedBy: "=")
        if pair.count == 2 {
            let key = pair[0]
            if var value = pair[1].removingPercentEncoding {
                value = value.replacingOccurrences(of: "+", with: " ")
                if let tempValue = dic[key] as? String, tempValue != value {
//                    KLog("쿼리값 오류 \(key)======\(queryString)=====\(dic[key])")
                }
                dic[key] = value
            }
        }
    }
    return dic.copy() as! NSDictionary
}


func queryString(with dictionary: NSDictionary) -> NSString {
    
    let keys = dictionary.allKeys.filter {
        $0 is NSString
    }
    
    let query = NSMutableString.init()
    for key in NSArray.init(array: keys).sortedArray(using: #selector(NSNumber.compare(_:))) {
        
        if query.length > 0 {
            query.append("&")
        }
        
        query.appendFormat("%@=%@", key as! CVarArg, (dictionary[key] as! NSObject).description)
    }
    
    return query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) as NSString? ?? ""
}


class YouTubeVideo {

    let errorDomain: String = "VideoErrorDomain"
    let AllowedCountriesUserInfoKey: String = "AllowedCountries"
    let NoStreamVideoUserInfoKey: String = "NoStreamVideo"
    let VideoQualityHTTPLiveStreaming: String = "HTTPLiveStreaming"
    
    
    var videoId: String!
    var title: String!
    var duration: Double = 0.0
    var smallThumbnailURL: URL?
    var mediumThumbnailURL: URL?
    var largeThumbnailURL: URL?
    var expirationDate: NSDate?
    var streamURLs: Dictionary<String, URL>?
    
    
    // MARK: - Class 매소드
    
    class func sortedDictionaryDescription(dictionary: NSDictionary) -> NSString {
        
        let sortedKeys = (dictionary.allKeys as NSArray).sortedArray(comparator: { (obj1, obj2) -> ComparisonResult in
            return (obj1 as! NSObject).description.compare((obj2 as! NSObject).description, options: String.CompareOptions.numeric, range: nil, locale: nil)
        })
        
        let description = NSMutableString.init(string: "{\n")
        for key in sortedKeys {
            description.appendFormat("\t%@ → %@\n", key as! CVarArg, dictionary[key] as! CVarArg) // TODO: \u2192 이거 제대로 동작안할 것 같은데?--a 일단 변환하면 →　이니.. 한번 해보자.
        }
        description.append("}")
        return description.copy() as? NSString ?? ""
    }
    
    class func URLBySettingParameter(url: URL, key: NSString, percentEncodedValue: NSString) -> URL? {
        
        let pattern = String.init(format: "((?:^|&)%@=)[^&]*", key)
        let template = String.init(format: "$1%@", percentEncodedValue)
        
        let components = NSURLComponents.init(url: url, resolvingAgainstBaseURL: false)
        do {
            
            let regularExpression = try NSRegularExpression.init(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let percentEncodedQuery: NSMutableString = NSMutableString.init(string: components?.percentEncodedQuery ?? "")
            let numberOfMatches = regularExpression.replaceMatches(in: percentEncodedQuery, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, percentEncodedQuery.length), withTemplate: template)
            
            if numberOfMatches == 0 {
                percentEncodedQuery.appendFormat("%@%@=%@", percentEncodedQuery.length > 0 ? "&" : "", key, percentEncodedValue)
            }
            components?.percentEncodedQuery = percentEncodedQuery as String
            return components?.url
            
        } catch let error {
            KLog("패턴 확인 실패 \(error)")
        }
        
        return nil
    }

    
    class func exprirationDate(streamURL: URL) -> NSDate? {
        if let streamQuery = streamURL.query {
            let query = dictionary(with: streamQuery)
            if let expire = query["expire"] as? Double {
                return expire > 0 ? NSDate.init(timeIntervalSince1970: expire) : nil
            }
        }
        return nil
    }
    
    
    // MARK: - Init
    
    convenience init(videoId: String, info: NSDictionary, playerScript: YouTubeJavaScriptPlayer?, response: URLResponse?, error: NSError?) {
        self.init()
        
        self.videoId = videoId
        
        let streamMap = info["url_encoded_fmt_stream_map"] as? String
        let httpLiveStream = info["hlsvp"] as? String
        let adaptiveFormats = info["adaptive_fmts"] as? String

        let userInfo = response?.url != nil ? [NSURLErrorKey: "response url error" ] : NSMutableDictionary.init()
        KLog("error > \(userInfo)")
        
        if let streamMap = streamMap, !streamMap.isEmpty {
            
            var streamQueries: [String] = streamMap.components(separatedBy: ",")
            if let adaptiveFormats = adaptiveFormats {
                streamQueries = (streamQueries as NSArray).addingObjects(from: adaptiveFormats.components(separatedBy: ",")) as! [String]
            }
            
            self.title = info["title"] as? String ?? ""
            self.duration = info["length_seconds"] as? Double ?? 0.0
            
            let smallThumbnail = info["thumbnail_url"] as? String ?? info["iurl"] as? String
            let mediumThumbnail = info["iurlsd"] as? String ?? info["iurlhq"] as? String ?? info["iurlmq"] as? String
            let largeThumbnail = info["iurlmaxres"] as? String ?? ""
            
            if let smallThumbnail = smallThumbnail {
                self.smallThumbnailURL = URL.init(string: smallThumbnail)
            }
            
            if let mediumThumbnail = mediumThumbnail {
                self.mediumThumbnailURL = URL.init(string: mediumThumbnail)
            }
            self.largeThumbnailURL = URL.init(string: largeThumbnail)
            
            var streamURLs = [String: URL]()

            if let httpLiveStream = httpLiveStream, !httpLiveStream.isEmpty {
                streamURLs[VideoQualityHTTPLiveStreaming] = URL.init(string: httpLiveStream)
            }
            
            for streamQuery in streamQueries {
                let stream = dictionary(with: streamQuery)
                let scrambledSignature = stream["s"] as? String

                // TODO: signature랑 에러 핸들링 보완해야함.
//                if let scrambledSignature = scrambledSignature, scrambledSignature != "", playerScript != nil {
//                    userInfo[NoStreamVideoUserInfoKey] = self
////                    if var error = error {
//                        // TODO: 에러처리후 넘겨줌.
//                    // userInfo 도 넘겨야함.
////                    NSError.init(domain: errorDomain, code: -1000, userInfo: nil)
////                    }
//                    KLog("====== NoStreamVideoUserInfoKey ============!!")
//                    return
//                }
                
                let signature = playerScript?.unscrambleSignature(scrambledSignature: scrambledSignature)
                
                if playerScript != nil && scrambledSignature != nil && signature == nil {
                    continue
                }
                
                if let urlString = stream["url"] as? String, let itag = stream["itag"] {
                    
                    if var streamURL = URL.init(string: urlString), self.expirationDate == nil {
                        self.expirationDate = YouTubeVideo.exprirationDate(streamURL: streamURL)
                        
                        if let signature = signature {
                            let escapedSignature = signature.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                            streamURL = YouTubeVideo.URLBySettingParameter(url: streamURL, key: "signature", percentEncodedValue: escapedSignature! as NSString)!
                        }
                        
                        // 이거 원래는 NSNumber형식으로 키를 지정을 했었음.
                        if let tempURL = YouTubeVideo.URLBySettingParameter(url: streamURL, key: "ratebypass", percentEncodedValue: "yes") {
                            let itagKey = "\(itag)" // 이거 스트링형식으로 처리하자.
                            streamURLs[itagKey] = tempURL
                        }

                    }
                }
            }
            self.streamURLs = streamURLs
            
            if self.streamURLs == nil || self.streamURLs!.count == 0 {
                
                KLog("스트림 URL취득 실패했음.")
                return
            }

        } else {
            
            // TODO: 이쪽도 제대로 돌아가도록 해야함!
            if var reason = info["reason"] as? NSString {
                reason = reason.replacingOccurrences(of: "<br\\s*/?>", with: " ", options: String.CompareOptions.regularExpression, range: NSMakeRange(0, reason.length)) as NSString
                reason = reason.replacingOccurrences(of: "\n", with: " ", options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(0, reason.length)) as NSString
                
//                let range = reason.range(of: "<[^>]+>", options: NSString.CompareOptions.regularExpression).location
//                while reason.range(of: "<[^>]+>", options: NSString.CompareOptions.regularExpression).location != NSNotFound {
//                    reason = reason.replacingCharacters(in: <#T##NSRange#>, with: <#T##String#>)
//                }
                // TODO: 일단 패스
                KLog("암튼 에러.. ")
            }
        }
    }
    
    
    // 이거 왜 필요하지?
//    func mergeVideo(video: YouTubeVideo) {
//        
//        var count: UnsignedInteger
//        properties: objc_property_t = class_copyPropertyList(self.class, count)
//    }
    
}
