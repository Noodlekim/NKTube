
//
//  NKMainViewController.swift
//  NKTube
//
//  Created by GibongKim on 2016/01/16.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

enum NKMainViewStatus: NSInteger {
    
    case normal  = 100
    case loadLeftMenu
    case loadRightMenu
}

enum NKDraggingStatus: NSInteger {
    
    case none = 50
    case leftMenu
    case rightMenu
}

protocol MainViewCommonProtocol {
    func doScrollToTop()
    func doNeedToReload()
}

class NKMainViewController: UIViewController, NKAVAudioManagerDelegate, NKMyMenuMainViewControllerDelegate {
    
    let standardDragged: CGFloat = 50.0
    let moveDistance: CGFloat = UIScreen.main.bounds.width - baseSpace
    
    
    @IBOutlet weak var olLeftContainerView: UIView!
    @IBOutlet weak var olMainContainerView: UIView!
    @IBOutlet weak var olrightContainerView: UIView!

    @IBOutlet weak var olMainViewLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var olRightContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var olRightContainerRightMargin: NSLayoutConstraint!
    @IBOutlet weak var olLeftContainerWidth: NSLayoutConstraint!
    
    // 마이메뉴 열때 나타남
    @IBOutlet weak var olLeftBadgeButton: UIButton!
    // 일시적으로 나타남.
    @IBOutlet weak var olRightBadgeButton: UIButton!
    @IBOutlet weak var olLeftMarginLeftButton: NSLayoutConstraint!
    
    
    @IBOutlet weak var olLeftWidth: NSLayoutConstraint!
    @IBOutlet weak var olRightWidth: NSLayoutConstraint!

    @IBOutlet weak var olTopMarginDownloadBadge: NSLayoutConstraint!
    @IBOutlet weak var olHeightOfMenuView: NSLayoutConstraint!
    @IBOutlet weak var olBottomOfMenuView: NSLayoutConstraint!
    
    @IBOutlet weak var olProfileButton: UIButton!
    @IBAction func acShowBottomMenu(_ sender: UIButton) {
        UIView.animate(withDuration: aniDuration) {
            sender.alpha = 0.0
            self.olHeightOfMenuView.constant = screenHeight - screenHeight/10 + 20.0
            self.olBottomOfMenuView.constant = -208.0
            self.view.layoutIfNeeded()
        }
    }
    
    
    var myMenuViewController: NKMyMenuMainViewController?
    var searchViewController: NKSearchViewController?
    var moviePlayerViewController: NKMoviePlayerViewController?
    var bottomMenuViewController: BottomMenuViewController?
    
    let widthForAnimation: CGFloat = UIScreen.main.bounds.width - 60
    
    var isOpenMyMenu: Bool = false
    var isOpenSearchMenu: Bool = false
    var lastSwipePositionX: CGFloat = 0.0
    
    var startPosition: CGFloat?
    var mainViewLeftMargin: CGFloat?
    var rightContainerRightMargin: CGFloat?
    var changedWidth: CGFloat = 0.0

    var draggingStatus: NKDraggingStatus = .none
    var tempMainViewStatus: NKMainViewStatus = .normal
    var mainViewStatus: NKMainViewStatus {
        get {
            return tempMainViewStatus
        }
        
        set(newStatus) {
            tempMainViewStatus = newStatus
            setBadgePanel(tempMainViewStatus)
        }
    }
    
    var isMyMenuEditing: Bool = false
    var isBadgeTogging: Bool = false
    var badgeAnimationCount: Int = 0
    var isBadgeAnimate: Bool = false
    
    // MARK: - View life cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()

        NKAVAudioManager.sharedInstance.delegate = self

        self.registerGesture()
        self.setInitViewWithoutAnimation()

