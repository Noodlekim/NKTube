//
//  NKCoreDataCachedVideo.swift
//  NKTube
//
//  Created by GibongKim on 2016/02/09.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import SDWebImage

class NKCoreDataCachedVideo: NKSuperCoreData {

    var cachedVideos: [CachedVideo] = []
    var cachedVideoIds: [String] = []
    var cachedVideoIdsWithGroup: [String: [String]] = [:]
    
    
    static var sharedInstance = NKCoreDataCachedVideo()
    
    func updateProperties(_ complete: () -> Void) {
        getOldCachedVideoList(complete)
    }
    
    // MARK: - SELECT
    
    fileprivate func getOldCachedVideoList(_ complete: ()-> Void) -> [CachedVideo] {
        
        if let mainContext = self.mainContext {
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedVideo")
            
            // Add Sort Descriptor
            // 기본 다운로드한 날짜를 기준으로 -> 나중에 정렬기능이 들어가면 order를 최우선으로 잡고 정렬
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Execute Fetch Request
            do {
                let result = try mainContext.fetch(fetchRequest)
                var videoIds: [String] = []
                var videos: [CachedVideo] = []
                for video in result {
                    if let video = video as? CachedVideo {
                        if !videoIds.contains(video.videoId!) {
                            videoIds.append(video.videoId!)
                        }
                        
                        if !videos.contains(video) {
                            videos.append(video)
                        }
                    }
                }
                self.cachedVideoIds = videoIds
                self.cachedVideos = videos
                complete()
                return result as! [CachedVideo]
                
            } catch {
                let fetchError = error as NSError
                print(fetchError)
                complete()
                return []
            }
        } else {
            complete()
            return []
        }
    }
    
    func getCachedVideoList(_ group: String? = nil) -> [CachedVideo] {
        
        if let mainContext = self.mainContext {
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedVideo")
            
            // Add Sort Descriptor
            // 특정 그룹의 곡들만 가져올 경우.
            if let group = group {
                let predicate = NSPredicate(format: "group = %@", group)
                fetchRequest.predicate = predicate
            }
            
            // 기본 다운로드한 날짜를 기준으로 -> 나중에 정렬기능이 들어가면 order를 최우선으로 잡고 정렬
            let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Execute Fetch Request
            do {
                let result = try mainContext.fetch(fetchRequest)
                var videoIds: [String] = []
                var videos: [CachedVideo] = []
                for video in result {
                    if let video = video as? CachedVideo {
                        if !videoIds.contains(video.videoId!) {
                            videoIds.append(video.videoId!)
                        }
                        
                        if !videos.contains(video) {
                            videos.append(video)
                        }
                    }
                    
                }
                self.cachedVideoIds = videoIds
                self.cachedVideos = videos
                
                return result as! [CachedVideo]
                
            } catch {
                let fetchError = error as NSError
                print(fetchError)
                return []
            }
        } else {
            return []
        }
    }
    
    func getCachedVideosInGroup(_ videoId: String) -> [String] {
        
        if let mainContext = self.mainContext {
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedVideo")
            
            if let video = CachedVideo.oldCachedVideo(videoId), let group = video.group {
                
                let predicate = NSPredicate(format: "group = %@", group)
                fetchRequest.predicate = predicate
                let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                // Execute Fetch Request
                do {
                    let result = try mainContext.fetch(fetchRequest)
                    var videoIds: [String] = []
                    for video in result {
                        if let video = video as? CachedVideo {
                            if !videoIds.contains(video.videoId!) {
                                videoIds.append(video.videoId!)
                            }
                        }
                    }
                    self.cachedVideoIdsWithGroup[group] = videoIds
                    
                    return videoIds
                    
                } catch {
                    let fetchError = error as NSError
                    print(fetchError)
                    return []
                }
                
            } else {
                return []
            }
            
        } else {
            return []
        }
    }
    
