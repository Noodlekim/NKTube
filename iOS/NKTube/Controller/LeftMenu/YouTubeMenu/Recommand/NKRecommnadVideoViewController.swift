//
//  NKRecommnadVideoViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/06/12.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKRecommnadVideoViewController: NKSuperVideoListViewController, MainViewCommonProtocol {
    
    
    var relatedVideos: [NKVideo] = []
    var relatedVideoId: String?
    let token = NKUserInfo.shared.accessToken

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        // 네비게이션 커스터마이징
        navigationItem.leftBarButtonItem = NKStyle.backButtonItem(self.navigationController!)
        navigationItem.titleView = NKStyle.navititleLabel((token == nil || token == "") ? "人気動画" : "オススメ")

        olTableView.registerCell("NKVideoListCell", cellId: "videoCell")
        fetch()
    }
    
    override func viewWillLayoutSubviews() {
        olTableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setEmptyBackButton()
    }
    
    fileprivate func fetch() {
        if token == nil || token == "" {
            loadPopularVideos()
            NKFlurryManager.sharedInstance.viewForYoutubeMenuPopularVideos()
        } else {
            loadRecommandVideos()
            NKFlurryManager.sharedInstance.viewForYoutubeMenuRecommandVideos()
        }
    }

    
    func loadRecommandVideos() {
        if let token = NKUserInfo.shared.accessToken {
            NKLoadingView.showLoadingView(.youtubeMenuRecommand)
            NKYouTubeService.sharedInstance.getRecommandVideos(token, nextPageToken: nextPageToken, completion: { (videos, nextPageToken, error, canPaging) in
                
                KLog("videos >> \(videos)")
                for video in videos {
                    self.relatedVideos.append(video)
                }
                self.nextPageToken = nextPageToken
                self.canPaging = canPaging
                self.olTableView.reloadData()
                NKLoadingView.hideLoadingView(.youtubeMenuRecommand)
            })
        }
    }
    
    func loadPopularVideos() {
        NKLoadingView.showLoadingView(.youtubeMenuPopular)
        NKYouTubeService.sharedInstance.getPopularVideos(nextPageToken) { (videos, nextPageToken, error, canPaging) in
            KLog("videos >> \(videos)")
            for video in videos {
                self.relatedVideos.append(video)
            }
            self.nextPageToken = nextPageToken
            self.canPaging = canPaging
            self.olTableView.reloadData()
            NKLoadingView.hideLoadingView(.youtubeMenuPopular)
        }
    }


    // MARK: - MainViewCommonProtocol
    
    func doScrollToTop() {
        olTableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func doNeedToReload() {
        olTableView.reloadData()
    }

    
    // MARK: - UITableViewDelegate, DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return relatedVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
    
        let cell: NKVideoListCell = self.olTableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! NKVideoListCell
        let video = relatedVideos[indexPath.row]
        video.indexPath = indexPath        
        cell.setVideoCellData(video, location: (token == nil || token == "") ? .youtubeRecommand : .youtubePopular)

        // 페이징
        if indexPath.row > relatedVideos.count-3 && canPaging {
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
        
        let video = relatedVideos[indexPath.row]
        
        if token == nil || token == "" {
            NKFlurryManager.sharedInstance.actionForPlayVideoOnYoutubeMenuPopular(video)
        } else {
            NKFlurryManager.sharedInstance.actionForPlayVideoOnYoutubeMenuRecommand(video)
        }
        NKAVAudioManager.sharedInstance.startPlay(video)
    }

    
    
}
