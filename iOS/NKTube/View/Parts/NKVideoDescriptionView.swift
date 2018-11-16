//
//  NKVideoDescriptionView.swift
//  NKTube
//
//  Created by NoodleKim on 2016/06/14.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

public protocol NKVideoDescriptionViewDelegate {
    
    func changeHeight(_ isInt: Bool, height: CGFloat)
}

class NKVideoDescriptionView: UIView {

    var delegate: NKVideoDescriptionViewDelegate?
    
    @IBOutlet weak var olVideoTitle: UILabel!
    @IBOutlet weak var olGoodPercentage: UILabel!
    @IBOutlet weak var olViewsCount: UILabel!
    @IBOutlet weak var olVideoDescription: UITextView!
    @IBOutlet weak var olMoreButton: UIButton!
    @IBOutlet var olHeightMoreButton: NSLayoutConstraint!
    @IBOutlet var olRegistrant: UILabel!    
    @IBOutlet var olHeightMoreView: NSLayoutConstraint!
    @IBOutlet var olChannelThumbnail: UIImageView!
    

    @IBAction func addChannel(_ sender: UIButton) {
        if let channelId = self.video?.channelId {
            
//            MABYT3_APIRequest.sharedInstance().insertSubscription(channelId, andHandler: { (error, success) in
//                
//                if success {
//                    NKUtility.showMessage(message: "채널 등록 성공")
//                } else {
//                    NKUtility.showMessage(message: "채널 등록 실패: \(error)")
//                }
//            })
        }
    }

    
    var isInit = true
    var isOpen = false
    let heightDefault: CGFloat = 140//192//202//212
    let heightMoreButton: CGFloat = 25
    let heightGoodView: CGFloat = 18
    let heightRegisterView: CGFloat = 18
    
    let topMargin: CGFloat = 4//14
    let verticalMargin: CGFloat = 8
    let heightOpenCloseView: CGFloat = 54//38
    
    let descriptionDefault = ""
    var video: NKVideo?

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func acToggleMoreDescription(_ sender: AnyObject) {
        toggleOpenClose()
    }
    
    func toggleOpenClose() {
        
        let caculate = caculateContentHeight()
        var height: CGFloat = 0.0
        
        // 닫혀 있을 때
        if isInit {
            isOpen = false
            
        } else {
            isOpen = !isOpen
        }
        
        // 다음 액션의 버튼을 셋팅
        if !isOpen {
            olMoreButton.setTitle("More", for: UIControlState())
        } else {
            olMoreButton.setTitle("Close", for: UIControlState())
        }
        
        // 설명문이 없으면
        if caculate.lower == 0 {
            olHeightMoreView.constant = 0
        } else {
            // 설명문이 있으면 버튼이랑 moreView컨테이너 높이 조절
            olHeightMoreView.constant = heightOpenCloseView
            height = olHeightMoreView.constant

        }
        height += caculate.upper
        
        // 닫혀있는 상태
        if isOpen {
            height += caculate.lower

        } else {
            // 열린 상태
            
        }
        
        // 높이 반영
        if let delegate = self.delegate {
            delegate.changeHeight(self.isInit, height: height)
            isInit = false
        }
    }
    
    func loadVideoDescription(_ video: VideoProtocol?) {
        
        func setStyle(_ textView: UITextView) {
            let attributedText = NSMutableAttributedString(string: textView.text)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.2
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
            attributedText.addAttribute(NSForegroundColorAttributeName, value: NKStyle.RGB(112, green: 112, blue: 112), range: NSMakeRange(0, attributedText.length))
            textView.attributedText = attributedText
        }
        
        isInit = true
        
        if let video = video as? NKVideo {
            self.video = video
            
            olVideoTitle.text = video.title
            if let like = video.likeCount, let unLike = video.dislikeCount {
                if like == "0" || unLike == "0"{
                    olGoodPercentage.text = "--"
                } else {
                    olGoodPercentage.text = "\(Int(Float(like)!/(Float(like)!+Float(unLike)!)*100))%"
                }
            }
            
            if let channelThumb = video.channelThumbDefault {
                self.olChannelThumbnail.sd_setImage(with: URL(string: channelThumb), placeholderImage: NKImage.defaultProfile)
            }

            
            if let viewsCount = video.viewCount {
                olViewsCount.text = viewsCount.decimal()!+" views"
            }
            
//            if let channelTitle = video.channelTitle {
//                olRegistrant.text = channelTitle
//            }
            
            olVideoDescription.text = video.videoDescription == "" ?  descriptionDefault : video.videoDescription
        } else if let video = video as? CachedVideo {
            olVideoTitle.text = video.title
            
            if let like = video.likeCount, let unLike = video.unLike {
                if like == "0" || unLike == "0" {
                    olGoodPercentage.text = "--"
                } else {
                    olGoodPercentage.text = "\(Int(Float(like)!/(Float(like)!+Float(unLike)!)*100))%"
                }
            } else {
                olGoodPercentage.text = "--"
            }
            if let viewsCount = video.viewsCount {
                olViewsCount.text = viewsCount.decimal()!+" views"
            }
            
            olVideoDescription.text = video.videoDescription == "" ?  descriptionDefault : video.videoDescription
        }
        setStyle(olVideoDescription)
        
        toggleOpenClose()
    }
    
    fileprivate func caculateContentHeight() -> (upper: CGFloat, lower: CGFloat) {
        
        // 상단 높이랑 하단 높이를 각각 계산해서 반납함.
        func getHeightOfTextView(_ textView: UITextView) -> CGFloat {
            if textView.text == "" {
                return 0
            }
            let contentSize = textView.sizeThatFits(textView.bounds.size)
            var frame = textView.frame
            frame.size.height = contentSize.height
            textView.frame = frame
            
            return frame.height
        }
        
        let upper: CGFloat = olVideoTitle.getUpdatedHeight() + 14 + 12 + 10 + 18
        let lower: CGFloat = getHeightOfTextView(olVideoDescription)
        return (upper, lower)
    }
}
