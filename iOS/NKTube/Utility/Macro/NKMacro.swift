//
//  NKMacro.swift
//  NKTube
//
//  Created by NoodleKim on 2016/01/19.
//  Copyright © 2016年 NoodleKim. All rights reserved.
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

