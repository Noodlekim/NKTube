//
//  Constants.swift
//  NKTube
//
//  Created by NoodleKim on 2016/12/24.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import Foundation
import UIKit

let screenWidth: CGFloat = UIScreen.main.bounds.width
let screenHeight: CGFloat = UIScreen.main.bounds.height
let screenSize: CGSize = UIScreen.main.bounds.size
let screenRect: CGRect = UIScreen.main.bounds

let redirectURL: String = "com.googleusercontent.apps.972534134760-gs90o7lio2gutc528fv4gr0j6ikn4d67:/oauthredirect"

struct YouTubeURL {
    static let baseURL: String = "https://www.googleapis.com/youtube/v3"
}

enum APIPath: String {
    case subscriptions = "/subscriptions"
    case search = "/search"
    case videos = "/videos"
    case channels = "/channels"
    case playlistItems = "/playlistItems"
    case activities = "/activities"
    case oauth = "/oauth2/v4/token"
}
