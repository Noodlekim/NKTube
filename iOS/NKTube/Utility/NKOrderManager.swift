//
//  NKOrderManager.swift
//  NKTube
//
//  Created by NoodleKim on 2016/06/26.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

/*
 - 곡추가 > 그룹명
    - 기존 곡들위에 제일 먼저 올림
 - 그룹만들기 > 해당 곡들
    - 새로운 그룹이면 그룹에 곡순서대로 정렬처리
    - 이미 있는 그룹이면 기존곡 앞에 새로운 영상을 넣음.
 - 그룹삭제 > 해당 그룹
    - 그룹을 삭제 > 해당 곡들을 기본 폴더로 다 보내버림.
 - 정렬모드로 바꿀 때?
 */
class NKOrderManager: NSObject {

    static let sharedInstance: NKOrderManager = NKOrderManager()
 
    func addNewVideo(_ video: CachedVideo, complete:(_ isSuccess: Bool) -> ()) {
        addVideosInGroup([video], complete: complete)
    }
    
    func addVideosInGroup(_ videos: [CachedVideo], group: String = defaultGroupName, complete:(_ isSuccess: Bool) -> ()) {
        
        var i: Int = 0
        for video in videos {
            video.order = i as NSNumber?
            video.group = group
            KLog("비티오 타이틀: \(video.title!)")
            KLog("비티오 순번: \(video.order!)")
            i += 1
        }
        
        let oldVideos = NKCoreDataCachedVideo.sharedInstance.getCachedVideoList(group)
        for oidVideo in oldVideos {
            if !videos.contains(oidVideo) {
                oidVideo.order = i as NSNumber?
                i += 1
            }
        }
        
        NKCoreDataManager.sharedInstance.saveContext(complete)
    }
    
    func changeGroup(_ video: CachedVideo, groupTitle: String, indexPath: IndexPath, complete:(_ isSuccess: Bool) -> Void) {
        
        // 새로운 비디오 순서 셋팅
        var index = indexPath.row
        video.order = index as NSNumber?
        video.group = groupTitle
        let videos = NKCoreDataCachedVideo.sharedInstance.getCachedVideoList(groupTitle)
        
        // 기존 비디오 순서
        for i in 0 ..< videos.count {
            let oldVideo = videos[i]
            if Int(oldVideo.order!) >= index {
                index += 1
                oldVideo.order = index as NSNumber?
            }
        }
        
        NKCoreDataManager.sharedInstance.saveContext(complete)
    }
    
    func removeGroup(_ groupTitle: String, complete:((_ isSuccess: Bool)->Void)) {
        NKCoreDataCachedVideo.sharedInstance.removeGroupedCacheVideos(groupTitle, complete: complete)
    }
    
    func AddNewGroup(_ groupTitle: String, complete:((_ isSuccess: Bool)->Void)) {        
        NKCoreDataCachedVideo.sharedInstance.addNewGroup(groupTitle, complete: complete)
    }

    
}
