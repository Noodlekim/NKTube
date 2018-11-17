//
//  NKYouTubeMenuViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/04/02.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

protocol NKYouTubeMenuViewControllerDelegate {
    
    func didLoginYouTube(_ height: CGFloat)
    func didLogoutYouTube()

}

enum YoutubeSubMenuType: Int {
    case recommend = 0, subscriptions, favorite
    
}

class NKYouTubeMenuViewController: UIViewController {

    @IBOutlet weak var olDescriptionLabel: UILabel!
    @IBOutlet weak var olProfileImageView: UIImageView!
    @IBOutlet weak var olHeightLoginDescription: NSLayoutConstraint!
    @IBOutlet weak var olYoutubeNameCenter: NSLayoutConstraint!
    
    @IBOutlet var subButtons: [UIButton]!

    var delegate: NKYouTubeMenuViewControllerDelegate?
    let heightCell: CGFloat = 40.0
    let heightProfileCell: CGFloat = 80.0
    
    @IBAction func acSelectedMenu(_ sender: UIButton) {
        
        guard let menuType = YoutubeSubMenuType.init(rawValue: sender.tag) else {
            return
        }
        var indentifier: String
        switch menuType {
        case .recommend:
            indentifier = "showRecommand"
        case .subscriptions:
            indentifier = "showChannelList"
        case .favorite:
            indentifier = "showFavoriteMovies"
        }
        
        performSegue(withIdentifier: indentifier, sender: nil)
    }
    
    @IBAction func acLoginGoogle(_ sender: AnyObject) {
        
        if !LoginManager.shared.isLogin {
            LoginManager.shared.login()            
        } else {
            // FIXME: ログアウト機能連動
        }
    }
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(NKYouTubeMenuViewController.updateMenuStatus), name: Notification.Name.init("SucessLogout"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NKYouTubeMenuViewController.updateMenuStatus), name: Notification.Name.init("SucessLogin"), object: nil)
    }
    
    // MARK: - Public
    
    @objc func updateMenuStatus() {
        let isLogin = LoginManager.shared.isLogin
        for btn in self.subButtons {
            btn.isEnabled = isLogin
            self.olHeightLoginDescription.constant = isLogin ? 0 : 14
            self.olYoutubeNameCenter.constant = isLogin ? 0 : -8
        }
        
        self.olDescriptionLabel.text = isLogin ? "" : "ログインしてください"        
    }
}
