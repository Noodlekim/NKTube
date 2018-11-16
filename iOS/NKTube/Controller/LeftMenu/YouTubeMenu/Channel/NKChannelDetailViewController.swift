//
//  NKChannelDetailViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/04/10.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class NKChannelDetailViewController: NKSuperVideoListViewController, MainViewCommonProtocol, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var channelId: String?
//    let userCredentials = MAB_GoogleUserCredentials.sharedInstance()
    var channelItems: [NKVideo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 커스터마이징
        navigationItem.leftBarButtonItem = NKStyle.backButtonItem(self.navigationController!)
        navigationItem.titleView = NKStyle.navititleLabel("チャンネル詳細")

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        olTableView.registerCell("NKVideoListCell", cellId: "videoCell")
        olTableView.emptyDataSetDelegate = self
        olTableView.emptyDataSetSource = self

        fetch()
        NKFlurryManager.sharedInstance.viewForYoutubeMenuChannelDetail()
    }
    
    override func viewWillLayoutSubviews() {
        olTableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setEmptyBackButton()
    }
    
    fileprivate func fetch() {
        
        if let channelId = channelId {
            NKLoadingView.showLoadingView(true, type: .youtubeMenuChannel)
            // TODO: 이런것도 결국 공통부분인데... 다 묶을 수 있다면 묶고 싶음.
            NKYouTubeService.sharedInstance.getChannelSections(channelId, nextPageToken: nextPageToken, complete: { (videos, nextPageToken, error, canPaging) in
                //                KLog("videos >>>> \(videos)")
                for viedo in videos {
                    self.channelItems.append(viedo)
                }
                self.nextPageToken = nextPageToken
                self.canPaging = canPaging
                
                self.olTableView.reloadData()
                NKLoadingView.hideLoadingView(.youtubeMenuChannel)
            })
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        return channelItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let video = channelItems[indexPath.row]
        
        let cell: NKVideoListCell = olTableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! NKVideoListCell
        video.indexPath = indexPath
        cell.setVideoCellData(video, location: .youtubeChannel)
        
        // 페이징
        if indexPath.row > channelItems.count-3 && canPaging {
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
        
        return NKChannelDetailCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = channelItems[indexPath.row]
        NKFlurryManager.sharedInstance.actionForPlayVideoOnYoutubeMenuChannel(video)
        NKAVAudioManager.sharedInstance.startPlay(video)
    }

}
