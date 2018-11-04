//
//  NKFileManager.swift
//  NKTube
//
//  Created by GibongKim on 2016/02/07.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import RNCryptor

class NKFileManager: NSObject {

    static let sharedInstance: NKFileManager = NKFileManager()
    
    class func getDocumentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    }
    
    // TODO: 실제로는 비디오 퀄리티와 같이 처리를 해야함.
    class func checkCachedVideo(_ videoId: String) -> Bool {
        
        let videoPath: String = NKFileManager.getVideoPath(videoId)
        
        KLog("checking cached videoId \(videoPath)" as AnyObject?)
        return FileManager.default.fileExists(atPath: videoPath)
    }

    class func getVideoPath(_ videoId: String) -> String {
        return NKFileManager.getDocumentPath() + "/\(videoId).mp4"
    }

    class func getVideoURLPath(_ videoId: String) -> URL? {
        return URL(fileURLWithPath: NKFileManager.getDocumentPath() + "/\(videoId).mp4")
    }
    
    class func deleteCachedFile(_ videoId: String) -> Bool {
        
        do {
            if let fileURL = NKFileManager.getVideoURLPath(videoId) {
                try FileManager.default.removeItem(at: fileURL)
                KLog("파일 삭제 성공" as AnyObject?)
                return true
            } else {
                KLog("파일 경로 확보 실패" as AnyObject?)
                return false
            }
        } catch {
                KLog("파일 삭제 실패" as AnyObject?)
            return false
        }
    }
    
    class func getDataSize(_ videoId: String) -> UInt64 {
        let path = NKFileManager.getDocumentPath()+"/"+videoId+".mp4"
        do {
            
            let attr: NSDictionary = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            KLog("total size \(attr.fileSize())" as AnyObject?)
            return attr.fileSize()

        } catch {
            
            KLog("파일 사이즈 취득 실패" as AnyObject?)
            return 0
        }
    }
    
    class func convertDataSize(_ totalSize: UInt64) -> String {
        
        var value = Double(totalSize)
        var multiplyFactor: Int = 0
        
        let tokens = ["bytes", "KB", "MB", "GB", "TB"]
        
        while (value > 1024) {
            value /= 1024
            multiplyFactor += 1
        }
        
        return NSString(format: "%4.2f %@", value, tokens[multiplyFactor]) as String
    }

    // MARK: 암호화 처리
    func getDecryptFile(_ videoId: String) -> URL? {
        
        let encryptPath = NKFileManager.getVideoPath(videoId)
        let encryptData = try? Data(contentsOf: URL(fileURLWithPath: encryptPath))
        
        if let encryptData = encryptData {
            // 복호화함.
            do {
                let decryptData = try RNCryptor.decrypt(data: encryptData, withPassword: pw)
                let path = NKFileManager.getVideoPath("temp")
                do {
                    try decryptData.write(to: NSURL(fileURLWithPath: path) as URL, options: NSData.WritingOptions.atomicWrite)
                    return URL(fileURLWithPath: path)
                } catch {
                    KLog("복호화 된 파일 읽기 실패" as AnyObject?)
                }
            } catch {
                KLog("암호회 파일 취득 실패" as AnyObject?)
            }
        }
        return nil
    }
    
    func deleteDecryptFile() -> Bool {

        let decryptFilePath = NKFileManager.getVideoPath("temp")
        do {
            if FileManager.default.fileExists(atPath: decryptFilePath) {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: decryptFilePath))
                KLog("복호화 파일 삭제 성공" as AnyObject?)
                return true
            } else {
                KLog("복호화 파일 경로 확보 실패" as AnyObject?)
                return false
            }
        } catch {
            KLog("복호화 파일 삭제 실패" as AnyObject?)
            return false
        }
    }

}
