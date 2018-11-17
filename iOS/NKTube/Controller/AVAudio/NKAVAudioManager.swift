//
//  NKAVAudioManager.swift
//  NKTube
//
//  Created by NoodleKim on 2016/02/09.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import MediaPlayer

// 각종 재생을 이녀석이 관리하도록
// 기본적으로 MovieViewController에서 Delegate를 이용을 해서 처리를 하도록...
/*
    임의의 컨트롤러에서 videoId를 가지고 재생을 하고 싶을 때
    다음곡 가져오기
    현재곡
    이전곡 가져오기?
    아마 나중에 로컬에 mp3나 영상도 재생할때 컨트롤을 하게 될지도.. 암튼 이정도까지..
    간단히 캐싱
*/
protocol NKAVAudioManagerDelegate {
    
    func playVideo(_ video: VideoProtocol)
}
class NKAVAudioManager: NSObject {

    var delegate: NKAVAudioManagerDelegate?
    var playingVideo: VideoProtocol? // TODO: 일단 캐싱이 안된 오브젝트만 취급하는 걸로.
    var downloadingVideoId: String?
    
    static let sharedInstance = NKAVAudioManager()

    
    // MARK: - 재생컨트롤 관련
    func startPlay(_ video: VideoProtocol) {
        
        if let delegate = delegate {            
            playingVideo = video
            delegate.playVideo(video)
        }
    }

    // 사용되지 않고 있음.
    func startPlayWithVideoId(_ videoId: String) {
        
        if let video = CachedVideo.oldCachedVideo(videoId) {
            playingVideo = video
            if let delegate = delegate {
                delegate.playVideo(video)
            } else {
                // 기동중이 아닐 경우엔... 3초 딜레이를 준다.
                let delay = 3 * Double(NSEC_PER_SEC)
                let time  = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    if let delegate = self.delegate {
                        delegate.playVideo(video)
                    }
                })

                
            }
        }
    }    
}
