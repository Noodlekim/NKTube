//
//  NKSplitviewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/06/05.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKSplitviewController: UIViewController {

    @IBOutlet weak var olTableView: UITableView!
    
    let cellHeight: CGFloat = 40.0
    var groupList: [GroupTitle] = []
    var position: CGPoint?
    var video: CachedVideo?
    
    var checkmarkImage: UIImageView?
    @IBOutlet weak var olTableHeight: NSLayoutConstraint!
    @IBOutlet var olBottomMargin: NSLayoutConstraint!
    
    
    convenience init(position: CGPoint) {
        
        self.init()
        self.position = position
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0.0
        
        let accessary = UIImageView()
        accessary.image = UIImage(named: "icon_check_mark")
        accessary.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        accessary.contentMode = UIViewContentMode.center
        checkmarkImage = accessary
    }
    
    func load(_ position: CGPoint, video: CachedVideo) {
        AppDelegate.mainVC()?.removeGesture()
        
        self.video = video
        self.position = position
        
        if let containerVC = AppDelegate.mainVC() {
            containerVC.addChildViewController(self)
            containerVC.view.addSubview(self.view)

            self.loadGroupList(position)

            UIView.animate(withDuration: aniDuration, animations: {
                self.view.alpha = 1.0
                self.olBottomMargin.constant = 0
                self.view.layoutIfNeeded()
                }, completion: { (finish) in
            })            
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: aniDuration, animations: {
            self.view.alpha = 0.0
        }, completion: { (finish) in
            AppDelegate.mainVC()?.registerGesture()
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }) 
    }
    
    @IBAction func acLink(_ sender: AnyObject) {
        
        if let video = self.video, let videoId = video.videoId {
            let board = UIPasteboard.general
            board.setValue("https://www.youtube.com/watch?v=\(videoId)", forPasteboardType: "public.text")
            NKUtility.showMessage(message: "コピーされました")
        } else {
            NKUtility.showMessage(message: "コピー失敗しました")
        }
    }
    
    @IBAction func acDelete(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "削除", message: "この動画を削除しますか？", preferredStyle: .alert)
        let okButton: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            if let video = self.video, let videoId = video.videoId {
                if NKFileManager.deleteCachedFile(videoId) {
                    if #available(iOS 9.0, *) {
                        NKCoreDataCachedVideo.sharedInstance.removeCachedVideoForSpotlight(video)
                    }
                    // 삭제시엔 순서 재정렬 해줄 필요가 없음.
                    NKVideoStatusManager.sharedInstance.didRemoveCahceVideo(video, complete: { (isSuccess) in
                        isSuccess ? KLog("파일 삭제 성공!" as AnyObject?) : KLog("파일 삭제 실패!" as AnyObject?)
                    })
                    self.dismiss()
                } else {
                    KLog("파일 삭제 실패!" as AnyObject?)
                }
            }
        })
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        if let mainVC = AppDelegate.mainVC() {
            mainVC.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func loadGroupList(_ position: CGPoint) {
        groupList = NKCoreDataCachedVideo.sharedInstance.getGroupTitles()
        var height = cellHeight*CGFloat(groupList.count)
        // 표시된 위치에서 화면사이즈를 넘어가지 않게 조절(마진은 20px)
        let limit = UIScreen.main.bounds.height - 212 - 20 - 60
        if height > limit {
            height = limit
        }

        olTableHeight.constant = height
        olBottomMargin.constant = -olTableHeight.constant-60
        self.view.layoutIfNeeded()

        olTableView.reloadData()
    }


    @IBAction func tagGestureAction(_ sender: AnyObject) {

        dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDelegate, DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NKSplitGroupCell = olTableView.dequeueReusableCell(withIdentifier: "splitGroupCell") as! NKSplitGroupCell
        
        let item = groupList[indexPath.row]
        cell.olGroupTitle.text = item.title
        
        if item.title == video!.group {
            cell.accessoryView = checkmarkImage
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 그룹변경
        let item = groupList[indexPath.row]
        self.video!.group = item.title
        NKCoreDataManager.sharedInstance.saveContext { (isSuccess) in
            
            if isSuccess {
                self.olTableView.reloadData()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "changeVideoStatus"), object: nil)
            }
        }
    }
    
}
