//
//  NKAboutThisAppViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/07/19.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKAboutThisAppViewController: UIViewController {

    @IBOutlet var olVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let version: NSString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String as NSString
        olVersionLabel.text = "v"+(version as String)
    }

    func load() {
        AppDelegate.mainVC()?.removeGesture()
        
        if let containerVC = AppDelegate.mainVC() {
            containerVC.addChildViewController(self)
            containerVC.view.addSubview(self.view)
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: aniDuration, animations: {
                self.view.alpha = 1.0
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

}
