//
//  NKStyle.swift
//  NKTube
//
//  Created by GibongKim on 2016/06/20.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKStyle {

    class func RGB(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    static let defaultTextColor: UIColor = NKStyle.RGB(76, green: 76, blue: 76)
    static let lightTextColor: UIColor = NKStyle.RGB(179, green: 177, blue: 175)
    static let bluishGreenColor: UIColor = NKStyle.RGB(191, green: 188, blue: 209)

    
    class func backButtonItem(_ target: AnyObject) -> UIBarButtonItem {
        let actionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        actionButton.addTarget(target, action: #selector(UINavigationController.popViewController(animated:)), for: .touchUpInside)
        actionButton.contentHorizontalAlignment = .left
        actionButton.setImage(UIImage(named: "icon_back_arrow"), for: UIControlState())
        actionButton.backgroundColor = UIColor.clear
        return UIBarButtonItem(customView: actionButton)
    }
    
    class func navititleLabel(_ title: String) -> UILabel {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = NKStyle.defaultTextColor
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = title
        return titleLabel
    }

}
