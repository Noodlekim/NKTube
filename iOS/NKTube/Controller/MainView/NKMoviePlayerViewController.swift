//
//  NKMoviePlayerViewController.swift
//  NKTube
//
//  Created by GibongKim on 2016/01/16.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import GoogleMobileAds
import RNCryptor
import SDWebImage

class NKMoviePlayerViewController: UIViewController, NKVideoControlViewDelegate, MainViewCommonProtocol, AVPlayerViewControllerDelegate, UIPopoverPresentationControllerDelegate, NKVideoQulitySelectionViewControllerDelegate {

    @IBOutlet weak var bannerView: GADBannerView!

    @IBOutlet weak var olMovieContainerView: UIView!
    @IBOutlet weak var olScreenLockView: UIImageView!

    @IBOutlet weak var olVideoPlayerHeight: NSLayoutConstraint!
    @IBOutlet weak var olHeightBanner: NSLayoutConstraint!
    
    var moviePlayer: AVPlayerViewController = AVPlayerViewController()
    var skinView: NKSuperVideoControlViewController?
    
    func screenSize() -> CGSize {
        return UIScreen.main.bounds.size
    }
    let heightOfPortrait: CGFloat = UIScreen.main.bounds.size.width * 210 / 375 + 1//210.0

    fileprivate var currentViedo: VideoProtocol?
    var currentTitle: String = ""

    
    var totalTime: TimeInterval?
    var timeObserver: AnyObject?
    
    var timer: Timer?
    var newPlayer: AVPlayer?

    var currentOperation: NKDownloadOperation?
    var indexPath: IndexPath?
    
    var relatedVideoViewController: NKRelatedVideoViewController?
    
    @IBOutlet weak var underContainerView: UIView!

