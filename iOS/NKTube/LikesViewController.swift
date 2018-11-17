//
//  LikesViewController.swift
//  NKTube
//
//  Created by GiBong Kim on 2018/11/17.
//  Copyright © 2018 GibongKim. All rights reserved.
//

import UIKit

class LikesViewController: NKSuperVideoListViewController, MainViewCommonProtocol {
    
    private var videos: [Video] = []
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
    
    
    private func fetch() {
        
        if let likeId = NKUserInfo.shared.likesId {
            var parameters: [String: Any] = ["part": "contentDetails",
                                             "playlistId": likeId,
                                             "maxResults": maxResults]
            // nextPageToken이 있으면 페이징 처리.
            if let nextPageToken = self.nextPageToken {
                parameters["pageToken"] = nextPageToken
            }
            
            NKLoadingView.showLoadingView(.youtubeMenuGood)
            YouTubeService2.shared.getLikesForMe(param: parameters) { (result, nextPageToken, error) in
                NKLoadingView.hideLoadingView(.youtubeMenuGood)

                DispatchQueue.main.async {

                    guard let videos = result?.videos else {
                        return
                    }
                    self.videos += videos
                    self.olTableView.reloadData()
                }
            }
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
        
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NKVideoListCell = self.olTableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! NKVideoListCell
        let video = videos[indexPath.row]
        let oldVideo = NKVideo.init(video)
        cell.setVideoCellData(oldVideo, location: (token == nil || token == "") ? .youtubeRecommand : .youtubePopular)
        
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
        let oldVideo = NKVideo.init(video)
        NKAVAudioManager.sharedInstance.startPlay(oldVideo)
    }
    
    
    
}
