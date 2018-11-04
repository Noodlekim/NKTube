//
//  NKCreatingGroupViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/12.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

protocol NKCreatingGroupViewControllerDelegate {
    
    func dismissCreatingGroupView()
}

class NKCreatingGroupViewController: UIViewController {

    var delegate: NKCreatingGroupViewControllerDelegate?
    
    @IBOutlet weak var olTableView: UITableView!
    @IBAction func acCreateGroup(_ sender: AnyObject) {
        
        var selectedVideos: [CachedVideo] = []
        for i in 0..<selectedIndexs.count {
            let indexPath = selectedIndexs[i]
            if let group = groupTitles[indexPath.section].title, let videos = cachedVideoList[group] {
                let video = videos[indexPath.row]
                selectedVideos.append(video)
            }
        }
        NKOrderManager.sharedInstance.addVideosInGroup(selectedVideos, group: selectedGroupName!, complete: { (isSuccess) in
            if isSuccess {
                NKUtility.showMessage(message: "グループ作成成功")
                self.dismissView()
            }
        })
    }

    var selectedGroupName: String?
    var cachedVideoList: [String: [CachedVideo]] = [:]
    var selectedIndexs: [IndexPath] = []
    
    let heightOfSection: CGFloat = 45.0
    
    let groupTitles: [GroupTitle] = NKCoreDataCachedVideo.sharedInstance.getGroupTitles()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let actionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        actionButton.addTarget(self.navigationController!, action: #selector(UINavigationController.popViewController(animated:)), for: .touchUpInside)
        actionButton.contentHorizontalAlignment = .left
        actionButton.setImage(UIImage(named: "icon_back_arrow"), for: UIControlState())
        actionButton.backgroundColor = UIColor.clear
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: actionButton)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = NKStyle.defaultTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = "イージーグルーピング"
        navigationItem.titleView = titleLabel
        
        cachedVideoList = self.cachedGroupedVideoList()
        
    }
    
    func dismissView() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "completeCreatingGroup"), object: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NKSelectGroupViewController {
            var selectedCachedVideos: [CachedVideo] = []
            
            for indexPath in selectedIndexs {
                
                let groupTitle = self.groupTitles[indexPath.section].title!
                
                if let videos = self.cachedVideoList[groupTitle] {
                    let video = videos[indexPath.row]
                    selectedCachedVideos.append(video)
                }
            }
            vc.selectedVideos = selectedCachedVideos
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // TODO: 일단 그냥 그룹핑
    func cachedGroupedVideoList() -> [String: [CachedVideo]] {
        
        let videos = NKCoreDataCachedVideo.sharedInstance.getCachedVideoList()
        let groupArr: [GroupTitle] = self.groupTitles
        
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
            result[group] = groupedVideos
        }
        
        return result
    }
    
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return groupTitles.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return heightOfSection
    }
    

    func updateSelectedIndexPath(_ indexPath: IndexPath) {
        if selectedIndexs.contains(indexPath) {
            selectedIndexs.removeObj(indexPath)
        } else {
            selectedIndexs.append(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let groupTitle = self.groupTitles[section].title!
        if let videos = cachedVideoList[groupTitle] {
            return videos.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let groupTitle = self.groupTitles[indexPath.section].title!
        
        let cell: NKSelectionMovieCell = self.olTableView.dequeueReusableCell(withIdentifier: "selectionMovieCell") as! NKSelectionMovieCell

        if let videos = self.cachedVideoList[groupTitle] {
            let video = videos[indexPath.row]
            cell.setData(video)
        }
        
        if selectedIndexs.contains(indexPath) {
            let accessary = UIImageView()
            accessary.image = UIImage(named: "icon_check_mark")
            accessary.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            accessary.contentMode = UIViewContentMode.center

            cell.accessoryView = accessary//.Checkmark
        } else {
            cell.accessoryView = nil//.None
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
        container.backgroundColor = NKStyle.RGB(236, green: 236, blue: 233)

        let label = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.width, height: 45))
        label.backgroundColor = UIColor.clear
        label.textColor = NKStyle.RGB(112, green: 112, blue: 112)
        label.text = self.groupTitles[section].title
        label.font = UIFont.systemFont(ofSize: 14)
        container.addSubview(label)
        return container
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return NKCachedVideoListCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        updateSelectedIndexPath(indexPath)
         self.olTableView.reloadData()
    }


}
