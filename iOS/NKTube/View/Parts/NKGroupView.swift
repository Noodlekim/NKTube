//
//  NKGroupView.swift
//  NKTube
//
//  Created by NoodleKim on 2016/03/10.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKGroupView: UIView, UITextFieldDelegate {

    let height: CGFloat = 36.0
    
    var completeBlock: ((_ groupTitle: String) -> ())?
    var deleteBlock: ((_ groupTitle: String) -> ())?
    var toggleBlock: ((_ groupTitle: String) -> ())?

    var isDefaultGroup: Bool = false
    let inputViewAccessary: NKCustomTextField = NKCustomTextField(frame: CGRect.zero)

    @IBOutlet weak var olDeleteButton: UIButton!
    @IBOutlet var olContentView: UIView!
    @IBOutlet weak var olGroupTitleTxf: UITextField!
    @IBOutlet weak var olDeleteWidth: NSLayoutConstraint!
    @IBOutlet weak var olToggleButton: UIButton!
    @IBOutlet var olLeftMarginGroupTitle: NSLayoutConstraint!

    deinit {
        KLog("dealloc NKGroupView" as AnyObject?)
        NotificationCenter.default.removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // xibファイル読み込み
        Bundle.main.loadNibNamed("NKGroupView", owner: self, options: nil)
        
        // Viewの大きさを定義
        bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        olContentView.frame = bounds
        
        // xibファイルのViewをカスタムViewクラスに追加する
        addSubview(olContentView)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        
        self.olGroupTitleTxf.text = title
        
        self.inputViewAccessary.isInputingBlock = { (text: String)
            in
            KLog("입력되고 있는 정보들 : \(text)" as AnyObject?)
            self.olGroupTitleTxf.text = text
        }
        
        self.inputViewAccessary.completeInputBlock = { (text: String)
            in
            self.olGroupTitleTxf.resignFirstResponder()
            
            KLog("입력완료 텍스트 : \(text)" as AnyObject?)
            
            if let complete = self.completeBlock, let title = self.olGroupTitleTxf.text {
                complete(title)
            }
        }

        if title == defaultGroupName {
            isDefaultGroup = true
            olGroupTitleTxf.isEnabled = false
            olDeleteButton.isEnabled = false
            olDeleteWidth.constant = 0
            olLeftMarginGroupTitle.constant = 15
        }
    }
    
    @IBAction func acDeleteGroup(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "削除", message: "この\(olGroupTitleTxf.text!)を削除しますか？", preferredStyle: .alert)
        let okButton: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            if let deleteBlock = self.deleteBlock, let title = self.olGroupTitleTxf.text {
                deleteBlock(title)
            }
        })
        let cancelButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        if let mainVC = AppDelegate.mainVC() {
            mainVC.present(alert, animated: true, completion: nil)
        }
    }
  
    @IBAction func acToggleGroupView(_ sender: UIButton) {

        if let toggleBlock = self.toggleBlock {
            toggleBlock(self.olGroupTitleTxf.text!)
        }
    }
    
    func isEditing(_ isEditing: Bool) {
        
        if self.isDefaultGroup {
            
            if isEditing {
                olToggleButton.isEnabled = false
            }
            
        } else {

            if isEditing {
                olToggleButton.isEnabled = true
            }
            olGroupTitleTxf.isEnabled = isEditing
            
            if isEditing {
                olDeleteWidth.constant = 32
                olLeftMarginGroupTitle.constant = 0
                olToggleButton.isHidden = true
                
                if self.olGroupTitleTxf.text == defaultGroupName {
                    olToggleButton.isUserInteractionEnabled = false
                }
                
            } else {
                olDeleteWidth.constant = 0
                olLeftMarginGroupTitle.constant = 15
                olToggleButton.isHidden = false
                if self.olGroupTitleTxf.text == defaultGroupName {
                    olToggleButton.isUserInteractionEnabled = true
                }
                
            }

        }
        layoutIfNeeded()
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if let validStr: String = textField.text {
            if validStr.validateSpace() {
                return false
            }
        } else if textField.text == nil {
            return false
        }
        
        if let complete = self.completeBlock, let title = textField.text {
            complete(title)
        }

        return true
    }
}