    func getGroupTitles() -> [GroupTitle] {
        
        if let mainContext = self.mainContext {
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupTitle")
            
            // Add Sort Descriptor
            // 기본 다운로드한 날짜를 기준으로 -> 나중에 정렬기능이 들어가면 order를 최우선으로 잡고 정렬
            let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Execute Fetch Request
            do {
                let result = try mainContext.fetch(fetchRequest)
                return result as! [GroupTitle]
                
            } catch {
                let fetchError = error as NSError
                print(fetchError)
                return []
            }
        } else {
            return []
        }
    }
    
    // MARK: 재생모드 관련
    
    func randomVideo() -> String? {
        
        if self.cachedVideoIds.count > 0 {
            let cnt: Int = Int(self.cachedVideoIds.count)
            let randomIndex = Int(arc4random() % UInt32(cnt))
            
            return self.cachedVideoIds[randomIndex]
        } else {
            
            if self.cachedVideoIds.count == 1 {
                return self.cachedVideoIds[0]
            } else {
                return nil
            }
        }
    }
    
    func nextVideo(_ videoId: String) -> String? {
        
        if var nextIndex = self.cachedVideoIds.index(of: videoId) {
            
            nextIndex += 1
            
            if nextIndex >= self.cachedVideoIds.count {
                nextIndex = 0
            }
            
            if nextIndex >= 0 && nextIndex < self.cachedVideoIds.count {
                return self.cachedVideoIds[nextIndex]
            }
        }
        
        return nil
    }
    
    func preVideo(_ videoId: String) -> String? {
        
        if var nextIndex = self.cachedVideoIds.index(of: videoId) {
            
            nextIndex -= 1
            
            if nextIndex < 0 {
                nextIndex = self.cachedVideoIds.count-1
            }
            
            for videoId in self.cachedVideoIds {
                KLog("videoId >> \(videoId)")
            }
            
            if nextIndex >= 0 && nextIndex < self.cachedVideoIds.count {
                return self.cachedVideoIds[nextIndex]
            }
        }
        
        return nil
    }
    
    func preVideoInGroup(_ videoId: String) -> String? {
        
        let videos = getCachedVideosInGroup(videoId)
        if var preIndex = videos.index(of: videoId) {
            
            preIndex -= 1
            
            if preIndex < 0 {
                preIndex = videos.count-1
            }
            
            for videoId in videos {
                KLog("videoId >> \(videoId)")
            }
            
            if preIndex >= 0 && preIndex < videos.count {
                return videos[preIndex]
            }
        }
        
        return nil
    }
    
    func nextVideoInGroup(_ videoId: String) -> String? {
        
        let videos = self.getCachedVideosInGroup(videoId)
        if var nextIndex = videos.index(of: videoId) {
            
            nextIndex += 1
            
            if nextIndex >= videos.count {
                nextIndex = 0
            }
            
            if nextIndex >= 0 && nextIndex < self.cachedVideoIds.count {
                return videos[nextIndex]
            }
        }
        
        return nil
    }
    
    func randomVideoInGroup(_ videoId: String) -> String? {
        
        let videos = self.getCachedVideosInGroup(videoId)
        
        let cnt: Int = Int(videos.count)
        let randomIndex = Int(arc4random() % UInt32(cnt))
        
        if videos.count == 1 {
            return videos[0]
        }
        return videos[randomIndex]
    }


    
    // MARK: - REMOVE
    
    func removeGroupTitle(_ groupTitle: String) {
        
        if let mainContext = self.mainContext {
            
            if let savedCacheVideo = GroupTitle.oldGroupTitle(groupTitle) {
                mainContext.delete(savedCacheVideo)
                KLog("groupTitle 삭제 성공!")
                NKCoreDataManager.sharedInstance.saveContext({ (isSuccess) -> Void in
                    KLog("done save context \(isSuccess)")
                })
            } else {
                KLog("해당 groupTitle가 없습니다.")
            }
        } else {
            KLog("콘텍스트가 없음!")
        }
        
    }
    
    
    func removeCacheVideo(_ videoId: String, complete:(_ isSuccess: Bool) -> Void) {
        if let mainContext = self.mainContext {
            if let savedCacheVideo = CachedVideo.oldCachedVideo(videoId) {
                mainContext.delete(savedCacheVideo)
                KLog("삭제 성공!")
                NKCoreDataManager.sharedInstance.saveContext(complete)
            } else {
                KLog("해당 videoId가 없습니다.")
                complete(false)
            }
        } else {
            KLog("콘텍스트가 없음!")
            complete(false)
        }
    }
    
