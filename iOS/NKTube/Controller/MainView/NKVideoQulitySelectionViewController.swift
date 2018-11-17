//
//  NKVideoQulitySelectionViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/07/17.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

protocol NKVideoQulitySelectionViewControllerDelegate {
    func didSelectVideoQulity()
}

class NKVideoQulitySelectionViewController: UIViewController {
    
    var delegate: NKVideoQulitySelectionViewControllerDelegate?
    
    @IBOutlet weak var olTableView: UITableView!
    @IBOutlet weak var olTableHeight: NSLayoutConstraint!
    @IBOutlet var olBottomMargin: NSLayoutConstraint!
    
    let settingMenus: [String] = ["240p", "360p", "720HD"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0.0
        
        NKFlurryManager.sharedInstance.viewForSettingList()
    }
    
    func load() {
        AppDelegate.mainVC()?.removeGesture()
        
        if let containerVC = AppDelegate.mainVC() {
            containerVC.addChildViewController(self)
            containerVC.view.addSubview(self.view)
            self.view.layoutIfNeeded()

            UIView.animate(withDuration: aniDuration, animations: {
                self.view.alpha = 1.0
                self.olBottomMargin.constant = 0
                self.view.layoutIfNeeded()
                }, completion: { (finish) in
            })
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: aniDuration, animations: {
            self.view.alpha = 0.0
        }, completion: { (finish) in
            AppDelegate.mainVC()?.registerGesture()
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }) 
    }
    
    
    @IBAction func tagGestureAction(_ sender: AnyObject) {
        dismiss()
    }
    
    
    // MARK: - UITableViewDelegate, DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingMenus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NKSettingListCell = olTableView.dequeueReusableCell(withIdentifier: "settingListCell") as! NKSettingListCell
        cell.olTitleLabel.text = settingMenus[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return NKSettingListCell.heightCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let qulity = settingMenus[indexPath.row]
        switch qulity {
        case "240p":
            NKUserInfo.shared.videoQulity = NKVideoQulity.Small240
        case "360p":
            NKUserInfo.shared.videoQulity = NKVideoQulity.Medium360
        case "720HD":
            NKUserInfo.shared.videoQulity = NKVideoQulity.HD720
        default:
            break
        }
        
        if let delegate = delegate {
            delegate.didSelectVideoQulity()
        }
        dismiss()
    }
    
}
