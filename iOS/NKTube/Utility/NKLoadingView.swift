//
//  NKLoadingView.swift
//  NKTube
//
//  Created by GibongKim on 2016/05/17.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

enum LoadingViewType: NSNumber {
    /*
     유투브 화면
    인기, 오스스메
     검색화면
     재생화면
     */
    case youtubeMenuRecommand = 2000
    case youtubeMenuPopular
    case youtubeMenuChannel
    case youtubeMenuGood
    case youtubeMenuWatchAfter
    case playVideoView
    case playVideoViewUnder
    case rightSearchView
    
    func loadingImage() -> UIImage {
        switch self {
        case .youtubeMenuRecommand:
            return UIImage(named: "icon_loading_recommand")!
        case .youtubeMenuPopular:
            return UIImage(named: "icon_loading_popular")!
        case .youtubeMenuChannel:
            return UIImage(named: "icon_loading_channel")!
        case .youtubeMenuGood:
            return UIImage(named: "icon_loading_good")!
        case .youtubeMenuWatchAfter:
            return UIImage(named: "icon_loading_watch_after")!
        default:
            return UIImage(named: "icon_total_download")!
        }
    }
}

class NKLoadingView: UIView {

    static let loadingViewTag = 10000
    static var showingContainers: [NSNumber: UIView] = [:]

    @IBOutlet var olContainerView: UIView!
    @IBOutlet weak var olTopMargin: NSLayoutConstraint!
    @IBOutlet weak var olBackgroundImage: UIImageView!
    @IBOutlet weak var backgroundBlurView: UIImageView!
    @IBOutlet weak var olLoadingAnimationView: UIImageView!
    
    var isShowing: Bool = false
    var type: LoadingViewType?
    
    static func leftMenuView() -> UIView? {
        if let leftContainerView = AppDelegate.mainVC()?.olLeftContainerView {
            return leftContainerView
        }
        return nil
    }
    
    // 아마 이건 좀 다른 방식으로 처리가 될 듯
    static func playVideoView() -> UIView? {
       
        if let containerView = AppDelegate.mainVC()?.moviePlayerViewController?.olMovieContainerView {
            return containerView
        }
        return nil
    }
    
    static func playVideoUnderView() -> UIView? {
        
        if let containerView = AppDelegate.mainVC()?.moviePlayerViewController?.underContainerView {
            return containerView
        }
        return nil
    }
    
    static func rightSearchView() -> UIView? {
        
        if let containerView = AppDelegate.mainVC()?.searchViewController?.view {
            return containerView
        }
        return nil
    }

    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, type: LoadingViewType) {
        self.init(frame: frame)
        
        self.type = type

        KLog("self frame \(self.frame)")
        Bundle.main.loadNibNamed("NKLoadingView", owner: self, options: nil)

        olContainerView.frame = frame
        addSubview(olContainerView)
        
        var imageNames: [String] = []
        for i in 1..<17 {
            let name = "dning"+"\(i)"
            imageNames.append(name)
        }
        
        var images: [UIImage] = []
        for name in imageNames {
            images.append(UIImage(named: name)!)
        }

        olBackgroundImage.animationImages = images
        olBackgroundImage.animationDuration = 1.5
        olBackgroundImage.animationRepeatCount = 0
        olBackgroundImage.startAnimating()
        
        
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // 애니메이션이 반복으로 움직이는 거랑
    class func showLoadingView(_ isShow: Bool,
                               type: LoadingViewType,
                               duration: TimeInterval? = nil,
                               animationImages: [UIImage]? = nil) {
        
        let containerView: UIView? = containerViewWithType(type)
        let container = containerView ?? UIApplication.shared.delegate?.window!!
        
        let showingTypes = Array(NKLoadingView.showingContainers.keys)
        if showingTypes.contains(type.rawValue) {
            
            KLog("이미 로딩바 있음. \(type)")
            return
        } else {
            let typeKey = type.rawValue
            NKLoadingView.showingContainers[typeKey] = container
        }

        let loadingView = NKLoadingView(frame: (container?.bounds)!, type: type)
        if let animationImages = animationImages {
            loadingView.olBackgroundImage.animationImages = animationImages
        }
        if let duration = duration {
            loadingView.olBackgroundImage.animationDuration = duration
        }
        loadingView.olBackgroundImage.startAnimating()
        
        container?.addSubview(loadingView)
    }
    
    class func hideLoadingView(_ type: LoadingViewType) {
        
        let typeKey = type.rawValue
        if let container = NKLoadingView.showingContainers[typeKey] {
            for subView in container.subviews {
                if let loadingView = subView as? NKLoadingView, loadingView.type == type {
                    
                    subView.removeFromSuperview()
                    NKLoadingView.showingContainers[typeKey] = nil
                } else {
                    KLog("삭제할 로딩바 없음. \(type)")
                }
            }
        }
    }


    class func containerViewWithType(_ type: LoadingViewType) -> UIView? {
        
        /*
         case YoutubeMenuRecommand = 2
         case YoutubeMenuPopular
         case YoutubeMenuChannel
         case YoutubeMenuGood
         case YoutubeMenuWatchAfter
         */
        switch type {
        case .youtubeMenuRecommand,
             .youtubeMenuChannel,
             .youtubeMenuGood,
             .youtubeMenuPopular,
             .youtubeMenuWatchAfter
             : return leftMenuView()
        case .playVideoView: return playVideoView()
        case .playVideoViewUnder: return playVideoUnderView()
        case .rightSearchView: return rightSearchView()
        }
    }
}
