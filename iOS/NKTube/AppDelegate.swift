
//
//  AppDelegate.swift
//  NKTube
//
//  Created by GibongKim on 2016/01/03.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer
import AVKit
import Fabric
import Crashlytics
import Firebase
import Flurry_iOS_SDK
//import StoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var identifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    static let window: UIWindow? = {
        return UIApplication.shared.delegate?.window!
    }()
    static func mainVC() -> NKMainViewController? {
       
        return UIApplication.shared.delegate?.window!!.rootViewController as? NKMainViewController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Flurry 셋팅
        Flurry.startSession(FlurryAPIKey);
        Fabric.with([Crashlytics.self])

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                KLog("AVAudioSession Category Playback OK")
            } catch {
                KLog("AVAudioSession Category Playback NG")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        Fabric.with([Crashlytics.self])

        // 通知許可をアラート表示にて
        UIApplication.shared.registerUserNotificationSettings(
            UIUserNotificationSettings(
                types:[.sound, .alert],
                categories: nil)
        )

        setGrobal()
        
        FIRApp.configure()

        if #available(iOS 9.0, *) {
            NKCoreDataCachedVideo.sharedInstance.saveAllCachedVideoForSpotlight()
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        if let userInfo = notification.userInfo {
            if let videoId = userInfo["videoId"] as? String {
                if let video = CachedVideo.oldCachedVideo(videoId) {
                    NKFlurryManager.sharedInstance.actionForPlayVideoWithLocalNotification(video)
                    NKAVAudioManager.sharedInstance.startPlay(video)
                }
            }
        }
    }

    fileprivate func setGrobal() {
        // ナビゲーションバーフォントと色設定
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 17),
            NSForegroundColorAttributeName: UIColor.black
        ]        

        // ナビゲーションバーの戻るボタンの矢印アイコン設定
//        UINavigationBar.appearance().backIndicatorImage = NaviItem.backItem()
//        UINavigationBar.appearance().backIndicatorTransitionMaskImage = NaviItem.backItem().imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        // タブバー背景色
//        UITabBar.appearance().barTintColor = UIColor.whiteColor()
//        
//        UINavigationBar.appearance().barTintColor = Color.KeyColor
//        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
//        UINavigationBar.appearance().translucent = false
//        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()

    }
    
//    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
//        // GIDSignIn
////        return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
//        return true
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // 화면이 재생정지가 되므로 자동 재생을 위해...
        if let movieVC = AppDelegate.mainVC()?.moviePlayerViewController {
            movieVC.startPlaying()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        // オブザーバー登録解除
//        SKPaymentQueue.default().remove(NKProductManager.sharedInstance)

    }
    
    // 6.バックグラウンド処理完了の通知を受け取る(AppDelegateファイルに記載)
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        NKYouTubeService.sharedInstance.backgroundCompletionHandler = completionHandler
        KLog("Background OK")
        completionHandler()
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        // 스포트라이트에서 곡이 선택되었을 경우
        if let videoId = userActivity.userInfo?["kCSSearchableItemActivityIdentifier"] as? String {
            if let video = CachedVideo.oldCachedVideo(videoId) {
                NKFlurryManager.sharedInstance.actionForPlayVideoWithSpotlight(video)
            }
            NKAVAudioManager.sharedInstance.startPlayWithVideoId(videoId)
        }
        return true
    }

    // MARK: 스테이스바 스크롤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let events = event!.allTouches
        let touch = events!.first
        let location = touch!.location(in: window)
        let statusBarFrame = UIApplication.shared.statusBarFrame
        if statusBarFrame.contains(location) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "statusBarTouched"), object: nil)
        }
    }
}

