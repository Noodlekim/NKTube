//
//  NKAlertManager.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/14.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKAlertManager: NSObject {

    static let appDelegate = UIApplication.shared.delegate
    static let alertFrame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
    
    class func showFinishDownloadAlert(_ video: NKVideo) {
    
        let window = appDelegate!.window!!.rootViewController!.view
        let alertView = NKAlertView(frame: alertFrame)
        alertView.setData(video)
        
        alertView.frame.origin.y = (window?.frame.height)!
        window?.addSubview(alertView)
        
        UIView.animate(
            withDuration: aniDuration,
            delay: 0.3,
            options: .allowUserInteraction,
            animations: { () -> Void in
                alertView.frame.origin.y = (window?.frame.height)! - alertView.frame.height
            }
            ) { _ in
                
                let delay = 2.0 * Double(NSEC_PER_SEC)
                let time  = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    UIView.animate(
                        withDuration: aniDuration,
                        delay: 0.0,
                        options: .allowUserInteraction,
                        animations: { () -> Void in
                            alertView.frame.origin.y = (window?.frame.height)!
                        }
                        ) { _ in
                            alertView.removeFromSuperview()
                    }
                })
        }
        


    }
}
