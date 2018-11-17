//
//  NKFavoriteMoviesViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/04/10.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKFavoriteMoviesViewController: NKSuperVideoListViewController {
    
    var playListId: String?
    var videos: [NKVideo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        // 네비게이션 커스터마이징
        navigationItem.leftBarButtonItem = NKStyle.backButtonItem(self.navigationController!)
        navigationItem.titleView = NKStyle.navititleLabel("お気に入り")
        
        self.setEmptyBackButton()
        olTableView.registerCell("NKVideoListCell", cellId: "videoCell")
        
        fetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setEmptyBackButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func fetch() {
        
        let param: [String: Any] = [
            "part": "id,snippet,contentDetails,status,topicDetails",
            "mine": "true"
        ]

        YouTubeService2.shared.getUserRelatedPlaylists(param: param, completion: { (relatedPlaylists, error) in
            if let relatedPlaylists = relatedPlaylists {
                
                if let favorites = relatedPlaylists.favorites {
                }
//                if let likes = relatedPlaylists.likes {
//                    UserInfos.likes.set(value: likes)
//                }
//                if let uploads = relatedPlaylists.uploads {
//                    UserInfos.uploads.set(value: uploads)
//                }
            }
        })

    }
}

// MARK: - MainViewCommonProtocol

extension NKFavoriteMoviesViewController: MainViewCommonProtocol {
    
    func doScrollToTop() {
        olTableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func doNeedToReload() {
        olTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, DataSource

extension NKFavoriteMoviesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let video = videos[indexPath.row]
        let cell: NKVideoListCell = self.olTableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! NKVideoListCell
        video.indexPath = indexPath
        
        cell.setVideoCellData(video, location: .youtubeGood)
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return NKFavoriteCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = videos[indexPath.row]
        NKFlurryManager.sharedInstance.actionForPlayVideoOnYouTubeMenuGood(video)
        NKAVAudioManager.sharedInstance.startPlay(video)
    }

}
