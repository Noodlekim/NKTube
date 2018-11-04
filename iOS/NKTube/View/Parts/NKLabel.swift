//
//  NKLabel.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/08.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKLabel: UILabel {

    // paddingの値
    let padding = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
    
    override func drawText(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }
    
    override var intrinsicContentSize : CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height += padding.top + padding.bottom
        intrinsicContentSize.width += padding.left + padding.right
        return intrinsicContentSize
    }
}
