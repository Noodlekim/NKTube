//
//  NKChannelListViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/04/10.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKChannelListViewController: UIViewController {

    @IBOutlet weak var olTableView: UITableView!
    
    var channels: [Channel] = []
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: false)

        // 네비게이션 커스터마이징
        navigationItem.leftBarButtonItem = NKStyle.backButtonItem(self.navigationController!)
        navigationItem.titleView = NKStyle.navititleLabel("チャンネル一覧")
        
        fetch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let channelDetailViewController = segue.destination as? NKChannelDetailViewController {
            
            if let channel = sender as? Channel {
                channelDetailViewController.channelId = channel.channelId
            }
        }
    }

    private func fetch() {
        
        let param: [String: Any] = ["part": "id,snippet,contentDetails",
                                    "mine": true,
                                    "maxResults": 30]
        
        YouTubeService2.shared.getSubscriptions(param: param) { (subscription, error) in
            
            if let error = error {
                switch error {
                case .successRefreshToken:
                    self.fetch()
                default: break
                }
                return
            }
            
            guard let subscription = subscription, let channels = subscription.channels else {
                return
            }
            
            self.channels = channels
            self.olTableView.reloadData()
        }
    }
}

// MARK: - MainViewCommonProtocol

extension NKChannelListViewController: MainViewCommonProtocol {
    
    func doScrollToTop() {
        olTableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func doNeedToReload() {
        olTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, DataSource

extension NKChannelListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let channel = channels[indexPath.row]
        let cell: NKChannelCell = olTableView.dequeueReusableCell(withIdentifier: "channelCell") as! NKChannelCell
        cell.setData(channel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return NKChannelCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: "showChannelDetail", sender: channel)
    }

}
