//
//  NKMacro.swift
//  NKTube
//
//  Created by GibongKim on 2016/01/19.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKMacro: NSObject {

}

func KLog(_ obj: Any?,
    function: String = #function,
    line: Int = #line) {
        #if DEBUG
            print("[Func:\(function) Line:\(line)] : \(obj)")
        #endif
}

