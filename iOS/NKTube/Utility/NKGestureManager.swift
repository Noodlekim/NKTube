//
//  NKGestureManager.swift
//  NKTube
//
//  Created by NoodleKim on 2016/02/28.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKGestureManager: NSObject {
    
    var mainViewController: NKMainViewController?
    var movieViewController: NKMoviePlayerViewController?
    
    static var sharedInstance = NKGestureManager()
}