        NotificationCenter.default.addObserver(self, selector: #selector(NKMainViewController.scrollToTop), name: NSNotification.Name(rawValue: "statusBarTouched"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NKMainViewController.needToReladAllTableView), name: NSNotification.Name(rawValue: "changeVideoStatus"), object: nil)
        
        
        self.olHeightOfMenuView.constant = -screenHeight/10
        self.olBottomOfMenuView.constant = -self.olHeightOfMenuView.constant
        
        for vc in self.childViewControllers {
            
            if let myMenuNavigationController = vc as? UINavigationController {
                
                if let myVC = myMenuNavigationController.viewControllers[0] as? NKMyMenuMainViewController {
                    self.myMenuViewController = myVC
                    self.myMenuViewController?.delegate = self
                    KLog("self.myMenuViewController set OK > \(self.myMenuViewController)")
                }
            }

            if let moviePlayerVC = vc as? NKMoviePlayerViewController {
                self.moviePlayerViewController = moviePlayerVC
                KLog("moviePlayerViewController set OK > \(self.moviePlayerViewController)")
            }
            
            if let searchVC = vc as? NKSearchViewController {
                self.searchViewController = searchVC
                KLog("searchViewController set OK > \(self.searchViewController)")
            }
            
            if let bottomVC = vc as? BottomMenuViewController {
                self.bottomMenuViewController = bottomVC
                
                self.bottomMenuViewController?.bottomMenuBlock = {
                    return self.olBottomOfMenuView
                }
                
                self.bottomMenuViewController?.hideBottomMenuBlock = {
                    UIView.animate(withDuration: aniDuration, animations: { 
                        self.olProfileButton.alpha = 1.0
                    })
                }
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("AVAudioSession Category Playback Fail")
            }
            print("AVAudioSession Category Playback OK")
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        // 배찌 셋업
        setup()

        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        
        //스테이터스바 색깔 변경
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = NKStyle.RGB(236, green: 236, blue: 233)
            //NKStyle.RGB(210, green: 205, blue: 189)

        }
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        if let event = event {
            
            /*
            // available in iPhone OS 3.0
            case None
            
            // for UIEventTypeMotion, available in iPhone OS 3.0
            case MotionShake
            
            // for UIEventTypeRemoteControl, available in iOS 4.0
            case RemoteControlPlay
            case RemoteControlPause
            case RemoteControlStop
            case RemoteControlTogglePlayPause
            case RemoteControlNextTrack
            case RemoteControlPreviousTrack
            case RemoteControlBeginSeekingBackward
            case RemoteControlEndSeekingBackward
            case RemoteControlBeginSeekingForward
            case RemoteControlEndSeekingForward
             
            */
            if event.type == .remoteControl {
                
                switch event.subtype {
                    
                case .remoteControlPause
                    , .remoteControlPlay:
                    self.moviePlayerViewController?.tappedPauseAndPlayButton()
                    break
                case .remoteControlNextTrack:

                    self.moviePlayerViewController?.tappedNextVideoButton(nil)
                    break
                    
                case .remoteControlPreviousTrack:
                    self.moviePlayerViewController?.tappedPreVideoButton(nil)
                    break
                    
                default: break
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 
    fileprivate func setup() {
        
        // 화면에 따른 간격 조절.
        olLeftWidth.constant = 40
        olRightWidth.constant = baseSpace
        
        olLeftBadgeButton.alpha = 0.0
        olRightBadgeButton.alpha = 0.0
    }
    
    func setBadgePanel(_ status: NKMainViewStatus) {
        
        if !NKDownloadManager.sharedInstance.isDownloading() {
            olLeftBadgeButton.alpha = 0.0
            olRightBadgeButton.alpha = 0.0
            return
        }
        
        let badgeNum = NKDownloadManager.sharedInstance.isInQueVideos.count
        setBadgeNumber(badgeNum)
        
        UIView.animate(withDuration: aniDuration, animations: {
            switch status {
            case .normal, .loadRightMenu:
                self.olLeftBadgeButton.alpha = 1.0
                self.leftBadgeAnimation(3.0)
                self.olRightBadgeButton.alpha = 0.0
            case .loadLeftMenu:
                self.olLeftBadgeButton.alpha = 0.0
                self.olRightBadgeButton.alpha = 1.0
            }
        }) 
    }
    
    fileprivate func setBadgeNumber(_ badgeNum: Int) {
        if badgeNum == 0 {
            return
        }
        olLeftBadgeButton.setTitle("\(badgeNum)", for: UIControlState())
        olRightBadgeButton.setTitle("\(badgeNum)", for: UIControlState())
    }
    
    @IBAction func acTappedBadgeButton(_ sender: AnyObject) {
        KLog("acTappedBadgeButton")
        AppDelegate.mainVC()?.showDownloadStatusIfNeeds()
        let badgeNum = NKDownloadManager.sharedInstance.isInQueVideos.count
        if self.isBadgeTogging || badgeNum == 1 {
            return
        }
        self.isBadgeTogging = true
        myMenuViewController!.toggleDownloadHeight { (finish) in
            if finish {
                self.isBadgeTogging = false
            }
        }
    }


    // 스테이터스바를 눌렀을 때 스크롤을 초기화
    func scrollToTop() {
        switch mainViewStatus {
        case .normal:
            moviePlayerViewController?.doScrollToTop()
        case .loadRightMenu:
            searchViewController?.doScrollToTop()
        case .loadLeftMenu:
            myMenuViewController?.doScrollToTop()
        }
    }
    
    func needToReladAllTableView() {
        moviePlayerViewController?.doNeedToReload()
        searchViewController?.doNeedToReload()
        myMenuViewController?.doNeedToReload()
        
        // 뱃지 표시여부도 체크
        setBadgePanel(mainViewStatus)
    }
    
    fileprivate func leftBadgeAnimation(_ duration: Float) {
        if self.isBadgeAnimate {
            self.badgeAnimationCount = 0
            return
        }

        self.isBadgeAnimate = true
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.olLeftMarginLeftButton.constant = 20
                    self.view.layoutIfNeeded()
                }, completion: { (finish) in
                    UIView.animate(withDuration: 0.5, animations: { 
                        self.olLeftMarginLeftButton.constant = 0
                        self.view.layoutIfNeeded()
                    }, completion: { (secondFinish) in
                        self.badgeAnimationCount+=1
                        if Float(self.badgeAnimationCount) >= duration {
                            self.badgeAnimationCount = 0
                            timer.invalidate()
                            UIView.animate(withDuration: aniDuration, animations: { 
                                self.olLeftBadgeButton.alpha = 0
                                self.isBadgeAnimate = false
                                self.view.layoutIfNeeded()
                            })
                            
                        }
                    })
                }) 
            }
        } else {
            // Fallback on earlier versions
        }
    }

    
    // MARK: - Gesture
    