    func removeGroupedCacheVideos(_ groupTitle: String, complete:((_ isSuccess: Bool)->Void)) {
        
        if let mainContext = self.mainContext {
            // 비디오 그룹 초기화
            let videos = NKCoreDataCachedVideo.sharedInstance.getCachedVideoList(groupTitle)
            for video in videos {
                video.group = defaultGroupName
            }
            
            if let savedCacheVideo = GroupTitle.oldGroupTitle(groupTitle) {
                mainContext.delete(savedCacheVideo)
            }
        }
        
        NKCoreDataManager.sharedInstance.saveContext(complete)
    }

    
    // MARK: - ADD
    
    func addNewGroup(_ groupName: String, complete:((_ isSuccess: Bool)->Void)) {
        
        var order = 1
        let newGroup = GroupTitle.getNewEntity()
        newGroup?.title = groupName
        newGroup?.order = order as NSNumber?
        
        let oldGroups = NKCoreDataCachedVideo.sharedInstance.getGroupTitles()
        
        for group in oldGroups {
            order += 1
            group.order = order as NSNumber?
        }
        
        NKCoreDataManager.sharedInstance.saveContext(complete)
    }
    
    
    
    // MARK: - UPDATE
    
    func updateGroupTitle(_ oldTitle: String, newTitle: String) {
        
        KLog("oldTitle >> \(oldTitle)")
        KLog("newTitle >> \(newTitle)")
        
        if let oldGroupTitle = GroupTitle.oldGroupTitle(oldTitle) {
            oldGroupTitle.title = newTitle
            NKCoreDataManager.sharedInstance.saveContext({ (isSuccess) -> Void in
                
                if isSuccess {
                    KLog("타이틀 갱신 완료!")
                } else {
                    KLog("타이틀 갱신 실패!")
                }
            })
        }
    }
    

    

    
    @available(iOS 9.0, *)
    func saveAllCachedVideoForSpotlight() {
        
        DispatchQueue.global().async {
            var searchableItems = [CSSearchableItem]()
            
            let cachedVideos = self.getCachedVideoList()
            
            for video in cachedVideos {
                
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: "image" as String)
                if let title = video.title {
                    attributeSet.title = title
                }
                //            KLog("video description >> \(video.videoDescription)")
                if let videoDescription = video.videoDescription {
                    attributeSet.contentDescription = videoDescription
                }
                
                // TODO: OFF라인에서도 캐시된 이미지를 가져와서 손쉽게 적용을 하고 싶다.
                if let url = video.thumbDefault, let imageUrl = URL(string: url), let imageData = try? Data(contentsOf: imageUrl) {
                    attributeSet.thumbnailData = imageData
                }
                
                let item = CSSearchableItem(uniqueIdentifier: video.videoId!, domainIdentifier: "nktube.noodle.com", attributeSet: attributeSet)
                searchableItems.append(item)
            }
            
            CSSearchableIndex.default().indexSearchableItems(searchableItems, completionHandler: { error -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    // MARK: - Spotlight관련

    
    @available(iOS 9.0, *)
    func saveCachedVideoForSpotlight(_ video: NKVideo) {
        
        var searchableItems = [CSSearchableItem]()
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: "image" as String)
        if let title = video.title {
            attributeSet.title = title
        }
        if let videoDescription = video.videoDescription {
            attributeSet.contentDescription = videoDescription
        }
        
        // TODO: OFF라인에서도 캐시된 이미지를 가져와서 손쉽게 적용을 하고 싶다.
        if let url = video.thumbDefault, let imageUrl = URL(string: url), let imageData = try? Data(contentsOf: imageUrl) {
            attributeSet.thumbnailData = imageData
        }
        
        let item = CSSearchableItem(uniqueIdentifier: video.videoId!, domainIdentifier: "nktube.noodle.com", attributeSet: attributeSet)
        searchableItems.append(item)
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems, completionHandler: { error -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
        })
    }
    
    @available(iOS 9.0, *)
    func removeCachedVideoForSpotlight(_ video: CachedVideo) {
        if let videoId = video.videoId {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [videoId]) { (error) -> Void in
                if error != nil {
                    KLog("스포트라이트 삭제 실패! \(error)")
                    return
                }
                KLog("스포트라이트 삭제 성공!")
            }
        }
    }
    
    
    // MARK: -
    // FIXME: - 임시로 쓴 마이그레이션용 매소드들 여기로 다 모아둠.
    
