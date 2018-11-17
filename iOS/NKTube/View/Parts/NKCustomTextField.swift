//
//  NKCustomTextField.swift
//  NKTube
//
//  Created by NoodleKim on 2016/03/12.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

class NKCustomTextField: UIView, UITextFieldDelegate {

    let height: CGFloat = 60.0
    
    var isInputingBlock: ((_ text: String) -> ())?
    var completeInputBlock: ((_ text: String) -> ())?


    @IBOutlet weak var olTextField: UITextField!
    @IBOutlet weak var olInputButton: UIButton!
    @IBOutlet var olContentView: UIView!
    
    deinit {
        KLog("dealloc inputingBlock")
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // xibファイル読み込み
        Bundle.main.loadNibNamed("NKCustomTextField", owner: self, options: nil)
        
        // Viewの大きさを定義
        bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        olContentView.frame = bounds
        
        // xibファイルのViewをカスタムViewクラスに追加する
        addSubview(olContentView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NKCustomTextField.didInputText(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: self.olTextField)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func acInput(_ sender: UIButton) {
        
        if let completeInputBlock = self.completeInputBlock {
            
            if let text = self.olTextField.text {
                self.olTextField.resignFirstResponder()
                completeInputBlock(text)
            }
        }
    }
    
    func setInputInitText(_ initText: String) {
        
        self.olTextField.text = initText
    }
    
    func setDelegate(_ textField: UITextField) {
        
        textField.delegate = self

    }
    
    func setFocus() {
        self.olTextField.becomeFirstResponder()
    }
    
    func didInputText(_ notification: Notification) {
        
        let object = notification.object
        if let textField = object as? UITextField {
            if let isInputingBlock = self.isInputingBlock {
                if let text = textField.text {
                    isInputingBlock(text)
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if let completeInputBlock = self.completeInputBlock {
            if let text = textField.text {
                if textField.isFirstResponder {
                    textField.resignFirstResponder()
                }
                completeInputBlock(text)
            }
        }

        return true
    }
}
