//
//  NKSuperVideoControlViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/06/22.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

protocol NKVideoControlViewDelegate {
    
    func okVideoStandBy()
    func tappedStopButton(_ button: UIButton)
    func tappedPauseAndPlayButton()
    func tappedSpeedUpButton(_ button: UIButton)
    func tappedSpeedDownButton(_ button: UIButton)
    func tappedSettingButton(_ button: UIButton)
    func tappedJumpForwardButton(_ button: UIButton)
    func tappedJumpBackButton(_ button: UIButton)
    func tappedNextVideoButton(_ button: UIButton?)
    func tappedPreVideoButton(_ button: UIButton?)
    func didMoveSeekBar(_ positionPer: CGFloat)
    func tappedCacheButton(_ button: UIButton)
    func tappedFullScreenMode(_ button: UIButton)
    func tappedScreen()
    func tappedChangeGroup(_ position: CGPoint)
}

class NKSuperVideoControlViewController: UIViewController {

    var delegate: NKVideoControlViewDelegate?
    
    var timer: Timer?
    
    @IBOutlet weak var olSettingButton: UIButton!
    @IBOutlet weak var olJumpForwardButton: UIButton!
    @IBOutlet weak var olJumpBackButton: UIButton!
    
    @IBOutlet weak var olPlayButton: UIButton!
    @IBOutlet weak var olSpeedUpButton: UIButton!
    @IBOutlet weak var olSpeedDownButton: UIButton!
    
    @IBOutlet weak var olControlContainerView: UIView!
    
    @IBOutlet weak var olLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var olPlayBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var olPlayBar: UIView!
    @IBOutlet weak var olCurrentBar: UIButton!
    @IBOutlet weak var olPlayTimeLabel: UILabel!
    @IBOutlet weak var olTotalPlayTimeLabel: UILabel!
    @IBOutlet weak var olCacheButton: NKStatusButton!
    @IBOutlet weak var olBackgroundImage: UIImageView!
    @IBOutlet weak var olPlayModeButton: UIButton!
    @IBOutlet weak var olFullScreenButton: UIButton!
    @IBOutlet weak var olSlowButton: UIButton!
    @IBOutlet weak var olFasterButton: UIButton!
    
    
    @IBOutlet weak var olUpperContainerPanel: UIView!
    @IBOutlet weak var olPlayVideoLoadingView: NKPlayVideoLoadingView!
    
    var lastBarPosition: CGFloat = 0.0;
    var isSeeking: Bool = false
    var playingVideo: VideoProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lockControlPanel()
        
        // 선택된 화질
        self.setVideoQulity()
        
        let mode = NKUserInfo.sharedInstance.playMode
        olPlayModeButton.setImage(NKPlayMode.playModeIcon(mode), for: UIControlState())

        olPlayBar.bringSubview(toFront: olCurrentBar)
        
