//
//  NKDownloadManager.swift
//  NKTube
//
//  Created by NoodleKim on 2016/02/21.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit

/*
  큐가 원하던데로 안돌아가서 그냥 만듬.
*/

protocol NKDownloadManagerDelegate {

    func didAddDownloadList()
    func didRemoveDownloadList()
    func startDownload(_ video: NKVideo)
    func finishedDownload(_ video: NKVideo)
    func updateDownloadingStatus(_ percentage: CGFloat)
    func emptNextDownloadList()

}

class NKDownloadManager: NKDownloadOperationDelegate {

    var delegate: NKDownloadOperationDelegate?
    var downloadStatusDelegate: NKDownloadManagerDelegate?

    var operations: [NKDownloadOperation] = []
    var currentOperation: NKDownloadOperation?
    var downloadingVideo: VideoProtocol?
    var isInQueVideos: [NKVideo] = []
    
    static var sharedInstance = NKDownloadManager()

    func nextOperations() -> [NKDownloadOperation] {
        
        if operations.count > 1 {
            return Array(operations[1..<operations.count])
        }
        return []
    }
    
    func addQue(_ video: NKVideo) {
                
        video.videoQulity = NKUserInfo.shared.qulityNameForVideoQulity()

        let downloadQue = NKDownloadOperation(video: video)

        operations.append(downloadQue)
        isInQueVideos.append(video)
        
        if let delegate = self.downloadStatusDelegate {
            delegate.didAddDownloadList()
        }

        KLog("전체 큐 >> \(self.operations)")
        KLog("=====================")
        for que in self.operations {
            KLog("=== \(que.video?.title) ==")
        }
        KLog("=====================")

        if self.operations.count == 1 {
            
            if let delegate = self.downloadStatusDelegate {
                delegate.startDownload(downloadQue.video!)
            }
            currentOperation = downloadQue
            currentOperation!.delegate = self
            currentOperation?.main()
            KLog("현재 큐 >> \(currentOperation)")
        }
        
        
        downloadQue.completionBlock = { () -> Void in

            KLog("Removing downloadQue > \(downloadQue)")
            self.operations.removeObj(downloadQue)
            self.isInQueVideos.removeObj(downloadQue.video!)
            
            if let delegate = self.downloadStatusDelegate {
                delegate.finishedDownload(downloadQue.video!)
            }
            
            if let nextQue = self.operations.first {
                self.currentOperation = nextQue
                self.currentOperation!.delegate = self
                self.currentOperation?.main()

                if let delegate = self.downloadStatusDelegate {
                    delegate.startDownload(nextQue.video!)
                }
            } else {
                if let delegate = self.downloadStatusDelegate {
                    delegate.emptNextDownloadList()
                }
            }
        }
    }
    
    func cancelCurrentDownloadOperation() {
        
        if let currentOperation = self.currentOperation {
            currentOperation.delegate = nil
            currentOperation.service.downloadRequest?.cancel()
            currentOperation.cancel()
            currentOperation.completionBlock!()
            if let delegate = self.downloadStatusDelegate {
                delegate.didRemoveDownloadList()
                delegate.updateDownloadingStatus(0)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "changeVideoStatus"), object: nil)
        }
    }
    
    func cancelReservedDownloadOperation(_ index: Int) {
        
        if index < operations.count {
            operations.remove(at: index)
            isInQueVideos.remove(at: index)
            if let delegate = self.downloadStatusDelegate {
                delegate.didRemoveDownloadList()
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "changeVideoStatus"), object: nil)
        }
    }
    
    func shouldDownload(_ video: NKVideo, isDownload: Bool, totalData: Int, currentData: Int, error: NSError?) {
        
        downloadingVideo = video
        let percentage: CGFloat = CGFloat(currentData)/CGFloat(totalData)*100
        if let delegate = self.downloadStatusDelegate {
            KLog("다운로드 퍼센트 : \(percentage)")
            delegate.updateDownloadingStatus(percentage)
        }
    }
    
    func finishDownload(_ video: NKVideo, isFinish: Bool, error: NSError?) {
        
        // 다운로드 실패시
        if error != nil {
            NKUtility.showMessage(message: "キャッシング失敗！")
            return
        }

        
        if #available(iOS 9.0, *) {
            NKCoreDataCachedVideo.sharedInstance.saveCachedVideoForSpotlight(video)
        }
        
        // 큐에서 삭제
        if let operation = currentOperation {
            self.isInQueVideos.removeObj(operation.video!)
            self.operations.removeObj(operation)
            currentOperation = nil
            
            NKVideoStatusManager.sharedInstance.didFinishDownloadCacheVideo(video)
        }

    }
    
    func currentOperation(_ operation: NKDownloadOperation) {
        KLog("현재 다운되고 있는 오퍼레이션 >> \(operation)")
        currentOperation = operation
    }
    
    func isInQue(_ video: NKVideo) -> Bool {
        return isInQueVideos.contains(video)
    }
    
    func isDownloading() -> Bool {
        return isInQueVideos.count > 0
    }
}