    func registerGesture() {
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(NKMainViewController.panGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    func removeGesture() {
        if let gestures = self.view.gestureRecognizers {
            for gesture in gestures {
                view.removeGestureRecognizer(gesture)
            }
        }
    }
    
    func panGesture(_ gesture: UIGestureRecognizer) {
        
        if gesture.state == .began {
            changedWidth = 0.0
            self.startPosition = gesture.location(in: self.view).x
            self.mainViewLeftMargin = self.olMainViewLeftMargin.constant
            self.rightContainerRightMargin = self.olRightContainerRightMargin.constant
        }
        
        if gesture.state == .changed {
            
            if let startPosition = self.startPosition {
                let changingPosition = gesture.location(in: self.view).x
                
                let diff: CGFloat = changingPosition - startPosition
                changedWidth = diff
                switch self.mainViewStatus {
                    // 제스쳐 왼쪽: 검색뷰를 로드할 의도
                case .normal:
                    if diff < 0 && self.olRightContainerRightMargin.constant < 0 {
                        
                        self.draggingStatus = .rightMenu
                        if let rightContainerRightMargin = self.rightContainerRightMargin {
                            self.olRightContainerRightMargin.constant = rightContainerRightMargin-diff
                        }
                    }
                        // 제스처 오른쪽: 캐싱뷰를 로드할 의도
                    else if diff > 0 && self.olMainViewLeftMargin.constant < self.view.frame.width - baseSpace {
                        
                        self.draggingStatus = .leftMenu
                        if let mainViewLeftMargin = self.mainViewLeftMargin {
                            self.olMainViewLeftMargin.constant = mainViewLeftMargin+diff
                        }
                    }

                    // 검색뷰가 로드가 되었을 때
                case .loadRightMenu:
                    
                    if diff > 0 && self.olRightContainerRightMargin.constant > -self.moveDistance {
                        
                        self.draggingStatus = .rightMenu
                        if let rightContainerRightMargin = self.rightContainerRightMargin {
                            self.olRightContainerRightMargin.constant = rightContainerRightMargin-diff
                        }
                    }
                    
                    // 캐싱뷰가 로드가 되었을 때
                case .loadLeftMenu:

                    if diff < 0 && self.olMainViewLeftMargin.constant > 0 {
                        
                        self.draggingStatus = .leftMenu
                        if let mainViewLeftMargin = self.mainViewLeftMargin {
                            self.olMainViewLeftMargin.constant = mainViewLeftMargin+diff
                        }
                    }
                }
            }
            self.view.layoutIfNeeded()
        }

        // 어느정도 로드가 되었으면 상태를 판단해서 완전 로드를 해버림.
        if gesture.state == .ended {
//            KLog("changedWidth >> \(changedWidth)")
            switch self.draggingStatus {
            case .rightMenu:
                if changedWidth < -standardDragged {
                    self.setInitViewWithStatus(.loadRightMenu)
                } else {
                    self.setInitViewWithStatus(.normal)
                }
            case .leftMenu:
                if changedWidth > standardDragged {
                    self.setInitViewWithStatus(.loadLeftMenu)
                } else {
                    self.setInitViewWithStatus(.normal)
                }
            default:
                KLog("Nothing!")
            }
            self.startPosition = nil
            self.mainViewLeftMargin = nil
            self.rightContainerRightMargin = nil
            changedWidth = 0.0
        }
    }
    
    func setInitViewWithoutAnimation() {
        
        if self.isMyMenuEditing {
            KLog("편집 모드 입니다.")
            return
        }
        self.olMainViewLeftMargin.constant = 0.0
        self.olRightContainerWidth.constant = self.moveDistance
        self.olLeftContainerWidth.constant = self.moveDistance
        self.olRightContainerRightMargin.constant = -self.olRightContainerWidth.constant
    }
    
    func showDownloadStatusIfNeeds() {
        
        if mainViewStatus != .loadLeftMenu {
            setInitViewWithStatus(.loadLeftMenu)
        }
    }
    
    func setInitViewWithStatus(_ viewStatus: NKMainViewStatus = .normal) {
        
        if self.isMyMenuEditing {
            KLog("편집 모드 입니다.")
            return
        }
        
        self.mainViewStatus = viewStatus
        
        moviePlayerViewController?.showScreenLockView((mainViewStatus != .normal))
        
        UIView.animate(withDuration: aniDuration, animations: { 
            
            switch viewStatus {
            // 기본 상태일 경우 메인뷰는 정위치에, 검색창은 오른쪽으로 숨긴다.
            case .normal:
                self.registerGesture()
                self.olMainViewLeftMargin.constant = 0.0
                self.olRightContainerWidth.constant = self.moveDistance
                self.olRightContainerRightMargin.constant = -self.olRightContainerWidth.constant
                
                // 검색창에 키보드가 로드가 되어 있으면 해제
                if let searchViewController = self.searchViewController {
                    searchViewController.dismissKeyboard()
                }
            case .loadLeftMenu:
                self.olMainViewLeftMargin.constant = self.moveDistance
                self.olRightContainerWidth.constant = self.moveDistance
                self.olRightContainerRightMargin.constant = -self.olRightContainerWidth.constant

            case .loadRightMenu:
                self.olMainViewLeftMargin.constant = 0.0
                self.olRightContainerWidth.constant = self.moveDistance
                self.olRightContainerRightMargin.constant = 0

            }
            self.view.layoutIfNeeded()

            
            }, completion: nil) 
    }
    
    func isLoadedSideViews() -> Bool {
        /*
            case Normal  = 100
            case LoadLeftMenu
            case LoadRightMenu
        */
        return (self.mainViewStatus != .normal)
        
    }
    
        override var canBecomeFirstResponder : Bool {
        return true
    }
    
    
    // MARK: - NKAVAudioManagerDelegate
    func playVideo(_ video: VideoProtocol) {

        self.setInitViewWithStatus()

        if let moviePlayerVC = self.moviePlayerViewController {
            moviePlayerVC.skinView?.startLoading()
            moviePlayerVC.moviePlayer.player?.rate = 0.0

            let delay = aniDuration * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                NKYouTubeService.sharedInstance.playWithCheckingCachedVideo(video.commonId!, complete: { (videoURL) -> Void in
                    if let videoURL = videoURL {
                        moviePlayerVC.parepareForPalyingVideo(video, videoURL: videoURL)
                        moviePlayerVC.setPlayVideo(videoURL)
                    } else {
                        
                    }
                })
            })
        }
    }
    
