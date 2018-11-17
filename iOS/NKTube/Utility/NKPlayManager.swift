//
//  NKPlayManager.swift
//  NKTube
//
//  Created by NoodleKim on 2016/02/18.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKPlayManager: NSObject {

    class func getCurrentPosition(_ totalWidth: CGFloat, totalTime: CGFloat, currentTime: CGFloat) -> CGFloat {
        
        if totalTime == 0 || currentTime == 0 {
            return 0
        }
        let currentPosition = (totalWidth*currentTime)/totalTime;
        return currentPosition
    }
    
    class func getCurrentTime(_ totalWidth: CGFloat, totalTime: CGFloat, currentPosition: CGFloat) -> CGFloat {
        
        let currentTime = (totalWidth*currentPosition)/totalTime

        return currentTime
    }
}
