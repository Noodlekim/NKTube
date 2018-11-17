//
//  NKDownloadOperation.swift
//  NKTube
//
//  Created by NoodleKim on 2016/02/21.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit


protocol NKDownloadOperationDelegate {
    
    func shouldDownload(_ video: NKVideo, isDownload: Bool, totalData: Int, currentData: Int, error: NSError?)
    func finishDownload(_ video: NKVideo, isFinish: Bool, error: NSError?)
    func currentOperation(_ operation: NKDownloadOperation)

}


class NKDownloadOperation: Operation {

    var delegate: NKDownloadOperationDelegate?
    var video: NKVideo?
    var videoId: String?
    let service = NKYouTubeService()

    
    init(video: NKVideo) {
        super.init()
        self.video = video
        self.queuePriority = Operation.QueuePriority.normal
    }
    
    override func main() {
        
        if self.isCancelled {
            return
        }
        if let video = self.video {
            
            if let delegate = self.delegate {
                
                delegate.currentOperation(self)
                service.downloadYouTubeWithViedo(video, quality: NKUserInfo.shared.videoQulity, downloadingStatus: { (isDownload, totalData, currentData, error) in
                    if self.isCancelled {
                        return
                    }
                    delegate.shouldDownload(video, isDownload: isDownload, totalData: totalData, currentData: currentData, error: error)
                    
                    }, complete: { (isSuccess, error, binaryData) in
                        if error != nil {
                            delegate.finishDownload(video, isFinish: false, error: error)
                            return
                        }
                        video.binaryData = binaryData
                        delegate.finishDownload(video, isFinish: isSuccess, error: error)
                        self.completionBlock!()
                })
            }
            
        }
    }
}