    // MARK: - NKMyMenuMainViewControllerDelegate
    func didStartEditMode(_ isEdit: Bool) {
        if isEdit {
            removeGesture()
        } else {
            registerGesture()
        }
    }
    
    func didSuccessYouTubeLogin()  {

        let accessToken = NKUserInfo.sharedInstance.accessToken
        NKUserInfo.sharedInstance.setAccessToken(accessToken!)

        if let moviePlayerVC = self.moviePlayerViewController {
            moviePlayerVC.relatedVideoViewController?.loadRecommandVideos()
        }
    }
    
    func didLogoutFromYouTube() {
        
        NKUserInfo.sharedInstance.setAccessToken("")
    }
    
    func didChangeDownloadListView(_ open: Bool, height: CGFloat) {
        
        UIView.animate(withDuration: aniDuration, animations: {
            if open {
                self.olRightBadgeButton.setTitle("", for: UIControlState())
                self.olRightBadgeButton.setImage(UIImage(named: "icon_badge_colse"), for: UIControlState())
            } else {
                let badgeNum = NKDownloadManager.sharedInstance.isInQueVideos.count
                self.olRightBadgeButton.setTitle("\(badgeNum)", for: UIControlState())
                self.olRightBadgeButton.setImage(nil, for: UIControlState())
            }
            
            self.olTopMarginDownloadBadge.constant = height - 40
            self.view.layoutIfNeeded()
        }) 
        
    }

}
