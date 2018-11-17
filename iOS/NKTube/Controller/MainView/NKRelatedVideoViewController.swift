//
//  NKRelatedVideoViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/04.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class NKRelatedVideoViewController: NKSuperVideoListViewController, NKVideoDescriptionViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var relatedVideos: [NKVideo] = []
    var relatedVideoId: String?
    var relatedVideo: VideoProtocol?
    var headerView: NKVideoDescriptionView?
    let token = {
        NKUserInfo.shared.accessToken // TODO: 이거 토큰 갱신 같이 되는지 확인해야됨.
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 셀등록
        olTableView.registerCell("NKVideoListCell", cellId: "videoCell")
        olTableView.emptyDataSetDelegate = self
        olTableView.emptyDataSetSource = self
        
        if token == nil || token == "" {
            loadPopularVideos()
        } else {
            loadRecommandVideos()
        }
        
        if let view = olTableView.tableHeaderView as? NKVideoDescriptionView {
            headerView = view
            headerView?.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        headerView!.frame.size.height = 0
        olTableView.tableHeaderView = headerView!
    }

    func loadRecommandVideos() {
        
        if let token = NKUserInfo.shared.accessToken {

            NKLoadingView.showLoadingView(.playVideoViewUnder)
            NKYouTubeService.sharedInstance.getRecommandVideos(token, nextPageToken: nextPageToken, completion: { (videos, nextPageToken, error, canPaging) in

                if nextPageToken == nil {
                    self.relatedVideos = []
                }

                KLog("videos >> \(videos)" as AnyObject?)
                for video in videos {
                    self.relatedVideos.append(video)
                }
                self.nextPageToken = nextPageToken
                self.canPaging = canPaging
                self.olTableView.reloadData()
                NKLoadingView.hideLoadingView(.playVideoViewUnder)
            })
        }
    }
    
    func loadPopularVideos() {
        
        NKLoadingView.showLoadingView(.playVideoViewUnder)
        NKYouTubeService.sharedInstance.getPopularVideos(nextPageToken) { (videos, nextPageToken, error, canPaging) in

            if nextPageToken == nil {
                self.relatedVideos = []
            }
            KLog("videos >> \(videos)" as AnyObject?)
            for video in videos {
                self.relatedVideos.append(video)
            }
            self.nextPageToken = nextPageToken
            self.canPaging = canPaging
            self.olTableView.reloadData()
            NKLoadingView.hideLoadingView(.playVideoViewUnder)
        }
    }
    

    // MARK: - 관련 비디오 리스트 로드?
    func getDescriptionAndRelatedVideos(_ video: VideoProtocol) {
        olTableView.setContentOffset(CGPoint.zero, animated: true)
        fetch(video.commonId!, nextPageToken: nil)
        headerView!.loadVideoDescription(video)
    }
    
    func setOnlyDescription(_ video: VideoProtocol) {
        headerView!.loadVideoDescription(video)
    }
    
    func setOnlyRelatedVideos(_ video: VideoProtocol) {
        olTableView.setContentOffset(CGPoint.zero, animated: true)
        fetch(video.commonId!, nextPageToken: nil)
    }

    func fetch(_ videoId: String, nextPageToken: String?) {
        
        if nextPageToken == nil {            
            self.completedPageTokens = []
            self.relatedVideos = []
        }
        self.relatedVideoId = videoId

        NKLoadingView.showLoadingView(.playVideoViewUnder)
        NKYouTubeService.sharedInstance.getRelatedVideoIds(videoId, nextPage: nextPageToken) { (videos, pageToken, error, canPaging) in
            
            if nextPageToken == nil || nextPageToken == "" {
                self.relatedVideos = []
                self.nextPageToken = nil
                self.canPaging = true
            }
            
            self.nextPageToken = pageToken
            
            if let videos = videos {
                for video in videos {
                    self.relatedVideos.append(video)
                }
                self.nextPageToken = pageToken
                self.canPaging = canPaging
            }
            self.olTableView.reloadData()
            NKLoadingView.hideLoadingView(.playVideoViewUnder)

        }
    }
        
    // MARK: - UITableViewDelegate, DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if relatedVideos.count == 0 {
            return 1
        }
        return relatedVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        if relatedVideos.count == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "default")
            cell.backgroundColor = UIColor.clear
            return cell
        }

        
        let cell: NKVideoListCell = self.olTableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! NKVideoListCell
        let video = relatedVideos[indexPath.row]
        video.indexPath = indexPath
        if token == nil || token == "" {
            cell.setVideoCellData(video, location: .centerPopular)
        } else {
            cell.setVideoCellData(video, location: .centerRecommand)
        }
        
        // 페이징
        if indexPath.row > relatedVideos.count-3 && canPaging {
            if let nextPageToken = nextPageToken {
                if !completedPageTokens.contains(nextPageToken) {
                    completedPageTokens.append(nextPageToken)
                    if let relatedVideoId = relatedVideoId {
                        fetch(relatedVideoId, nextPageToken: nextPageToken)
                    } else {
                        if token == nil || token == "" {
                            loadPopularVideos()
                        } else {
                            loadRecommandVideos()
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if relatedVideos.count == 0 {
            return 0
        }

        return NKVideoListCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = self.relatedVideos[indexPath.row]
        NKAVAudioManager.sharedInstance.startPlay(video)
        
        if token == nil || token == "" {
            NKFlurryManager.sharedInstance.actionForPlayVideoOnCenterPopular(video)
        } else {
            NKFlurryManager.sharedInstance.actionForPlayVideoOnCenterRecommand(video)
        }
    }
    
    // MARK: - NKVideoDescriptionViewDelegate
    func changeHeight(_ isInt: Bool, height: CGFloat) {
        let header = olTableView.tableHeaderView
        header!.frame.size.height = height
        olTableView.tableHeaderView = header
        olTableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
}
