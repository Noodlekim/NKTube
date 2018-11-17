//
//  NKInputAccessary.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/14.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

protocol NKInputAccessaryDelegate {
    func didCancel()
    func didComplete()

}
class NKInputAccessary: UIView {

    var delegate: NKInputAccessaryDelegate?
    
    @IBOutlet var olContainerView: UIView!
    @IBOutlet weak var olCompleteButton: UIButton!
    
    let height: CGFloat = 40
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("NKInputAccessary", owner: self, options: nil)
        bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        olContainerView.frame = bounds
        addSubview(olContainerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func acComplete(_ sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.didComplete()
        }
    }

    @IBAction func acCancel(_ sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.didCancel()
        }
    }
}
