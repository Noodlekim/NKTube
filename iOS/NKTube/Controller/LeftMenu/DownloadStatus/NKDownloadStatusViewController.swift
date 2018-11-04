//
//  NKDownloadStatusViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/06.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

protocol NKDownloadStatusViewControllerDelegate {
    func didStartDownload()
    func toggleDownloadListView(_ height: CGFloat)
    func updateDownloadListView(_ height: CGFloat)
    func didFinishAllDownload()
    func addVideoInQue(_ height: CGFloat)
}

class NKDownloadStatusViewController: UIViewController, NKDownloadManagerDelegate {

    var delegate: NKDownloadStatusViewControllerDelegate?
    
    @IBOutlet weak var olCurrentTitleLabel: UILabel!
    @IBOutlet weak var olLeftGageMargin: NSLayoutConstraint!
    @IBOutlet weak var olHeightTop: NSLayoutConstraint!
    @IBOutlet weak var olTableView: UITableView!
    @IBOutlet weak var olImageView: UIImageView!
    
    @IBOutlet weak var olDownloadBadge: UIButton!
    @IBOutlet var tabgesture: UITapGestureRecognizer!
    @IBOutlet var olProcessingImage: UIImageView!
    @IBOutlet var olCancelButton: UIButton!
    @IBOutlet var olChargeImageView: UIImageView!
    
    let heightCell: CGFloat = 40.0
    var isOpen: Bool = false
    
    var downloadingImages: [UIImage] = []

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NKDownloadManager.sharedInstance.downloadStatusDelegate = self
        olTableView.estimatedRowHeight = 40
        olTableView.rowHeight = UITableViewAutomaticDimension
        
        setAnimationImage()
    }
    
    
    // MARK: - Action
    
    @IBAction func acCancelDownload(_ sender: AnyObject) {
        
        NKDownloadManager.sharedInstance.cancelCurrentDownloadOperation()
        let countOfdownload = NKDownloadManager.sharedInstance.nextOperations().count
        if countOfdownload == 0 {
            if let delegate = self.delegate {
                delegate.didFinishAllDownload()
            }
        }
    }
    
    @IBAction func acToggleDownloadView() {
        let nextQues = NKDownloadManager.sharedInstance.nextOperations()
        
        if nextQues.count == 0 {
            KLog("더이상 없음요!" as AnyObject?)
            return
        }
        
        isOpen = !isOpen
        if let delegate = self.delegate {
            if self.isOpen {
                let numberOfQue = nextQues.count+1
                let height = CGFloat(numberOfQue)*self.heightCell
                delegate.toggleDownloadListView(height)

            } else {
                delegate.toggleDownloadListView(0.0)
            }
        }
    }

    // MARK: - NKDownloadManagerDelegate
    func startDownload(_ video: NKVideo) {
        DispatchQueue.main.async {
            self.downloadSetup()

            if let d = self.delegate {
                d.didStartDownload()
            }
            self.olImageView.sd_setImage(with: URL(string: video.thumbMedium!), placeholderImage: NKImage.defaultThumbnail)
            self.olCurrentTitleLabel.text = video.title
            self.olTableView.reloadData()
        }
    }
    
    func finishedDownload(_ video: NKVideo) {
        
        KLog("다운로드 완료!" as AnyObject?)
        DispatchQueue.main.async {
            self.reset()
            
            if let delegate = self.delegate {
                let numberOfQue = NKDownloadManager.sharedInstance.nextOperations().count
                var height: CGFloat = 0.0
                if numberOfQue != 0 {
                    height = CGFloat(numberOfQue+1)*self.heightCell
                }
                delegate.updateDownloadListView(height)
            }
        }
    }

    func updateDownloadingStatus(_ percentage: CGFloat) {
        
        DispatchQueue.main.async {
            if percentage > 90 {
                self.startProcessing(true)
            } else if (percentage > 98) {
                self.startProcessing(false)
            }
            self.olLeftGageMargin.constant = (self.view.frame.width - self.olImageView.frame.width)/100 * (100-percentage)
        }
    }
    
    fileprivate func setAnimationImage() {
        var imageNames: [String] = []
        for i in 1..<17 {
            let name = "dning"+"\(i)"
            imageNames.append(name)
        }

        var images: [UIImage] = []
        for name in imageNames {
            images.append(UIImage(named: name)!)
        }
        downloadingImages = images
    }

    fileprivate func startProcessing(_ isProcessing: Bool) {
        if isProcessing {
            if !olProcessingImage.isAnimating {
                UIView.animate(withDuration: aniDuration, animations: { 
                    self.olChargeImageView.backgroundColor = NKStyle.RGB(210, green: 235, blue: 240)
                    self.olCancelButton.isHidden = true
                    self.olProcessingImage.animationImages = self.downloadingImages
                    self.olProcessingImage.animationDuration = 1.0
                    self.olProcessingImage.animationRepeatCount = 0
                    self.olProcessingImage.startAnimating()
                })
            }
        } else {
            
            UIView.animate(withDuration: aniDuration, animations: {
                self.olChargeImageView.backgroundColor = NKStyle.RGB(101, green: 188, blue: 208)
                self.olProcessingImage.stopAnimating()
                self.olProcessingImage.image = UIImage(named: "icon_dncomplete")
            })
        }
    }
    
    fileprivate func reset() {
        olProcessingImage.animationImages = nil
        olProcessingImage.image = nil
        olProcessingImage.stopAnimating()
        
        self.olImageView.image = nil
        self.olCurrentTitleLabel.text = ""
        self.olTableView.reloadData()
    }

    fileprivate func downloadSetup() {
        olProcessingImage.image = nil
        olCancelButton.isHidden = false
        olChargeImageView.backgroundColor = NKStyle.RGB(101, green: 188, blue: 208)

    }


    
    // 추가 되었을 경우
    func didAddDownloadList() {
        
        DispatchQueue.main.async {
            self.olTableView.reloadData()
            let numberOfQue = NKDownloadManager.sharedInstance.nextOperations().count+1
            let height = CGFloat(numberOfQue)*self.heightCell
            if let delegate = self.delegate {
                if self.isOpen {
                    delegate.updateDownloadListView(height)
                } else {
                    delegate.addVideoInQue(height)
                }
                
            }
        }
    }
    
    // 다운로드 리스트에서 제거 되었을 경우
    func didRemoveDownloadList() {
        
        DispatchQueue.main.async {
            self.olTableView.reloadData()
            let numberOfQue = NKDownloadManager.sharedInstance.operations.count
            let height = CGFloat(numberOfQue)*self.heightCell
            if let delegate = self.delegate {
                if numberOfQue == 0 {
                    self.isOpen = false
                    delegate.didFinishAllDownload()
                } else {
                    delegate.updateDownloadListView(height)
                }
            }
        }
    }

    // 다음 곡이 하나도 없을 경우.
    func emptNextDownloadList() {
        DispatchQueue.main.async {
            self.olCurrentTitleLabel.text = "キャッシングリストがありません。"
            self.olLeftGageMargin.constant = self.view.frame.width
            self.olTableView.reloadData()
        }

    }

    // MARK: - UITableViewDelegate, DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return NKDownloadManager.sharedInstance.nextOperations().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = olTableView.dequeueReusableCell(withIdentifier: "downloadListCell") as! NKDownloadListCell
        if indexPath.row < NKDownloadManager.sharedInstance.nextOperations().count {
            let item = NKDownloadManager.sharedInstance.nextOperations()[indexPath.row]
            if let video = item.video {
                cell.setData(video, index: indexPath.row+1)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
    }

    
}
