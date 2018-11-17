//
//  BottomMenuViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/12/24.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit


class BottomMenuViewController: UIViewController {

    enum BottomMenuStatus {
        case top
        case middle
        case hidden
        
        // Bottom용 Margin값을 반환
        func posision() -> CGFloat {
            switch self {
            case .top:
                return 0.0
            case .middle:
                return -208.0
            case .hidden:
                return -screenHeight*9/10 - 20.0
            }
        }
        
        func nextDirection(direction: GestureDirection) -> BottomMenuStatus {
        
            switch direction {
            case .up:
                return .top
            case .down:
                if self == .top {
                    return .middle
                } else if self == .middle {
                    return .hidden
                } else {
                    return self
                }
            default:
                return self
            }
        }
    }
    
    enum GestureDirection {
        case up
        case down
        case none
    }

    
    @IBOutlet weak var olTableView: UITableView!
    
    var startPosition: CGFloat?
    var status: BottomMenuStatus = .top
    var bottomMenuBlock: (() -> NSLayoutConstraint)?
    var hideBottomMenuBlock: (() -> Void)?
    
    let topMinY: CGFloat = BottomMenuStatus.top.posision()
    let middleMinY: CGFloat = BottomMenuStatus.middle.posision()
    let minmumMove: UInt = 20
    var currentBottom: NSLayoutConstraint?
    var direction: GestureDirection = .none
    var currentStatus: BottomMenuStatus = .middle {
        didSet {
            if self.currentStatus == .hidden {
                self.currentStatus = .middle
                if let block = self.hideBottomMenuBlock {
                    block()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerGesture()
        
    }

    
    
    
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
            self.startPosition = gesture.location(in: self.view).y
            if let bottomBlock = self.bottomMenuBlock {
                self.currentBottom = bottomBlock()
            }
        }
        
        if gesture.state == .changed {
            
            KLog("bottom view frame \(self.view.frame.minY)")
            
            guard let _ = self.currentBottom else {
                return
            }
            
            if let startPosition = self.startPosition {
                let changingPosition = gesture.location(in: self.view).y
                let diff: CGFloat = changingPosition - startPosition

                KLog("self.currentBottom \(currentBottom!.constant - diff)")
                let changed: CGFloat = self.currentBottom!.constant - diff
                if changed > 0 || changed <= -self.view.frame.height {
                    if changed > 0 {
                        self.currentBottom?.constant = 0.0
                    } else {
                        self.currentBottom?.constant = -self.view.frame.height
                    }
                    self.parent!.view!.layoutIfNeeded()
                    return
                }

                self.currentBottom!.constant = self.currentBottom!.constant - diff
            }
            self.parent!.view!.layoutIfNeeded()
        }
        
        // 드래그된 속도에 따라 뷰를 어떻게 로드할지 정함.
        if gesture.state == .ended {
            
            let velocity = (gesture as! UIPanGestureRecognizer).velocity(in: self.view)
            KLog("velocity1 >> \(velocity)")
            // 만약 20px이하로 움직였다면..
            
            if velocity.y >= 500 || velocity.y <= -500, let bottomBlock = self.bottomMenuBlock {
                let direction: GestureDirection = velocity.y < 0 ? .up : .down

                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {

                    let bottomConstrataint = bottomBlock()
                    let nextStatus = self.currentStatus.nextDirection(direction: direction)
                    // 다음 Status 저장.
                    self.currentStatus = nextStatus
                    bottomConstrataint.constant = nextStatus.posision()
                    
                    self.parent!.view!.layoutIfNeeded()

                }, completion: nil)
            } else {
              
                let changed: CGFloat = self.currentBottom!.constant
                if changed > 0 || changed <= -self.view.frame.height {
                    return
                }
                
                if let bottomBlock = self.bottomMenuBlock {
                    let bottomConstrataint = bottomBlock()
                    
                    KLog("bottomConstrataint.constant > \(bottomConstrataint.constant)")
                    KLog("-self.topMinY > \(-self.topMinY)")
                    KLog("-self.middleMinY > \(-self.middleMinY)")
                    
                    
                    UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: { [weak self] in

                        guard let weakSelf = self else {
                            return
                        }

                        // Top
                        if bottomConstrataint.constant <= 0 && bottomConstrataint.constant > -weakSelf.topMinY/2 {
                            weakSelf.currentStatus = .top
                            // Middle
                        } else if bottomConstrataint.constant <= -weakSelf.topMinY/2 && bottomConstrataint.constant > -weakSelf.middleMinY*3/2 {
                            weakSelf.currentStatus = .middle
                            // Hidden
                        } else {
                            weakSelf.currentStatus = .hidden
                            if let block = weakSelf.hideBottomMenuBlock {
                                block()
                            }
                        }
                        
                        bottomConstrataint.constant = weakSelf.currentStatus.posision()
                        weakSelf.parent!.view!.layoutIfNeeded()

                    }, completion: nil)
                }
            }
        }
    }
    

    // MARK: - UITableViewDelegate, DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
