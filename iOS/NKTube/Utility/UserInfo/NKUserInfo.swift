//
//  NKUserInfo.swift
//  NKTube
//
//  Created by GibongKim on 2016/02/04.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

struct NKVideoQulity {
    static let Small240 = NSNumber(value: 36 as Int32)
    static let Medium360 = NSNumber(value: 18 as Int32)
    static let HD720 = NSNumber(value: 22 as Int32)
}

struct NKPlayMode {
    static let None = "none"
    static let Random = "random"
    static let OneRepeat = "oneRepeat"
    static let AllRepeat = "allRepeat"
    static let GroupRepeat = "groupRepeat"
    static let GroupRandom = "groupRandom"

    static let allMode: [String] = [None, Random, OneRepeat, AllRepeat, GroupRepeat, GroupRandom]
    
    static func playModeIcon(_ mode: String) -> UIImage {
        switch mode {
        case NKPlayMode.None:
            return UIImage(named: "icon_normal")!
        case NKPlayMode.Random:
            return UIImage(named: "icon_Shuffle")!
        case NKPlayMode.OneRepeat:
            return UIImage(named: "icon_one_repeat")!
        case NKPlayMode.AllRepeat:
            return UIImage(named: "icon_all_random")!
        case NKPlayMode.GroupRepeat:
            return UIImage(named: "icon_group_random")!
        case NKPlayMode.GroupRandom:
            return UIImage(named: "icon_group_shuffle")!
        default:
            return UIImage(named: "icon_normal")!
        }
    }
}

let KeyVideoQulity: String = "kVideoQulity"
let KeyPlayMode: String = "kPlayMode"
let KeyMigration: String = "kMigration"
let KeySearchHistory: String = "kSearchHistory"

let KeyAccessToken: String = "kAccessToken"
let KeyRefreshToken: String = "kRefreshToken"

class NKUserInfo: NSObject {

    let userInfo: UserDefaults = UserDefaults.standard

    static var sharedInstance = NKUserInfo()

    func currentModeIndex() -> Int {
       
        if let index = NKPlayMode.allMode.index(of: self.playMode) {
            return index
        } else {
            return 0
        }
    }

    
    var videoQulity: NSNumber {
        get {

            if let qulity = userInfo.object(forKey: KeyVideoQulity) {
                return qulity as! NSNumber
            } else { // 기본 HD화질로 설정
                return NKVideoQulity.HD720
            }
        }
        set (newQulity) {
            self.userInfo.set(newQulity, forKey: KeyVideoQulity)
        }
    }
    
    func qulityNameForVideoQulity() -> String {
    
        switch self.videoQulity {
        case NKVideoQulity.Small240:
            return "240p"
        case NKVideoQulity.Medium360:
            return "360p"
        case NKVideoQulity.HD720:
            return "720HD"
        default:
            return "720HD"
        }
    }
    
    var playMode: String {
        
        get {
            if let qulity = self.userInfo.object(forKey: KeyPlayMode) {
                return qulity as! String
            } else { // 기본 전체반복
                return NKPlayMode.AllRepeat
            }
        }
        set (newPlayMode) {
            userInfo.set(newPlayMode, forKey: KeyPlayMode)
        }
    }
    
    var isMigration: Bool {
        
        get {
            if let isMigration = userInfo.object(forKey: KeyMigration) as? Bool {
                return isMigration
            } else {
                return false
            }
        }
        
        set (newFlag) {
            userInfo.set(newFlag, forKey: KeyMigration)
        }
    }
    
    // 검색이력
    func setSearchHistory(_ keyword: String) {

        // TODO: 검색 이력 갯수 제한 걸 것!
        if var oldHistory = userInfo.object(forKey: KeySearchHistory) as? [String] {
            if oldHistory.contains(keyword) {
                oldHistory.removeObj(keyword)
            }
            oldHistory.insert(keyword, at: 0)
            userInfo.set(oldHistory, forKey: KeySearchHistory)
        } else {
            userInfo.set([keyword], forKey: KeySearchHistory)

        }
    }
    
    var searchHistory: [String] {
        get {
            if let history = userInfo.object(forKey: KeySearchHistory) {
                return history as! [String]
            } else {
                return []
            }
        }
    }
    
    
    // 유투브 검색 토큰
    func setAccessToken(_ token: String) {
        userInfo.set(token, forKey: KeyAccessToken)
    }
    
    var accessToken: String? {        
        get {
            if let token = userInfo.object(forKey: KeyAccessToken) {
                return token as? String
            } else {
                return nil
            }
        }
    }
    
    
    func setRefreshToken(_ token: String) {
        userInfo.set(token, forKey: KeyRefreshToken)
    }
    
    var refreshToken: String? {        
        get {
            if let token = userInfo.object(forKey: KeyRefreshToken) {
                return token as? String
            } else {
                return nil
            }
        }
    }

}
