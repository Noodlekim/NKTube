//
//  CachedVideo.swift
//  NKTube
//
//  Created by NoodleKim on 2016/03/07.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import Foundation
import CoreData

class CachedVideo: NSManagedObject, VideoProtocol {

// Insert code here to add functionality to your managed object subclass

    var cachedPercentage: Float = 0
    var commonId: String? {
        get {
            return videoId
        }
    }
    class func getNewEntity() -> CachedVideo? {
        
        if let mainContext = NKCoreDataManager.sharedInstance.mainContext {
            let entityDescription = NSEntityDescription.entity(forEntityName: "CachedVideo", in: mainContext)
            return CachedVideo(entity: entityDescription!, insertInto: mainContext)
        } else {
            return nil
        }
    }
    
    
    class func oldCachedVideo(_ videoId: String) -> CachedVideo? {
        
        if let mainContext = NKCoreDataManager.sharedInstance.mainContext {
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedVideo")
            
            let predicate = NSPredicate(format: "videoId = %@", videoId)
            fetchRequest.predicate = predicate
            
            // Add Sort Descriptor
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Execute Fetch Request
            do {
                let result = try mainContext.fetch(fetchRequest)
                if result.count > 0 {
                    return result[0] as? CachedVideo
                } else {
                    return nil
                }
                
            } catch {
                let fetchError = error as NSError
                print(fetchError)
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    class func setCacheDataWithVideo(_ video: NKVideo) -> CachedVideo? {
        
        if let video = CachedVideo.oldCachedVideo(video.videoId!) {
            KLog("이미 저장된 데이터 있음.");
            return video
        }
        
        if let videoModel = CachedVideo.getNewEntity() {
            
            if let videoId = video.videoId {
                videoModel.videoId = videoId
                let path = NKFileManager.getVideoPath(videoId)
                videoModel.path = path
            }
            
            if let quality = video.videoQulity {
                videoModel.quality = quality
            } else {
                videoModel.quality = NKUserInfo.shared.videoQulity.stringValue
            }
            videoModel.title = video.title!
            
            if let videoDescription = video.videoDescription {
                videoModel.videoDescription = videoDescription
            }
            
            if let channelTitle = video.channelTitle {
                videoModel.channelTitle = channelTitle
            }
            
            videoModel.embedHtml = video.embedHtml
            
            videoModel.thumbDefault = video.thumbDefault
            
            videoModel.thumbMedium = video.thumbMedium
            
            videoModel.thumbHigh = video.thumbHigh
            
            videoModel.thumbStandard = video.thumbStandard
            
            videoModel.thumbMaxres = video.thumbMaxres
            videoModel.cachedPercentage = Float(video.cachedPercentage)

            videoModel.downloadDate = Date()
            videoModel.order = 0 // 일단 0으로 이거 필요 없을 지도.
            videoModel.group = defaultGroupName
            videoModel.license = video.license
            videoModel.privacyStatus = video.privacyStatus
            videoModel.duration = video.duration
            videoModel.publicStatsViewable = video.publicStatsViewable
            videoModel.definition = video.definition
            videoModel.likeCount = video.likeCount
            videoModel.viewsCount = video.viewCount
            videoModel.unLike = video.dislikeCount
            
            return videoModel
        }
        
        return nil
    }    
}
