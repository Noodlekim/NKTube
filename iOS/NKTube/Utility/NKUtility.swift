//
//  NKUtility.swift
//  NKTube
//
//  Created by GibongKim on 2016/02/23.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import MBProgressHUD

class NKUtility: NSObject {

    class func showMessage(_ onView: UIView = (UIApplication.shared.delegate!.window!?.rootViewController?.view)!, message: String, fontSize: CGFloat = 12, delay: TimeInterval = 1.0, animate: Bool = true) {
        
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: onView, animated: true)
            hud.mode = .text
            hud.labelText = message
            hud.labelFont = UIFont.boldSystemFont(ofSize: fontSize)
            hud.hide(true, afterDelay: delay)
        }
    }
    
    class func viewAnimation(_ animation: @escaping (() -> Void)) {
        UIView.animate(withDuration: aniDuration, animations: animation, completion: nil)
    }
    
}
