//
//  NKAlertView.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/14.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKAlertView: UIView {

    @IBOutlet var olContainerView: UIView!
    @IBOutlet weak var olTitle: UILabel!
    @IBOutlet weak var olThumbnail: UIImageView!
    
    var video: NKVideo?
    let height: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        KLog("self frame \(self.frame)" as AnyObject?)
        Bundle.main.loadNibNamed("NKAlertView", owner: self, options: nil)
        bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        olContainerView.frame = bounds
        
        addSubview(olContainerView)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(_ video: NKVideo) {
        self.video = video
        olTitle.text = video.title!
        if let thumb = video.thumbMaxres {
            olThumbnail.sd_setImage(with: URL(string: thumb), placeholderImage: NKImage.defaultThumbnail)
        } else {
            olThumbnail.sd_setImage(with: URL(string: video.thumbHigh!), placeholderImage: NKImage.defaultThumbnail)
        }
        
    }
    
    @IBAction func acTapped(_ sender: AnyObject) {
        
        if let video = self.video {
            NKAVAudioManager.sharedInstance.startPlay(video)
        }
    }

}
