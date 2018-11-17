//
//  NKDownloadBadgeViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/07/04.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit


/*
 # 다운로드중일때 배찌 실장
	> 사양을 정해야함.
	> 그리고 다운로드 중일때도 98%정도 되면.. 100으로 돌려버리고 처리로딩바가 돌아가도록 할 것!
	> 역시 무리다.
 > 그냥 MoviePlayerVC쪽에 붙이는건 가능해도.. 유코씨 제안대로는 무리.. 그냥 배찌만 넣고 5초후에 사라지게 하자.
 > 숫자를 누르면 제일 하단까지 내려가는걸 뭐 만들라면 가능은 하겠다 --?
	>> 한번 설계를 해보자. 둘사이에 완벽한 상호 호출이 이뤄져야함.
	이거 가능은 할 것 같다.
	> 투명한 패널을 위에 올려놓고
	> 현재 다운로드중, 패널의 상태에 따라 표시가 됨
 > 좌측 메뉴바가 아닐경우엔 5초후에 사라짐? > 이건 일단 실장은 하지말자.
	> 버튼을 누르면 기본적으로 좌측패널로 이동한다 > 그리고 전체 상황을 보여줌.
	> NKMainViewController랑 연결되어서 스테이터스가 갱신될 때 마다 확인
	> 인터넷이 시작되면 Notification으로 호출함.

 */
class NKDownloadBadgeViewController: UIViewController {

    @IBOutlet weak var olLeftBadgeButton: UIButton!
    @IBOutlet weak var olLeftBadgeContainer: UIView!
    
    @IBOutlet weak var olRightBadgeContainer: UIView!
    @IBOutlet weak var olRightBadgeButton: UIButton!
    
    @IBOutlet weak var olLeftWidth: NSLayoutConstraint!
    @IBOutlet weak var olRightWidth: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(NKDownloadBadgeViewController.reset), name:NSNotification.Name(rawValue: "changeVideoStatus") , object: nil)        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setup() {
        
        // 화면에 따른 간격 조절.
        olLeftWidth.constant = baseSpace
        olRightWidth.constant = baseSpace
        
        olLeftBadgeButton.alpha = 1.0
        olLeftBadgeContainer.alpha = 0.0
        olRightBadgeButton.alpha = 1.0
        olRightBadgeContainer.alpha = 0.0
    }
    
    func setBadgePanel(_ status: NKMainViewStatus) {

        if !NKDownloadManager.sharedInstance.isDownloading() {
            olLeftBadgeContainer.alpha = 0.0
            olRightBadgeContainer.alpha = 0.0
            return
        }
        
        let badgeNum = NKDownloadManager.sharedInstance.isInQueVideos.count
        setBadgeNumber(badgeNum)

        UIView.animate(withDuration: aniDuration, animations: {
            switch status {
            case .normal, .loadRightMenu:
                self.olLeftBadgeContainer.alpha = 1.0
                self.olRightBadgeContainer.alpha = 0.0
            case .loadLeftMenu:
                self.olLeftBadgeContainer.alpha = 0.0
                self.olRightBadgeContainer.alpha = 1.0
            }
        }) 
    }
    
    func reset() {
        UIView.animate(withDuration: aniDuration, animations: { 
            self.olLeftBadgeContainer.alpha = 0.0
            self.olRightBadgeContainer.alpha = 0.0
        }) 
    }

    fileprivate func setBadgeNumber(_ badgeNum: Int) {
        if badgeNum == 0 {
            return
        }
        olLeftBadgeButton.setTitle("\(badgeNum)", for: UIControlState())
        olRightBadgeButton.setTitle("\(badgeNum)", for: UIControlState())
    }
}
