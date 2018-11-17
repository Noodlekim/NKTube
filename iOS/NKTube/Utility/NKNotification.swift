//
//  NKNotification.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/08.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import Foundation
import UIKit

class NKNotification {
    
    static var sharedInstance = NKNotification()

    func postLocalNotification(_ body: String, userInfo: [AnyHashable: Any]? = nil) {
            
        if UIApplication.shared.applicationState != .active {
            // Notificationの生成する.
            let notification = UILocalNotification()
            notification.alertBody = body
            notification.userInfo = userInfo
            notification.timeZone = TimeZone.current
            notification.soundName = "densi.mp3"
            UIApplication.shared.scheduleLocalNotification(notification)
        }

    }
    
    
}
