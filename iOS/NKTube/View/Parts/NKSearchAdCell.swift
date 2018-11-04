//
//  NKSearchAdCell.swift
//  NKTube
//
//  Created by GibongKim on 2016/06/11.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import GoogleMobileAds

class NKSearchAdCell: UITableViewCell {

    @IBOutlet weak var olBannerView: GADBannerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setBanner(_ vc: UIViewController) {
        if olBannerView.adUnitID == nil {
            olBannerView.adUnitID = adUnitID
            olBannerView.rootViewController = vc
            olBannerView.load(GADRequest())
        }
    }
}