    var stopedByUser = false
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(NKMoviePlayerViewController.endPlayingVideo), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NKMoviePlayerViewController.playerDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NKMoviePlayerViewController.errorPlayVideo), name: NSNotification.Name(rawValue: "didRemovePlayingVideo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NKMoviePlayerViewController.requestAD), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        for child in childViewControllers {
            if let vc = child as? NKRelatedVideoViewController {
                relatedVideoViewController = vc
            }
            if let vc = child as? NKSuperVideoControlViewController {
                skinView = vc
                skinView?.delegate = self
            }
        }
        
        // 전면 광고 로드
        requestAD()
        
        // 화면사이즈에 따른 비율을 측정해 재생영상 크기 조절
        olVideoPlayerHeight.constant = heightOfPortrait
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bannerView.frame.size.width = self.view.frame.width
    }

    func requestAD() {
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    func setTrackInfo(_ videoId: String, video: NKVideo? = nil) {
        
        let currentTime: TimeInterval = 0.0
        let duration: TimeInterval = 0.0

        if let video = video, let imageUrl = video.thumbMedium, let thumbnail = SDImageCache.shared().imageFromDiskCache(forKey: imageUrl) {
            
            guard let title = video.title else {
                return
            }
            currentViedo = video
            currentTitle = title
            
            let artwork = MPMediaItemArtwork(image: thumbnail)
            let audioInfo = MPNowPlayingInfoCenter.default()
            var nowPlayingInfo: [String: Any] = [:]
            
            artwork.image(at: artwork.bounds.size)
            nowPlayingInfo = [
                MPMediaItemPropertyTitle: title
                , MPMediaItemPropertyPlaybackDuration: duration
                , MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime
                , MPMediaItemPropertyArtwork: artwork
            ]
            
            audioInfo.nowPlayingInfo = nowPlayingInfo

        } else if let video = CachedVideo.oldCachedVideo(videoId), let imageUrl = video.thumbMedium, let thumbnail = SDImageCache.shared().imageFromDiskCache(forKey: imageUrl) {
            
            guard let title = video.title else {
                return
            }
            currentViedo = video
            currentTitle = title
            
            let artwork = MPMediaItemArtwork(image: thumbnail)
            let audioInfo = MPNowPlayingInfoCenter.default()
            var nowPlayingInfo: [String: Any] = [:]
            
            artwork.image(at: artwork.bounds.size)
            nowPlayingInfo = [
                MPMediaItemPropertyTitle: title
                , MPMediaItemPropertyPlaybackDuration: duration
                , MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime
                , MPMediaItemPropertyArtwork: artwork
            ]

            audioInfo.nowPlayingInfo = nowPlayingInfo
        }
    }
    
    
    func playerDidEnterBackground() {
        if let player = moviePlayer.player {
            if player.rate != 0.0 {
                player.perform(#selector(MPMediaPlayback.play), with: nil, afterDelay: 0.1)
            }
        }
        var identifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
        identifier = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
            UIApplication.shared.endBackgroundTask(identifier)
        })
    }

    override func viewDidLayoutSubviews() {
        // AVPlayerViewController 추가
        if !olMovieContainerView.subviews.contains(moviePlayer.view) {
            moviePlayer.showsPlaybackControls = false
            moviePlayer.videoGravity = AVLayerVideoGravityResizeAspect
            moviePlayer.view.frame = olMovieContainerView.bounds
            moviePlayer.view.backgroundColor = UIColor.black
            olMovieContainerView.insertSubview(moviePlayer.view, belowSubview: skinView!.view)
        }
    }
    
    // MARK: - 곡컨트롤 관련 (백그라운드 재생포함)
    func endPlayingVideo() {

        // 현재 곡 재생수 +1
        if let videoId = currentViedo?.commonId {
            if let currentCacheVideo = CachedVideo.oldCachedVideo(videoId) {
                
                if currentCacheVideo.playedCount == nil {
                    currentCacheVideo.playedCount = 0
                }
                
                let currentPlayCount = currentCacheVideo.playedCount!

                currentCacheVideo.playedCount = NSNumber(value: currentPlayCount.intValue + 1)
                
                NKCoreDataManager.sharedInstance.saveContext({ (isSuccess) -> Void in
                    if isSuccess {
                        KLog("곡재생수 저장 성공" as AnyObject?)
                    } else {
                        KLog("곡재생수 저장 실패" as AnyObject?)
                    }
                })
            }
        }
        
        switch NKUserInfo.sharedInstance.playMode {
        case NKPlayMode.None:
            KLog("nothing" as AnyObject?)
            skinView?.resetSeekBar()
        case NKPlayMode.Random:
            playRamdomVideo()
        case NKPlayMode.AllRepeat:
            playNextVideo()
        case NKPlayMode.OneRepeat:
            playRepeatVideo()
        case NKPlayMode.GroupRandom:
            playRamdomVideoInGroup()
        case NKPlayMode.GroupRepeat:
            playNextVideoInGroup()
        default:
            break
        }
    }
    
    func playRepeatVideo() {
        
        if let currentVideoId = currentViedo?.commonId {
            if let decryptFileURL = NKFileManager.sharedInstance.getDecryptFile(currentVideoId) {
                setTrackInfo(currentVideoId)
                setPlayVideo(decryptFileURL)
            }
        }
        
        
    }
    
    func playRamdomVideo() {
        
        if let randomId = NKCoreDataCachedVideo.sharedInstance.randomVideo() {
            if let decryptFileURL = NKFileManager.sharedInstance.getDecryptFile(randomId) {
                setTrackInfo(randomId)
                setPlayVideo(decryptFileURL)
            }
        }
    }

    
    func playNextVideo() {

        if let currentVideoId = currentViedo?.commonId {
            if let nextId = NKCoreDataCachedVideo.sharedInstance.nextVideo(currentVideoId) {
                if let decryptFileURL = NKFileManager.sharedInstance.getDecryptFile(nextId) {
                    setTrackInfo(nextId)
                    setPlayVideo(decryptFileURL)
                }
            }
        }
    }

    func playPreviousVideo() {

        if let currentVideoId = currentViedo?.commonId {
            if let preId = NKCoreDataCachedVideo.sharedInstance.preVideo(currentVideoId) {
                if let decryptFileURL = NKFileManager.sharedInstance.getDecryptFile(preId) {
                    setTrackInfo(preId)
                    setPlayVideo(decryptFileURL)
                }
            }
        }
    }
    
    func playPreviousVideoInGroup() {
        
        if let currentVideoId = currentViedo?.commonId {
            
            if let preId = NKCoreDataCachedVideo.sharedInstance.preVideoInGroup(currentVideoId) {
                if let decryptFileURL = NKFileManager.sharedInstance.getDecryptFile(preId) {
                    setTrackInfo(preId)
                    setPlayVideo(decryptFileURL)
                }
            }
        }
    }
    
    func playNextVideoInGroup() {
        
        if let currentVideoId = currentViedo?.commonId {
            
            if let nextId = NKCoreDataCachedVideo.sharedInstance.nextVideoInGroup(currentVideoId) {
                if let decryptFileURL = NKFileManager.sharedInstance.getDecryptFile(nextId) {
                    setTrackInfo(nextId)
                    setPlayVideo(decryptFileURL)
                }
            }
        }
    }

    func playRamdomVideoInGroup() {
        
        if let currentVideoId = currentViedo?.commonId {

            if let randomId = NKCoreDataCachedVideo.sharedInstance.randomVideoInGroup(currentVideoId) {
                if let decryptFileURL = NKFileManager.sharedInstance.getDecryptFile(randomId) {
                    setTrackInfo(randomId)
                    setPlayVideo(decryptFileURL)
                }
            }
        }
    }
    
    // 회전시 스킨이랑 화면 사이즈 조정
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {

        if toInterfaceOrientation == .landscapeRight
            || toInterfaceOrientation == .landscapeLeft {
            olVideoPlayerHeight.constant = screenSize().width
            print("Landscape")
            olHeightBanner.constant = 0
            hideStatsBarIfNeeds()
        } else {
            olVideoPlayerHeight.constant = heightOfPortrait
            olHeightBanner.constant = 50
            print("Portrait")
            showStatsBarIfNeeds()
        }
        view.layoutIfNeeded()
    }
    
    fileprivate func showStatsBarIfNeeds() {
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
        }
    }

    fileprivate func hideStatsBarIfNeeds() {
        if !UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.setStatusBarHidden(true, with: .fade)
        }
    }
    
    func tapedMoviewView() {
        
        if let mainVC = AppDelegate.mainVC() {
            if mainVC.isLoadedSideViews() {
                mainVC.setInitViewWithStatus()
            } else {
                if let skinView = skinView {
                    skinView.toggleHiddenControlPanel()
                }
            }
        } else {
            if let skinView = skinView {
                skinView.toggleHiddenControlPanel()
            }
        }
    }
    
    // MARK: - 스트림 URL설정하고 재생
    func setPlayVideo(_ url: URL) {
        
        if let skinView = skinView, let currentVideo = self.currentViedo {
            skinView.updateVideoStatus(currentVideo)
            relatedVideoViewController?.setOnlyDescription(currentVideo)
        }
        
        let item = AVPlayerItem(url: url)
        let player: AVPlayer = AVPlayer(playerItem: item)
        newPlayer = player
        startPlay()
    }
    
    // 비디오 재생이 실패했을 경우.
    func errorPlayVideo() {
        if let player = moviePlayer.player, let skinView = skinView {
            player.rate = 0.0
            skinView.reset()
        }
    }

    
    // MARK: - MainViewCommonProtocol

    func doScrollToTop() {
        if let recommandVC = relatedVideoViewController {
            recommandVC.olTableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func doNeedToReload() {
        if let recommandVC = relatedVideoViewController {
            recommandVC.olTableView.reloadData()
        }
        
        if let skinView = skinView, let video = currentViedo {
            skinView.updateVideoStatus(video)
        }
    }

    
    // MARK: - Public
    
    func startPlay() {
        
        if let player = newPlayer {
            if let skinView = skinView {
                skinView.lockControlPanel()
                skinView.startLoading()
            }
            
            // 기존에 재생되고 있는 곡 정지
            // TODO: 아마 로드 되고 있을 때 로딩바라던지 처리가 필요하지 않을까?
            if let oldPlayer = moviePlayer.player {
                oldPlayer.rate = 0.0
            }
            
            if player.status == .readyToPlay {
                
                if let skinView = skinView {
                    skinView.olBackgroundImage.image = nil
                    skinView.lastBarPosition = 0.0
                    if NKFileManager.sharedInstance.deleteDecryptFile() {
                        KLog("임시 파일 삭제 성공" as AnyObject?)
                    }
                    skinView.setCanPause()
                    skinView.unLockControlPanel()
                    self.moviePlayer.videoGravity = AVLayerVideoGravityResizeAspect
                }
                
                // 혹시 몰라 기존 타이머 해제
                if let timer = timer {
                    timer.invalidate()
                    self.timer = nil
                }
                // TODO: 일단은 임시로 이렇게 처리를 했는데 나중에 근본적인 수정을 하고 싶음.
                if let videoId = currentViedo?.commonId {
                    if let video = self.currentViedo as? NKVideo {
                        self.setTrackInfo(videoId, video: video)
                    } else {
                        self.setTrackInfo(videoId)
                    }
                }
                moviePlayer.player = player
                skinView?.resetSeekBar()
                player.play()
                
                // MARK: 현재 재생시간 실시간 측정
                if let player = moviePlayer.player {
                    
                    let timeScale = moviePlayer.player?.currentItem!.asset.duration.timescale;
                    let time: CMTime  = CMTimeMakeWithSeconds(1, timeScale!);
                    
                    if let duration = player.currentItem?.asset.duration {
                        totalTime = CMTimeGetSeconds(duration);
                        KLog("totalPlaytime >> \(totalTime)" as AnyObject?)
                        self.skinView!.olTotalPlayTimeLabel.text = "\(Int(self.totalTime!))".playTime()
                        self.skinView?.endLoading()
                    }
                    
                    player.addPeriodicTimeObserver(forInterval: time, queue: nil, using: { (time) -> Void in
                        
                        let currentTime: TimeInterval = CMTimeGetSeconds(player.currentTime());
                        
                        KLog("current time >>> \(currentTime)" as AnyObject?)

                        if let videoId = self.currentViedo?.commonId {
                            if let video = self.currentViedo as? NKVideo {
                                self.setTrackInfo(videoId, video: video)
                            } else {
                                self.setTrackInfo(videoId)
                            }
                        }
                        
                        if let skinVC = self.skinView{
                            // SeekBar 포지션 갱신
                            skinVC.setCurrentPosition(CGFloat(self.totalTime!), currentTime: CGFloat(currentTime))
                            skinVC.olPlayTimeLabel.text = "\(Int(currentTime))".playTime()
                        }
                    })
                }
                return
            }
            
            timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(NKMoviePlayerViewController.startPlay), userInfo: nil, repeats: false)
        }
    }

    func parepareForPalyingVideo(_ video: VideoProtocol, videoURL: URL) {

        currentViedo = video
        relatedVideoViewController?.relatedVideo = video
        relatedVideoViewController?.getDescriptionAndRelatedVideos(video)


        if let videoId = video.commonId {
            if let video = video as? NKVideo {
                setTrackInfo(videoId, video: video)
            } else {
                setTrackInfo(videoId)
            }
        }
    }
    
    func startPlaying() {
        
        // TODO: 속도가 올라간 상태에서 이거 설정하면 위험함.. 다른 방안 생각을 해야..
        if let player = moviePlayer.player, stopedByUser == false {
            if  (player.rate == 0.0) {
                player.rate = 1.0
                player.play()

                if let skinView = skinView {
                    skinView.setCanPause()
                }
            }
        }
    }
    
    func showScreenLockView(_ show: Bool) {
        UIView.animate(withDuration: aniDuration, animations: {
            self.olScreenLockView.alpha = show ? 1.0 : 0.0
        }) 
    }
    
    
    // MARK: - NKVideoControlViewDelegate
    
    func okVideoStandBy() {
        moviePlayer.player?.play()
    }
    func tappedStopButton(_ button: UIButton) {
        
    }
    func tappedPauseAndPlayButton() {

        // TODO: 속도가 올라간 상태에서 이거 설정하면 위험함.. 다른 방안 생각을 해야..
        if let player = moviePlayer.player {
            if let skinView = skinView {
                if  (player.rate == 1.0) {
                    player.rate = 0.0
                    stopedByUser = true
                    skinView.setReadyPlay()
                }
                else {
                    player.play()
                    stopedByUser = false
                    skinView.setCanPause()
                }
            }
        }
    }
    func tappedSpeedUpButton(_ button: UIButton) {
        
        if let player = moviePlayer.player {

            if player.rate < 2.0 {
                player.rate += 0.1
            }
        }
    }
    func tappedSpeedDownButton(_ button: UIButton) {
        
        if let player = moviePlayer.player {
            
            if player.rate > -1.0 {
                player.rate -= 0.1
            }
        }
    }

    func tappedSettingButton(_ button: UIButton) {
        
        let settingView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "videoQulitySelectionViewController") as! NKVideoQulitySelectionViewController
        settingView.delegate = self
        settingView.load()
    }
    

    func tappedJumpForwardButton(_ button: UIButton) {

        if let player = moviePlayer.player {

            let timeScale = player.currentItem!.asset.duration.timescale;
            let currentTime = player.currentTime()
            let time: CMTime  = CMTimeMakeWithSeconds(10, timeScale) + currentTime;
            player.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)

        }

    }
    func tappedJumpBackButton(_ button: UIButton) {
        
        if let player = moviePlayer.player {
            
            let timeScale = player.currentItem!.asset.duration.timescale;
            let currentTime = player.currentTime()
            let time: CMTime  = CMTimeMakeWithSeconds(-10, timeScale) + currentTime
            player.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    func isVerticalVideo() -> Bool {
    
        if let item = moviePlayer.player?.currentItem {
            let videoSize = item.presentationSize
            return (videoSize.height > videoSize.width && (UIDevice.current.orientation.isPortrait))
        }
        return false
    }
    
    func tappedFullScreenMode(_ button: UIButton) {

        // 세로 영상일 경우
        if isVerticalVideo() {
            let size: CGSize = screenSize()
            
            UIView.animate(withDuration: 0.4, animations: {
                // 세로영상 > 폰이 가로일 때
                if self.olVideoPlayerHeight.constant == size.height {
                    self.olVideoPlayerHeight.constant = self.heightOfPortrait
                    self.olHeightBanner.constant = 50
                    self.showStatsBarIfNeeds()
                } else {
                    // 세로영상 > 폰이 세로일 때
                    self.olVideoPlayerHeight.constant = size.height
                    self.olHeightBanner.constant = 0
                    self.hideStatsBarIfNeeds()
                }
                self.view.layoutIfNeeded()

                }, completion: { (finish) in
            })
            return
        }

        self.moviePlayer.videoGravity = AVLayerVideoGravityResizeAspect
        // 세로 > 가로
        if UIDevice.current.orientation.isPortrait {
                let value = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
        } else {
            // 가로 > 세로
            showStatsBarIfNeeds()
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    func tappedNextVideoButton(_ button: UIButton?) {
        if let player = moviePlayer.player, let skinView = skinView {
            skinView.startLoading()
            player.pause()
        }

        switch NKUserInfo.sharedInstance.playMode {
        case NKPlayMode.None, NKPlayMode.AllRepeat:
            playNextVideo()
        case NKPlayMode.Random:
            playRamdomVideo()
        case NKPlayMode.OneRepeat:
            playRepeatVideo()
        case NKPlayMode.GroupRandom:
            playRamdomVideoInGroup()
        case NKPlayMode.GroupRepeat:
            playNextVideoInGroup()
        default:
            break
        }
    }
    
    func tappedPreVideoButton(_ button: UIButton?) {
        if let player = moviePlayer.player, let skinView = skinView {
            skinView.startLoading()
            player.pause()
        }

        switch NKUserInfo.sharedInstance.playMode {
        case NKPlayMode.None, NKPlayMode.AllRepeat:
            playPreviousVideo()
        case NKPlayMode.Random:
            playRamdomVideo()
        case NKPlayMode.OneRepeat:
            playRepeatVideo()
        case NKPlayMode.GroupRandom:
            playRamdomVideoInGroup()
        case NKPlayMode.GroupRepeat:
            playPreviousVideoInGroup()
        default:
            break
        }
    }

    func didMoveSeekBar(_ positionPer: CGFloat) {
        
        if let player = moviePlayer.player, let duration = player.currentItem?.asset.duration {
            let timeScale = player.currentItem!.asset.duration.timescale;
            let movedTime = Float64(positionPer)*CMTimeGetSeconds(duration)
            let time: CMTime  = CMTimeMakeWithSeconds(movedTime, timeScale);
            player.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    func tappedCacheButton(_ button: UIButton) {

        if let video = self.currentViedo as? NKVideo{
            NKVideoStatusManager.sharedInstance.didStartDownload(video, location: .centerPlayer)
        }
    }
    
    func tappedScreen() {
        tapedMoviewView()
    }
    
    func tappedChangeGroup(_ position: CGPoint) {
        
        if let video = CachedVideo.oldCachedVideo(currentViedo!.commonId!) {
            let splitView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splitviewController") as! NKSplitviewController
            splitView.load(position, video: video)
        }
    }

    
    // MARK; - AVPlayerViewControllerDelegate
    
    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        
        KLog("playerViewControllerDidStartPictureInPicture" as AnyObject?)
    }
    
    
    // MARK: - NKVideoQulitySelectionViewControllerDelegate
    
    func didSelectVideoQulity() {
        if let skinView = self.skinView {
            skinView.setVideoQulity()
        }
    }

    
}
