//
//  NKMyMenuViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/01/16.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

protocol NKCachedMovieListViewControllerDelegate {
    
    func didChangeHeight(_ isEdit: Bool, height: CGFloat)
    func beginEditMode(_ modeOn: Bool)
    func beginCreateGroup()
}


class NKCachedMovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var olEditButton: UIButton!
    @IBOutlet weak var cacheTableView: UITableView!
    @IBOutlet weak var olHeightEditCompleteButton: NSLayoutConstraint!

    var delegate: NKCachedMovieListViewControllerDelegate?
    
    var cachedVideoList: [String: [CachedVideo]] = [:]
    var backupedVideoList: [String: [CachedVideo]] = [:]
    var openCloseManager: [String: AnyObject] = [:]

    let heightOfSection: CGFloat = 36.0
    let heightCacheGroupSection: CGFloat = 46.0
    
    func cachedGroupedVideoList() -> [String: [CachedVideo]] {
        
        let videos = NKCoreDataCachedVideo.sharedInstance.getCachedVideoList()
        var groupArr: [GroupTitle] = self.groupTitles()
        if groupArr.count == 0 {
            
            if let group = GroupTitle.getNewEntity() {
                group.title = defaultGroupName
                group.order = -1000                
                groupArr = [group]
            }
        }
        
        var result: [String: [CachedVideo]] = [:]

        for groupTitle in groupArr {
            
            let group = groupTitle.title!
            var groupedVideos: [CachedVideo] = []
            for cacheVideo in videos {
    
                if let videoGroup = cacheVideo.group {
                    if group == videoGroup {
                        groupedVideos.append(cacheVideo)
                    }
                }
            }
            let sortedVideos = groupedVideos.sorted(by: { (video1, video2) -> Bool in
                KLog("video1.title \(video1.title!)")
                KLog("video1.order \(video1.order!)")
                KLog("video2.title \(video2.title!)")
                KLog("video2.order \(video2.order!)")
                return (video1.order!.compare(video2.order!) == .orderedAscending)
            })

            result[group] = sortedVideos
            self.backupedVideoList[group] = sortedVideos
            // 기본 열려있는 설정
            self.openCloseManager[group] = true as AnyObject?
            

        }
        KLog("grouped video result >> \(result)")
        
        return result
    }

    func groupTitles() -> [GroupTitle] {
        return NKCoreDataCachedVideo.sharedInstance.getGroupTitles()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //
        NotificationCenter.default.addObserver(self, selector: #selector(NKCachedMovieListViewController.updateVideoList), name: NSNotification.Name(rawValue: "changeVideoStatus"), object: nil);
        // 그룹 등록용 Notification등록
        NotificationCenter.default.addObserver(self, selector: #selector(NKCachedMovieListViewController.updateVideoList), name: NSNotification.Name(rawValue: "completeCreatingGroup"), object: nil)

        cacheTableView.registerCell("NKCachedVideoListCell", cellId: "cachedVideoCell")
        cachedVideoList = cachedGroupedVideoList()
        
        let delay = 1.5 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.notifyTotalHeight()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func acEdit(_ sender: AnyObject) {

        cacheTableView.setEditing(!cacheTableView.isEditing, animated: true)

        // 기본 화면 이동 제스처 막기
        if let delegate = self.delegate {
            delegate.beginEditMode(cacheTableView.isEditing)
        }
        
        // 스크롤 액션 전환
        cacheTableView.isScrollEnabled = cacheTableView.isEditing
        
        // 전체 프레임 모드로 조정
        self.notifyTotalHeight()

        self.cacheTableView.beginUpdates()
        let range = NSMakeRange(0, self.groupTitles().count)
        self.cacheTableView.reloadSections(IndexSet(integersIn: range.toRange() ?? 0..<0), with: .fade)
        self.cacheTableView.endUpdates()

        NKUtility.viewAnimation {
            if self.cacheTableView.isEditing {
                self.olEditButton.isSelected = true
                self.olEditButton.alpha = 0.0
                self.olHeightEditCompleteButton.constant = 40
            } else {
                self.olEditButton.isSelected = false
                self.olEditButton.alpha = 1.0
                self.olHeightEditCompleteButton.constant = 0
            }
        }
    }
    
    @IBAction func acAddGroup(_ sender: AnyObject) {

        if let delegate = self.delegate {
            delegate.beginCreateGroup()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 
    func updateVideoList() {
        DispatchQueue.main.async {
            self.cachedVideoList = self.cachedGroupedVideoList()
            self.cacheTableView.reloadData()
            self.notifyTotalHeight()
        }
    }
    
    func notifyTotalHeight() {
        var heightOfTableView: CGFloat = 0.0
        for key in self.cachedVideoList.keys {
            
            heightOfTableView += self.heightOfSection

            if let cells = self.cachedVideoList[key] {
                heightOfTableView += CGFloat(cells.count)*NKCachedVideoListCell.height()
            }
        }
        heightOfTableView += heightCacheGroupSection
        KLog("heightofTable ** \(heightOfTableView)")
        if let delegate = self.delegate {
            // TODO: 헤더쪽 디자인 나오면 수치반영
            delegate.didChangeHeight(cacheTableView.isEditing, height: heightOfTableView)
        }

    }
    
    func groupTitleOfSection(_ section: Int) -> String {

        let groupTitles = NKCoreDataCachedVideo.sharedInstance.getGroupTitles()
        if  section < groupTitles.count {
            
            if let title = self.groupTitles()[section].title {
                return title
            }
            return ""
        }

        return ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groupTitles().count
    }
    
    
    // MARK: - UITableView edit to sort
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none;
    }
    
    // prevent indendation related to delete action required space
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false;
    }
    
    // allow cell to be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    // allow cell to be moved
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    // func called when cell has been moved
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // 같으면 처리 안함.
        if sourceIndexPath == destinationIndexPath {
            return
        }

        if let sourceGroupTitle = self.groupTitles()[sourceIndexPath.section].title, let videos = self.cachedVideoList[sourceGroupTitle] {
            
            let video = videos[sourceIndexPath.row]
            let destinationGroupTitle = self.groupTitles()[destinationIndexPath.section].title!
            NKOrderManager.sharedInstance.changeGroup(video, groupTitle: destinationGroupTitle, indexPath: destinationIndexPath, complete: { (isSuccess) in
                
                if isSuccess {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "changeVideoStatus"), object: nil)
                    self.updateVideoList()
                    KLog("정렬모드 정렬 성공")
                } else {
                    KLog("정렬모드 정렬 실패!")
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return heightOfSection
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cachedGroup = groupTitles()[section]

        let groupView = NKGroupView(frame: CGRect.zero)
        if let title = cachedGroup.title, let _ = cachedVideoList[cachedGroup.title!] {
            groupView.setTitle(title)
            groupView.isEditing(self.cacheTableView.isEditing)
        }
        
        groupView.completeBlock = { (groupTitle: String) in

            let oldTitle = cachedGroup.title!
            
            NKCoreDataCachedVideo.sharedInstance.updateGroupTitle(oldTitle, newTitle: groupTitle)
            // 코어데이터에 저장
            if let videos = self.cachedVideoList[oldTitle] {
                for video in videos {
                    video.group = groupTitle
                }
            }
            NKCoreDataManager.sharedInstance.saveContext({ (isSuccess) -> Void in
                if isSuccess {
                    KLog("성공!")
                } else {
                    KLog("실패!")
                }
                self.cachedVideoList = self.cachedGroupedVideoList()

            })
        }
        
        groupView.deleteBlock = { (groupTitle: String) in
            NKOrderManager.sharedInstance.removeGroup(groupTitle, complete: { (isSuccess) in
                if isSuccess {
                    self.updateVideoList()
                } else {
                    KLog("삭제 실패!")
                }
 
            })
        }
        
        // MARK: - 그룹 열고 닫기
        groupView.toggleBlock = { (groupTitle: String) in

            if let flag = self.openCloseManager[groupTitle] as? Bool {
                // 열림
                if flag == true {
                    self.cachedVideoList[groupTitle] = []
                    self.openCloseManager[groupTitle] = false as AnyObject?
                } else {
                    if let backVideos = self.backupedVideoList[groupTitle] {
                        self.cachedVideoList[groupTitle] = backVideos
                        self.openCloseManager[groupTitle] = true as AnyObject?
                    }
                }

                self.notifyTotalHeight()

                if let index = self.indexForGroupTitle(groupTitle) {
                    self.cacheTableView.beginUpdates()
                    self.cacheTableView.reloadSections(IndexSet(integer: index), with: .none)
                    self.cacheTableView.endUpdates()
                }
                
                
            }
        }
        
        return groupView
    }
    
    func indexForGroupTitle(_ groupTitle: String) -> Int? {
        
        let groupTitles = self.groupTitles()
        for i in 0..<groupTitles.count {
            let obj = groupTitles[i]
            if let title = obj.title {
                if title == groupTitle {
                    return i
                }
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let groupTitle = self.groupTitles()[section].title!
        if let videos = cachedVideoList[groupTitle] {
            return videos.count
        } else {
            return 0
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NKCachedVideoListCell = self.cacheTableView.dequeueReusableCell(withIdentifier: "cachedVideoCell", for: indexPath) as! NKCachedVideoListCell
        
        let groupTitle = self.groupTitles()[indexPath.section].title!
        if let videos = self.cachedVideoList[groupTitle] {
            let video = videos[indexPath.row]
            
            cell.setCachedVideoCellData(video)
            cell.deleteBlock = { () in
                self.updateVideoList()
            }
            cell.showsReorderControl = true
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return NKCachedVideoListCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let group = self.groupTitleOfSection(indexPath.section)
        if let videos = self.cachedVideoList[group] {
            let video = videos[indexPath.row]
            NKAVAudioManager.sharedInstance.startPlay(video)
        }
    }

}
