//
//  NKFeedbackViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/07/12.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKFeedbackViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var olFeedBackTextView: UITextView!
    @IBOutlet weak var olHeightKeyboard: NSLayoutConstraint!
    @IBOutlet weak var olSendAnimationImageView: UIImageView!
    @IBOutlet weak var olTopContanierView: UIView!
    @IBOutlet var olSendButton: UIButton!

    var animationImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0.0
        
        olSendAnimationImageView.animationDuration = 2.0
        olSendAnimationImageView.animationRepeatCount = 1
        olSendAnimationImageView.animationImages = [
        UIImage(named: "ani_airplane1")!
        , UIImage(named: "ani_airplane2")!
        , UIImage(named: "ani_airplane3")!
        , UIImage(named: "ani_airplane4")!
        , UIImage(named: "ani_airplane5")!
        , UIImage(named: "ani_airplane6")!
        , UIImage(named: "ani_airplane7")!
        , UIImage(named: "ani_airplane8")!
        , UIImage(named: "ani_airplane9")!
        , UIImage(named: "ani_airplane10")!
        , UIImage(named: "ani_airplane11")!
        , UIImage(named: "ani_airplane12")!
        , UIImage(named: "ani_airplane13")!
        , UIImage(named: "ani_airplane14")!
        , UIImage(named: "ani_airplane15")!
        , UIImage(named: "ani_airplane16")!
        , UIImage(named: "ani_airplane17")!
        , UIImage(named: "ani_airplane18")!
        , UIImage(named: "ani_airplane19")!
        , UIImage(named: "ani_airplane20")!
        ]
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(NKFeedbackViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        olFeedBackTextView.becomeFirstResponder()
    }
    
    @IBAction func acSendFeedback(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "確認", message: "ご意見送信しますか？", preferredStyle: .alert)
        let okButton: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            // 송신 애니메이션
            self.sendAirplanAnimation { (finish) in
                self.dismiss()
            }
        })
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        if let mainVC = AppDelegate.mainVC() {
            mainVC.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func acDismiss(_ sender: AnyObject) {
        
        if olFeedBackTextView.text != "" {
            let alert = UIAlertController(title: "確認", message: "フィードバック内容があります。\n閉じますか？", preferredStyle: .alert)
            let okButton: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                self.dismiss()
            })
            let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(okButton)
            alert.addAction(cancelButton)
            if let mainVC = AppDelegate.mainVC() {
                mainVC.present(alert, animated: true, completion: nil)
            }
        } else {
            self.dismiss()
        }
    }
    
    func load() {
        AppDelegate.mainVC()?.removeGesture()
        
        if let containerVC = AppDelegate.mainVC() {
            containerVC.addChildViewController(self)
            containerVC.view.addSubview(self.view)
            self.view.layoutIfNeeded()

            UIView.animate(withDuration: aniDuration, animations: {
                self.view.alpha = 1.0
                self.view.layoutIfNeeded()

                }, completion: { (finish) in
            })
        }
    }

    func sendAirplanAnimation(_ complete: @escaping (_ finish: Bool) -> ()) {
        
        olSendAnimationImageView.frame = CGRect(x: olSendButton.center.x, y: olSendButton.center.y, width: 0, height: 0)

        let width = UIScreen.main.bounds.width/3
        let positionX = (UIScreen.main.bounds.width-width)/2

        // 위치조정
        UIView.animate(withDuration: 0.5, animations: {
            // 키보드 내리고
            self.olFeedBackTextView.resignFirstResponder()
            
            // 비행기를 표시...
            self.olSendAnimationImageView.center = CGPoint(x: 0,y: 0)
            self.olSendAnimationImageView.frame.size = self.view.bounds.size
            self.olSendAnimationImageView.alpha = 1.0

            }, completion: { (firstFinish) in
                UIView.animate(withDuration: 0.1, delay: 0.1, options: UIViewAnimationOptions(), animations: {
                    // 잠시 대기
                    Thread.sleep(forTimeInterval: 0.5)
                    
                    // 애니메이션
                    self.olSendAnimationImageView.image = UIImage(named: "ani_airplane20")
                    self.olSendAnimationImageView.startAnimating()

                    }, completion: { (secondFinish) in
        
                        // 아래에서 날리는 애니메이션
                        let position = self.olSendAnimationImageView.center
                        UIView.animate(withDuration: 0.3, delay: 2.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
                            self.olSendAnimationImageView.frame = CGRect(x: positionX, y: position.y, width: width, height: width)
                        }) { (finish) in
                            UIView.animate(withDuration: 1.0, delay: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
                                self.olSendAnimationImageView.frame = CGRect(x: positionX, y: -width, width: width, height: width)
                                }, completion: complete)
                        }
                })
        }) 
    }
    
    func dismiss() {
        UIView.animate(withDuration: aniDuration, animations: {
            self.view.alpha = 0.0
        }, completion: { (finish) in
            AppDelegate.mainVC()?.registerGesture()
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }) 
    }

    func keyboardWillShow(_ notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        
        olHeightKeyboard.constant = keyboardRectangle.height+22
        self.view.layoutIfNeeded()
        
    }

    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        olSendButton.isEnabled = (textView.text != "")
    }
}
