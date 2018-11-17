//
//  NKPlayVideoLoadingView.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/29.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKPlayVideoLoadingView: UIView {

    @IBOutlet var olContainerView: UIView!
    @IBOutlet var oAniImageView: UIImageView!

    var isLoading = false
    
    override func awakeFromNib() {
        super.awakeFromNib()

        Bundle.main.loadNibNamed("NKPlayVideoLoadingView", owner: self, options: nil)
        
        olContainerView.frame = bounds
        addSubview(olContainerView)
        
        oAniImageView.animationImages = [UIImage(named: "whitenoise1")!, UIImage(named: "whitenoise2")!, UIImage(named: "whitenoise3")!, UIImage(named: "whitenoise4")!, UIImage(named: "whitenoise5")!, UIImage(named: "whitenoise6")!]
        oAniImageView.animationDuration = 0.5
        oAniImageView.animationRepeatCount = 0

    }

    func start() {
        if isLoading {
            KLog("이미 로딩되고 있음" as AnyObject?)
            return
        }
        self.alpha = 1.0
        isLoading = true
        oAniImageView.startAnimating()
    }
    
    func end() {
        if !isLoading {
            KLog("이미 로딩 안되고 있음" as AnyObject?)
            self.alpha = 0.0
            isLoading = false
            oAniImageView.stopAnimating()
            return
        }
        self.alpha = 0.0
        isLoading = false
        oAniImageView.stopAnimating()
    }
}