        beginTimerForHidingControlPanel()
    }
    
    func setGesture() {
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(NKSuperVideoControlViewController.detectPan(_:)))
        olPlayBar.addGestureRecognizer(panRecognizer)
    }
    
    fileprivate func removeGesture() {
        if let gestures = olPlayBar.gestureRecognizers {
            for gesture in gestures {
                view.removeGestureRecognizer(gesture)
            }
        }
    }

    
    func toggleHiddenControlPanel() {
        
        self.olCacheButton.isHidden = !self.olCacheButton.isHidden
        self.olControlContainerView.isHidden = !self.olControlContainerView.isHidden
        self.olPlayTimeLabel.isHidden = self.olControlContainerView.isHidden
        self.olSettingButton.isHidden = self.olControlContainerView.isHidden
        self.olJumpForwardButton.isHidden = self.olControlContainerView.isHidden
        self.olJumpBackButton.isHidden = self.olControlContainerView.isHidden
        self.olPlayModeButton.isHidden = self.olControlContainerView.isHidden
        self.olFullScreenButton.isHidden = self.olControlContainerView.isHidden
        olUpperContainerPanel.isHidden = !olUpperContainerPanel.isHidden
        olPlayButton.isHidden = !olPlayButton.isHidden
        olSlowButton.isHidden = !olSlowButton.isHidden
        olFasterButton.isHidden = !olFasterButton.isHidden
        
        if !olControlContainerView.isHidden {
            beginTimerForHidingControlPanel()
        } else {
            resetTimer()
        }
        
    }
    
    func beginTimerForHidingControlPanel() {
        
        resetTimer()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(NKSuperVideoControlViewController.hideControlPanel), userInfo: nil, repeats: false)
    }
    
    func hideControlPanel() {
        
        if !olControlContainerView.isHidden {
            
            UIView.animate(withDuration: aniDuration, animations: { () -> Void in
                
                self.olCacheButton.alpha = 0.0
                self.olControlContainerView.alpha = 0.0
                self.olPlayTimeLabel.alpha = 0.0
                self.olSettingButton.alpha = 0.0
                self.olJumpForwardButton.alpha = 0.0
                self.olJumpBackButton.alpha = 0.0
                self.olPlayModeButton.alpha = 0.0
                self.olFullScreenButton.alpha = 0.0
                self.olPlayButton.alpha = 0.0
                self.olUpperContainerPanel.alpha = 0.0
                self.olSlowButton.alpha = 0.0
                self.olFasterButton.alpha = 0.0
                
                }, completion: { (isFinish) -> Void in
                    
                    self.olCacheButton.isHidden = true
                    self.olControlContainerView.isHidden = true
                    self.olPlayTimeLabel.isHidden = true
                    self.olSettingButton.isHidden = true
                    self.olJumpForwardButton.isHidden = true
                    self.olJumpBackButton.isHidden = true
                    self.olPlayModeButton.isHidden = true
                    self.olFullScreenButton.isHidden = true
                    self.olPlayButton.isHidden = true
                    self.olUpperContainerPanel.isHidden = true
                    self.olSlowButton.isHidden = true
                    self.olFasterButton.isHidden = true
                    
                    
                    self.olCacheButton.alpha = 1.0
                    self.olControlContainerView.alpha = 1.0
                    self.olPlayTimeLabel.alpha = 1.0
                    self.olSettingButton.alpha = 1.0
                    self.olJumpForwardButton.alpha = 1.0
                    self.olJumpBackButton.alpha = 1.0
                    self.olPlayModeButton.alpha = 1.0
                    self.olFullScreenButton.alpha = 1.0
                    self.olPlayButton.alpha = 1.0
                    self.olUpperContainerPanel.alpha = 1.0
                    self.olSlowButton.alpha = 1.0
                    self.olFasterButton.alpha = 1.0
            })
        }
    }
    
    fileprivate func resetTimer() {
        if let _ = timer {
            timer!.invalidate()
            timer = nil
        }
    }
    
    
    func setVideoQulity() {
        self.olSettingButton.setTitle(NKUserInfo.sharedInstance.qulityNameForVideoQulity(), for: UIControlState())
    }
    
    func updateVideoStatus(_ video: VideoProtocol) {
        
        playingVideo = video
        
        // 비디오 상태에 따른 버튼 상태 처리
        let videoStatus = VideoQuality.statusFromVideo(video)
        olCacheButton.videoStatus = videoStatus
        
        switch videoStatus {
        case .canDownload:
            olCacheButton.isUserInteractionEnabled = true
            olCacheButton.setImage(UIImage(named: NKDesign.iCon.downloadStatusCan), for: UIControlState())
        case .inQue:
            olCacheButton.isUserInteractionEnabled = false
            olCacheButton.setImage(UIImage(named: NKDesign.iCon.downloadStatusInQue), for: UIControlState())
        case .downloaded:
            olCacheButton.isUserInteractionEnabled = true
            olCacheButton.setImage(UIImage(named: NKDesign.iCon.videoMenu), for: UIControlState())
        }
    }
    
    func reset() {
        olBackgroundImage.image = UIImage(named: "background_player")
        olPlayButton.setImage(UIImage(named: NKDesign.iCon.playVideo), for: UIControlState())
        olCacheButton.isUserInteractionEnabled = false
        olCacheButton.setImage(UIImage(named: NKDesign.iCon.downloadStatusCan), for: UIControlState())
    }
    
    func setReadyPlay() {
        olPlayButton.setImage(UIImage(named: NKDesign.iCon.playVideo), for: UIControlState())
    }
    
    func setCanPause() {
        olPlayButton.setImage(UIImage(named: NKDesign.iCon.pauseVideo), for: UIControlState())
    }

    func lockControlPanel() {
        resetSeekBar()
//        olPlayButton.userInteractionEnabled = false
        olJumpBackButton.isUserInteractionEnabled = false
        olJumpBackButton.isUserInteractionEnabled = false
        removeGesture()
    }
    
    func unLockControlPanel() {
//        olPlayButton.userInteractionEnabled = true
        olJumpBackButton.isUserInteractionEnabled = true
        olJumpBackButton.isUserInteractionEnabled = true
        setGesture()
    }
    
    
    // MARK: - 버튼 액션
    
    @IBAction func acTappedScreen(_ sender: AnyObject) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            delegate.tappedScreen()
        }
    }
    
    @IBAction func acJumpForward(_ sender: UIButton) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            delegate.tappedJumpForwardButton(sender);
        }
    }
    
    @IBAction func acJumpBack(_ sender: UIButton) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            delegate.tappedJumpBackButton(sender)
        }
    }
    
    @IBAction func acPauseAndPlay(_ sender: UIButton) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            delegate.tappedPauseAndPlayButton()
        }
    }
    
    @IBAction func acSpeedUp(_ sender: UIButton) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            delegate.tappedSpeedUpButton(sender)
        }
    }
    
    @IBAction func acSpeedDown(_ sender: UIButton) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            delegate.tappedSpeedDownButton(sender)
        }
    }
    
    @IBAction func acSetting(_ sender: UIButton) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            delegate.tappedSettingButton(sender)
        }
    }
    
    @IBAction func acPreVideo(_ sender: UIButton) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            delegate.tappedPreVideoButton(sender)
        }
    }
    
    @IBAction func acNextVideo(_ sender: UIButton) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            delegate.tappedNextVideoButton(sender)
        }
    }
    
    @IBAction func acDoCache(_ sender: UIButton) {
        beginTimerForHidingControlPanel()

        // 현재 비디오 상태 별 액션처리
        let videoStatus = (sender as! NKStatusButton).videoStatus
        switch videoStatus {
        case .canDownload:
            if let delegate = self.delegate {
                delegate.tappedCacheButton(sender)
                olCacheButton.videoStatus = .inQue
            }
        case .downloaded:
            var position = sender.frame.origin
            position.y += sender.bounds.height
            position.x = 20
            if let delegate = self.delegate {
                delegate.tappedChangeGroup(position)
            }
        case .inQue:
            KLog("이미 큐에 들어가 있음.")
            break
        }
        
        // 버튼 아이콘 변경
        if let video = playingVideo {
            updateVideoStatus(video)
        }
    }
    
    @IBAction func acPlayMode(_ sender: UIButton) {
        beginTimerForHidingControlPanel()
        let currentIndex = NKUserInfo.sharedInstance.currentModeIndex() + 1
        let nextModeIndex = currentIndex%NKPlayMode.allMode.count
        if nextModeIndex < NKPlayMode.allMode.count {
            NKUserInfo.sharedInstance.playMode = NKPlayMode.allMode[nextModeIndex]
            
            let currentPlayMode = NKUserInfo.sharedInstance.playMode
            self.olPlayModeButton.setImage(NKPlayMode.playModeIcon(currentPlayMode), for: UIControlState())
        }
    }
    
    @IBAction func acFullScreenMode(_ sender: AnyObject) {
        beginTimerForHidingControlPanel()
        if let delegate = self.delegate {
            self.olFullScreenButton.isSelected = !self.olFullScreenButton.isSelected 
            delegate.tappedFullScreenMode(sender as! UIButton)
        }
    }
    
    @IBAction func acChangeGroup(_ sender: AnyObject) {
        var position = (sender as! UIButton).frame.origin
        position.y += (sender as! UIButton).bounds.height
        if let delegate = self.delegate {
            delegate.tappedChangeGroup(position)
        }
    }
    
    // MARK: - Public
    func resetSeekBar() {
        self.lastBarPosition = 0.0
        self.isSeeking = false
        self.olCurrentBar.center = CGPoint(x: self.olCurrentBar.frame.width/2, y: self.olCurrentBar.center.y)
        self.olLeftMargin.constant = 0
    }
    
    func startLoading() {
        olPlayVideoLoadingView.start()
    }
    
    func endLoading() {
        olPlayVideoLoadingView.end()
    }
    
    // MARK: - Gesture
    func detectPan(_ gesture: UIPanGestureRecognizer) {
        
        self.isSeeking = true
        
        if gesture.state == .began {
            self.lastBarPosition = self.olCurrentBar.center.x
        }
        
        if gesture.state == .changed {
            
            beginTimerForHidingControlPanel()
            
            let barHalfWidth = self.olCurrentBar.frame.width/2
            let totalWidth = self.olPlayBar.frame.width
            if self.olCurrentBar.frame.minX >= 0
                && self.olCurrentBar.frame.maxX <= totalWidth {
                
                let translation  = gesture.translation(in: self.olControlContainerView)
                self.olCurrentBar.center = CGPoint(x: self.lastBarPosition + translation.x, y: self.olCurrentBar.center.y)
                KLog("self.olCurrentBar.frame.maxX >> \(self.olCurrentBar.frame.maxX)")

                if self.olCurrentBar.frame.maxX >= 0 && self.olCurrentBar.frame.maxX < totalWidth {
                    self.olLeftMargin.constant = self.olCurrentBar.frame.maxX
                }

                if self.olCurrentBar.center.x < barHalfWidth {
                    self.olCurrentBar.center.x = barHalfWidth
                    return
                }
                
                if self.olCurrentBar.frame.maxX > totalWidth {
                    self.olCurrentBar.center.x = totalWidth-barHalfWidth
                    return
                }
            }
        }
        
        if gesture.state == .ended {
            self.lastBarPosition = self.olCurrentBar.center.x
            movedSeekBar()
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time  = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.isSeeking = false
            })
            
        }
        
        if gesture.state == .cancelled
            || gesture.state == .failed {
            self.isSeeking = false
        }
    }
    
    fileprivate func movedSeekBar() {
        if let delegate = self.delegate {
            let totalWidth = self.olPlayBar.frame.width
            let currentPosition = self.lastBarPosition
            let position = currentPosition/totalWidth
            delegate.didMoveSeekBar(position)
        }
    }
    
    
    // MARK: - SeekBar position
    func setCurrentPosition(_ totalTime: CGFloat, currentTime: CGFloat) {
        
        if self.isSeeking == false {
            let position = NKPlayManager.getCurrentPosition(self.olPlayBar.frame.width, totalTime: totalTime, currentTime: currentTime)
            var leftMargin = position-self.olCurrentBar.frame.width/2
            if leftMargin < 0 {
                leftMargin = 0
            } else if leftMargin + self.olCurrentBar.frame.width > self.olPlayBar.frame.width {
                leftMargin = self.olPlayBar.frame.width-self.olCurrentBar.frame.width
            }
            self.olLeftMargin.constant = leftMargin
            self.view.layoutIfNeeded()
        }
    }
    

}
