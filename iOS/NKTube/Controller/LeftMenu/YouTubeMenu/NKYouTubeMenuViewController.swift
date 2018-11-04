//
//  NKYouTubeMenuViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/04/02.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

protocol NKYouTubeMenuViewControllerDelegate {
    
    func didLoginYouTube(_ height: CGFloat)
    func didLogoutYouTube()

}

class NKYouTubeMenuViewController: UIViewController, MAB_GoogleUserCredentialsDelegate {

    @IBOutlet weak var olDescriptionLabel: UILabel!
    @IBOutlet weak var olProfileImageView: UIImageView!
    @IBOutlet weak var olHeightLoginDescription: NSLayoutConstraint!
    @IBOutlet weak var olYoutubeNameCenter: NSLayoutConstraint!
    
    @IBOutlet var subButtons: [UIButton]!

    var delegate: NKYouTubeMenuViewControllerDelegate?
    let userCredentials = MAB_GoogleUserCredentials.sharedInstance()
    let heightCell: CGFloat = 40.0
    let heightProfileCell: CGFloat = 80.0
    
    @IBAction func acSelectedMenu(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            performSegue(withIdentifier: "showRecommand", sender: nil)
        case 1:
            performSegue(withIdentifier: "showChannelList", sender: nil)
        case 2:
            if let playListId = userCredentials?.user.contentDetails.relatedPlaylists["likes"] {
                performSegue(withIdentifier: "showFavoriteMovies", sender: playListId)
            }
        case 3:
            if let playListId = userCredentials?.user.contentDetails.relatedPlaylists["watchLater"] {
                performSegue(withIdentifier: "showWatchAfter", sender: playListId)
            }
        default:
            break
        }
        
    }
    
    @IBAction func acLoginGoogle(_ sender: AnyObject) {
        
        guard let userCredentials = userCredentials else {
            return
        }
        
        if !userCredentials.signedin {
            performSegue(withIdentifier: "showYouTubeLogin", sender: nil)
        } else {
            let alert: UIAlertController = UIAlertController(title: "確認", message: "ログアウトしますか？", preferredStyle: UIAlertControllerStyle.alert)
            
            let yes: UIAlertAction = UIAlertAction(title: "はい", style: .default) { (action) -> Void in
                self.userCredentials?.signOut()

                NKFlurryManager.sharedInstance.actionForYoutubeLogout()

                NKUserInfo.sharedInstance.setAccessToken("")
                if let delegate = self.delegate {
                    delegate.didLogoutYouTube()
                }
                
                // 기존 캐싱 데이터도 다 지움.
                URLCache.shared.removeAllCachedResponses()
                if let cookies = HTTPCookieStorage.shared.cookies {
                    for cookie in cookies {
                        HTTPCookieStorage.shared.deleteCookie(cookie)
                    }
                }

                // 프로필 UI 초기화
                self.updateSubViews()                
            }
            
            let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                
            }

            alert.addAction(yes)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        userCredentials?.delegate = self
        updateSubViews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        // NKFavoriteMoviesViewController
        if let watchAfterViewController = segue.destination as? NKWatchAfterViewController {
            if let playlistId = sender as? String {
                watchAfterViewController.playListId = playlistId
            }
        }
        
        if let favoriteMoviesViewController = segue.destination as? NKFavoriteMoviesViewController {
            if let playlistId = sender as? String {
                favoriteMoviesViewController.playListId = playlistId
            }
        }
    }
    
    func updateSubViews() {
        let snippet: MABYT3_ChannelSnippet = MAB_GoogleUserCredentials.sharedInstance().user.snippet
        let token = NKUserInfo.sharedInstance.accessToken
        let isLogout = (token == nil || token == "" || snippet.title == "")

        for btn in subButtons {
            btn.isEnabled = isLogout ? false : true
            olHeightLoginDescription.constant = isLogout ? 14 : 0
            self.olYoutubeNameCenter.constant = isLogout ? -8 : 0

        }
        
        if isLogout {
            self.olDescriptionLabel.text = "ログインしてください"
            self.olProfileImageView.image = NKImage.defaultProfile
        } else {
            olDescriptionLabel.text = snippet.title
            
            if let thumbnail = snippet.thumbnails["default"] as? MABYT3_Thumbnail {
                olProfileImageView.sd_setImage(with: URL(string: thumbnail.url), placeholderImage: NKImage.defaultProfile)
            }
        }
    }
    
    // MARK: - Delegate
    func credUserNoChannel() {
        olDescriptionLabel.text = "チャンネルない"
    }
    
    func credUserUpdated() {
        updateSubViews()
        
        if let delegate = delegate {
            delegate.didLoginYouTube(66.0+heightProfileCell)
        }
    }
    
    func credUserPrepare() {
        KLog("UserPrepare")
    }
    
    func credUserSubsComplete() {
        KLog("CredUserSubsComplete")
    }
}
