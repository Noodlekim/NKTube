//
//  NKOtherMenuViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/22.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
//import StoreKit

class NKOtherMenuViewController: UIViewController/*, NKProductManagerDelegate*/ {

    var totalCapacity: String = "0"
    
    @IBOutlet weak var olTotalDataCapacity: UILabel!
    
    @IBAction func acBuyItem(_ sender: AnyObject) {
        
        let productIdentifiers = [inAppItem1]
        
//        NKProductManager.sharedInstance.delegate = self
        
        //プロダクト情報を取得
//        NKProductManager.sharedInstance.productsWithProductIdentifiers(productIdentifiers, completion: { (products, error) -> Void in
//            if (products?.count)! > 0 {
//
//                //課金処理開始
//                NKProductManager.sharedInstance.startWithProduct((products?[0])!)
//
//            }
//        })

    }
    
    @IBAction func acLoadSettingView(_ sender: AnyObject) {
        
        let settingView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingViewController") as! NKSettingViewController
        settingView.load()
    }
    

    @IBAction func acLoadFeedbackView(_ sender: AnyObject) {
        
        let feedbackView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedbackViewController") as! NKFeedbackViewController
        feedbackView.load()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculaterTotalCapacity()

        NotificationCenter.default.addObserver(self, selector: #selector(NKOtherMenuViewController.calculaterTotalCapacity), name: NSNotification.Name(rawValue: "changeVideoStatus"), object: nil);
    }
    
    func calculaterTotalCapacity() {
        var capacity: UInt64 = 0
        let videos = NKCoreDataCachedVideo.sharedInstance.getCachedVideoList()
        for video in videos {
            capacity += NKFileManager.getDataSize(video.videoId!)
        }
        totalCapacity = NKFileManager.convertDataSize(capacity)
        olTotalDataCapacity.text = "\(totalCapacity)"
    }
    
    // MARK: - NKProductManagerDelegate
    /*
    func purchaseManager(_ purchaseManager: NKProductManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        //課金終了時に呼び出される
        /*
         
         
         コンテンツ解放処理
         
         
         */
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: NKProductManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
        /*
         
         
         コンテンツ解放処理
         
         
         */
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: NKProductManager!, didFailWithError error: NSError!) {
        //課金失敗時に呼び出される
        /*
         
         
         errorを使ってアラート表示
         
         
         */
    }
    
    func purchaseManagerDidFinishRestore(_ purchaseManager: NKProductManager!) {
        //リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
        /*
         
         
         インジケータなどを表示していたら非表示に
         
         
         */
    }
    
    func purchaseManagerDidDeferred(_ purchaseManager: NKProductManager!) {
        //承認待ち状態時に呼び出される(ファミリー共有)
        /* 
         
         
         インジケータなどを表示していたら非表示に
         
         
         */
    }
 */

}
