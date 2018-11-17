//
//  NKCacheSearchViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/28.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKCacheSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate {

    // TODO: UISearchControllerに変更する
    @IBOutlet weak var olTopMarginSearchBar: NSLayoutConstraint!
    @IBOutlet weak var olSearchBar: UISearchBar!

    var cachedAllVideos: [CachedVideo]?
    var searchedVideos: [CachedVideo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchDisplayController?.searchResultsTableView.registerCell("NKCachedVideoListCell", cellId: "cachedVideoCell")
        self.searchDisplayController?.searchResultsTableView.separatorColor = UIColor.clear
        cachedAllVideos = NKCoreDataCachedVideo.sharedInstance.getCachedVideoList()
    }
    
    func loadCacheSearchView(_ containerView: UIView) {
        
        view.frame = containerView.bounds
        self.view.alpha = 0.0
        olSearchBar.becomeFirstResponder()

        UIView.animate(withDuration: aniDuration, animations: { () -> Void in
            self.view.alpha = 1.0
            self.view.layoutIfNeeded()
            }, completion: { (isFinish) -> Void in
        }) 
    }
    
    fileprivate func searchVideo(_ keyword: String) {
        searchedVideos = []
        for video in cachedAllVideos! {
            if let _ = video.title?.range(of: keyword) {
                searchedVideos.append(video)
            }
        }
        
    }
    
    fileprivate func dismissSearchView() {
        UIView.animate(withDuration: aniDuration, animations: { () -> Void in
            
            self.view.alpha = 0.0
            //            self.olTopMarginSearchBar.constant = -44
            self.view.layoutIfNeeded()
            
            }, completion: { (isFinish) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }) 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - UISearchDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchVideo(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        dismissSearchView()
    }

    // MARK: - UITableViewDelegate, DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchedVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let video = searchedVideos[indexPath.row]
        let cell: NKCachedVideoListCell = self.searchDisplayController?.searchResultsTableView.dequeueReusableCell(withIdentifier: "cachedVideoCell", for: indexPath) as! NKCachedVideoListCell
        cell.setCachedVideoCellData(video)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let video = searchedVideos[indexPath.row]
        NKAVAudioManager.sharedInstance.startPlay(video)
        if olSearchBar.isFirstResponder {
            olSearchBar.resignFirstResponder()
        }
        
    }
    
    func searchDisplayController(_ controller: UISearchDisplayController, willHideSearchResultsTableView tableView: UITableView) {
//        dismissSearchView()        
    }
    
    func searchDisplayControllerDidEndSearch(_ controller: UISearchDisplayController) {
        dismissSearchView()
    }
}
