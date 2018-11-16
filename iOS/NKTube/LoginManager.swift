//
//  LoginManager.swift
//  NKTube
//
//  Created by GiBong Kim on 2018/11/16.
//  Copyright © 2018 GibongKim. All rights reserved.
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
                    // Flurry 로그인 성공
                    // FlurryManager.shared.actionBottomMenuLoginLoginSuccess()
                    // TODO: UserDefault의 저장 방식을 바꿀예정.
                    UserInfos.accessToken.set(value: accessToken)
                    UserInfos.refreshToken.set(value: refreshToken)
                    
                    let parameters: [String: Any] = [
                        "part": "id,snippet,contentDetails,status,topicDetails",
                        "mine": "true"
                    ]
                    YouTubeService.shared.getUserRelatedPlaylists(param: parameters, completion: { (relatedPlaylists, error) in
                        if let relatedPlaylists = relatedPlaylists {
                            
                            if let favorites = relatedPlaylists.favorites {
                                UserInfos.favorites.set(value: favorites)
                            }
                            if let likes = relatedPlaylists.likes {
                                UserInfos.likes.set(value: likes)
                            }
                            if let uploads = relatedPlaylists.uploads {
                                UserInfos.uploads.set(value: uploads)
                            }
                        }
                        // TODO: 이걸 사이드쪽으로 바꾸던지 아니면 없애든지 해야함.
                        BottomMenuManager.shared.completeLogin(isLogin: true)
                    })
                    
                } else {
                    print("로그인 에러")
                    BottomMenuManager.shared.completeLogin(isLogin: false)
                }
            })
        })
    }
    
    var isLogin: Bool {
        guard let accessToken = UserInfos.accessToken.get() as? String, let refreshToken = UserInfos.refreshToken.get() as? String else {
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