    func migrationForSortGroup() {
        
        let titles: [GroupTitle] = self.getGroupTitles()
        
        for i in 0..<titles.count {
            let groupTitle = titles[i]
            
            if groupTitle.title! == "Default Group" {
                groupTitle.title = defaultGroupName
                groupTitle.order = -1
            } else if groupTitle.title! == defaultGroupName {
                groupTitle.order = -1
            } else {
                groupTitle.order = NSNumber(value: i+10000)
            }
        }
        NKCoreDataManager.sharedInstance.saveContext { (isSuccess) -> Void in
            KLog("save context > \(isSuccess)")
            NKUserInfo.sharedInstance.isMigration = isSuccess
        }
        
    }
    
    func migrationOldVideo() {
        
        let oldVideos: [CachedVideo] = self.getOldCachedVideoList { 
            
        }
        
        for i in 0..<oldVideos.count {
            let video = oldVideos[i]
            if video.downloadDate == nil || video.group == "Default Group" {
                video.downloadDate = Date()
                video.order = i as NSNumber?
                video.group = defaultGroupName
                //                video.videoQulity = "hd" // TODO: 일단 기본 이걸로 설정.. 나중에 영향있을 것 같으면 수정요
            }
        }
        NKCoreDataManager.sharedInstance.saveContext { (isSuccess) -> Void in
            KLog("save context > \(isSuccess)")
            NKUserInfo.sharedInstance.isMigration = isSuccess
        }
    }
    
    func migrationGroupTitle() {
        
        let oldVideos: [CachedVideo] = self.getOldCachedVideoList { 
            
        }
        
        for i in 0..<oldVideos.count {
            let video = oldVideos[i]
            if let group = video.group {
                
                if let oldGroupTitle = GroupTitle.oldGroupTitle(group) {
                    if oldGroupTitle.title == "Default Group" {
                        oldGroupTitle.title = defaultGroupName
                        oldGroupTitle.order = -1
                    } else {
                        oldGroupTitle.order = NSNumber(value: i+1)
                        continue
                    }
                } else {
                    if let newGroupTitle = GroupTitle.getNewEntity() {
                        newGroupTitle.title = group
                        newGroupTitle.order = NSNumber(value: i+1)
                        newGroupTitle.editable = true
                    }
                }
            }
        }
        NKCoreDataManager.sharedInstance.saveContext { (isSuccess) -> Void in
            KLog("save context > \(isSuccess)")
            NKUserInfo.sharedInstance.isMigration = isSuccess
        }
    }
    
    func migrationForGroupTitleReset() {
        
        let oldGroups: [GroupTitle] = self.getGroupTitles()
        
        for oldGroup in oldGroups {
            
            self.mainContext?.delete(oldGroup)
        }
        
        NKCoreDataManager.sharedInstance.saveContext { (isSuccess) -> Void in
            KLog("save context > \(isSuccess)")
            NKUserInfo.sharedInstance.isMigration = isSuccess
        }
    }
    
    // TODO: NSData형식으로 넣어서 재생할때 활용을 하려고 했으나 AVPlayer에서는 URL형식이랑 Path형식뿐이 지원을 안함.. 흠....
    func migrationForSavingVideoInCoreData() {
        
        let oldVideos: [CachedVideo] = self.getOldCachedVideoList { 
            
        }
        
        for cache in oldVideos {
            let path = NKFileManager.getVideoPath(cache.videoId!)
            if let videoData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                cache.videoData = videoData
            }
        }
        
        NKCoreDataManager.sharedInstance.saveContext { (isSuccess) -> Void in
            KLog("saving video data in coredata > \(isSuccess)")
        }
        
    }

}
