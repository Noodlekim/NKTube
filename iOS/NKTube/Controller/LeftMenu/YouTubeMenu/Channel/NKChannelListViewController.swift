//
//  NKChannelListViewController.swift
//  NKTube
//
//  Created by GibongKim on 2016/04/10.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKChannelListViewController: UIViewController, MainViewCommonProtocol {

    @IBOutlet weak var olTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        NKFlurryManager.sharedInstance.viewForYouTubeMenuChannelList()

        // 네비게이션 커스터마이징
        navigationItem.leftBarButtonItem = NKStyle.backButtonItem(self.navigationController!)
        navigationItem.titleView = NKStyle.navititleLabel("チャンネル一覧")
    }
    
    // MARK: - MainViewCommonProtocol
    
    func doScrollToTop() {
        olTableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func doNeedToReload() {
        olTableView.reloadData()
    }

    /*
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setEmptyBackButton()
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
//        if let channelDetailViewController = segue.destination as? NKChannelDetailViewController {
//
//            if let item = sender as? MABYT3_Subscription {
//                channelDetailViewController.channelId = item.snippet.resourceId.channelId
//            }
//        }
    }
    
    private func fetchSubscriptions() {
        
        let param: [String: Any] = ["part": "id,snippet,contentDetails",
                                    "mine": true,
                                    "maxResults": 30]

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
        
        return userCredentials!.ytSubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let item: MABYT3_Subscription = userCredentials!.ytSubs[indexPath.row] as! MABYT3_Subscription
        
        let cell: NKChannelCell = olTableView.dequeueReusableCell(withIdentifier: "channelCell") as! NKChannelCell
        cell.setData(item.snippet)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return NKChannelCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item: MABYT3_Subscription = userCredentials!.ytSubs[indexPath.row] as! MABYT3_Subscription        
        performSegue(withIdentifier: "showChannelDetail", sender: item)
    }
     */
}
