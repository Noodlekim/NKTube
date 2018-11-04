//
//  NKWatchAfterViewController.swift
//  NKTube
//
//  Created by GibongKim on 2016/04/10.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class NKWatchAfterViewController: NKSuperVideoListViewController, MainViewCommonProtocol, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    let userCredentials = MAB_GoogleUserCredentials.sharedInstance()
    var playListId: String?
    var videos: [NKVideo] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 네비게이션 커스터마이징
        navigationItem.leftBarButtonItem = NKStyle.backButtonItem(self.navigationController!)
        navigationItem.titleView = NKStyle.navititleLabel("後で見る")

        navigationController?.setNavigationBarHidden(false, animated: true)
        setEmptyBackButton()
        olTableView.registerCell("NKVideoListCell", cellId: "videoCell")
        olTableView.emptyDataSetDelegate = self
        olTableView.emptyDataSetSource = self

        fetch()
        NKFlurryManager.sharedInstance.viewForYoutubeMenuWatchAfter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func fetch() {
        
        guard let playListId = playListId, let token = userCredentials?.token.accessToken else {
            return
        }
        NKLoadingView.showLoadingView(true, type: .youtubeMenuWatchAfter)
        isPaging = true
        NKYouTubeService.sharedInstance.getWatchLater(token, playlistId: playListId, nextPageToken: nextPageToken, completion: { (videos, nextPageToken, error, canPaging) in
            KLog("videos >> \(videos)" as AnyObject?)
            for video in videos {
                self.videos.append(video)
            }
            self.nextPageToken = nextPageToken
            self.canPaging = canPaging
            self.olTableView.reloadData()
            NKLoadingView.hideLoadingView(.youtubeMenuWatchAfter)
            self.isPaging = false
        })
    }

    
    
    // MARK: - MainViewCommonProtocol

    func doScrollToTop() {
        olTableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func doNeedToReload() {
        olTableView.reloadData()
    }

    
    // MARK: - DZNEmptyDataSetSource
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        
        return UIImage(named: "empty_default")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {        
        return NSAttributedString(string: "今日も頑張りましょう！")
    }

    
    // MARK: -
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    
    // MARK: - UITableViewDelegate, DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let video = videos[indexPath.row]
        let cell: NKVideoListCell = self.olTableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! NKVideoListCell
        video.indexPath = indexPath
        cell.setVideoCellData(video, location: .youtubeWatchAfter)

        // 페이징
        if indexPath.row > videos.count-3 && canPaging {
            if let nextPageToken = nextPageToken {
                if !completedPageTokens.contains(nextPageToken) {
                    completedPageTokens.append(nextPageToken)
                    fetch()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return NKVideoListCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = videos[indexPath.row]
        // 재생 로그
        NKFlurryManager.sharedInstance.actionForPlayVideoOnYoutubeMenuWatchAfter(video)
        NKAVAudioManager.sharedInstance.startPlay(video)
    }

}
