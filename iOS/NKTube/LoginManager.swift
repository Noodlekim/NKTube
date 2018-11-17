//
//  LoginManager.swift
//  NKTube
//
//  Created by NoodleKim on 2018/11/16.
//  Copyright © 2018 NoodleKim. All rights reserved.
//

import Foundation
import AppAuth

class LoginManager: NSObject {
    
    static let shared = LoginManager()
    let scopes = [
        "https://www.googleapis.com/auth/youtube",
        "https://www.googleapis.com/auth/youtube.readonly",
        "https://www.googleapis.com/auth/youtubepartner"
    ]
    

    
    func login() {
        guard let issuer = URL.init(string: "https://accounts.google.com"),
            let redirectURL = URL.init(string: redirectURL),
            let mainVC = AppDelegate.window?.rootViewController else {
                return
        }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer, completion: {(_ configuration: OIDServiceConfiguration?, _ error: Error?) -> Void in
            if configuration == nil {
                return
            }
            let request = OIDAuthorizationRequest(configuration: configuration!, clientId: clientId, scopes: self.scopes, redirectURL: redirectURL, responseType: OIDResponseTypeCode, additionalParameters: nil)
            
            (UIApplication.shared.delegate as? AppDelegate)?.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: mainVC, callback: {(_ authState: OIDAuthState?, _ error: Error?) -> Void in
                if let accessToken = authState?.lastTokenResponse?.accessToken,
                    let refreshToken = authState?.lastTokenResponse?.refreshToken
                {
                    // FlurryManager.shared.actionBottomMenuLoginLoginSuccess()
                    NKUserInfo.shared.setAccessToken(accessToken)
                    NKUserInfo.shared.setRefreshToken(refreshToken)

                    // ログイン完了Notificationを通知
                    
                    let parameters: [String: Any] = [
                        "part": "id,snippet,contentDetails,status,topicDetails",
                        "mine": "true"
                    ]
                    YouTubeService2.shared.getUserRelatedPlaylists(param: parameters, completion: { (relatedPlaylists, error) in
                        if let relatedPlaylists = relatedPlaylists {
                            
                            if let favoritesId = relatedPlaylists.favorites {
                                NKUserInfo.shared.setFavorites(favoritesId)
                            }
                            if let likesId = relatedPlaylists.likes {
                                NKUserInfo.shared.setLikes(likesId)
                            }
                            if let uploadsId = relatedPlaylists.uploads {
                                NKUserInfo.shared.setUploadsId(uploadsId)
                            }
                        }
                    })
                    
                } else {
                    print("로그인 에러")
                    // TODO: ログイン失敗Notificationを通知
                }
            })
        })
    }
    
    var isLogin: Bool {
        guard NKUserInfo.shared.accessToken != nil , NKUserInfo.shared.refreshToken != nil else {
            return false
        }
        return true
    }
}

extension LoginManager: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    func didChange(_ state: OIDAuthState) {
        print("didChange status \(state)")
    }
    
    
    func didChangeState(state: OIDAuthState) {
        print("didChangeState status \(state)")
        
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("didEncounterAuthorizationError stats \(state) error \(error)")
        
    }
}
