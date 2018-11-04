//
//  NKSplashViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/21.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit


class NKSplashViewController: UIViewController {

    @IBOutlet weak var olAniView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        olAniView.animationImages = [UIImage(named: "whitenoise_w1")!, UIImage(named: "whitenoise_w2")!, UIImage(named: "whitenoise_w3")!, UIImage(named: "whitenoise_w4")!, UIImage(named: "whitenoise_w5")!, UIImage(named: "whitenoise_w6")!]
        olAniView.animationDuration = 0.5
        olAniView.animationRepeatCount = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        olAniView.startAnimating()

        let delay = 2.0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as! NKMainViewController
            
            UIApplication.shared.delegate?.window!!.rootViewController = mainViewController
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate : Bool {
     
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
