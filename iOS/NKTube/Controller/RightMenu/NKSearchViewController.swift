//
//  NKSearchViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/01/16.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import GoogleMobileAds
import DZNEmptyDataSet


class NKSearchViewController: NKSuperVideoListViewController, MainViewCommonProtocol, UITextFieldDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    @IBOutlet weak var olSearchTextField: UITextField!
    @IBOutlet weak var olSearHistoryButton: UIButton!
    @IBOutlet weak var olResultTableView: UITableView!
    @IBOutlet weak var olReserveKeywordTableView: UITableView!
    
    @IBOutlet weak var olBottomHistoryMargin: NSLayoutConstraint!
    @IBOutlet weak var olBottomResultMargin: NSLayoutConstraint!
    
    var searchedVideos: [NKVideo] = []
    var keyworkd: String?
    var reserveKeywords: [String] = []
    var preKeyword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        canPaging = true
        olReserveKeywordTableView.estimatedRowHeight = 40
        olReserveKeywordTableView.rowHeight = UITableViewAutomaticDimension

        olResultTableView.registerCell("NKVideoListCell", cellId: "videoCell")
        olResultTableView.registerCell("NKSearchAdCell", cellId: "searchAdCell")
        
        olResultTableView.emptyDataSetSource = self
        olResultTableView.emptyDataSetDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(NKSearchViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(NKSearchViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(NKSearchViewController.didChangeKeyword(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)

        
        reserveKeywords = NKUserInfo.shared.searchHistory
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismissKeyboard() {
        olSearchTextField.resignFirstResponder()
    }
    
    fileprivate func fetch() {
        
        if let keyworkd = self.keyworkd {
            NKLoadingView.showLoadingView(.rightSearchView)
            NKYouTubeService.sharedInstance.getVideoIdWithKeyword(keyworkd, nextPageToken: self.nextPageToken, complete: { (videos, nextPageToken, error, canPaging) in
                
                for viedo in videos {
                    self.searchedVideos.append(viedo)
                }
                self.canPaging = canPaging
                self.nextPageToken = nextPageToken
                self.olResultTableView.reloadData()
                NKLoadingView.hideLoadingView(.rightSearchView)
            })
        }
        
    }


    // MARK: - MainViewCommonProtocol

    func doScrollToTop() {
        if olReserveKeywordTableView.isHidden == false {
            olReserveKeywordTableView.setContentOffset(CGPoint.zero, animated: true)
        } else {
            olResultTableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func doNeedToReload() {
        olResultTableView.reloadData()
    }

    
    // MARK: - Action
    @IBAction func acShowSearchHIstory(_ sender: AnyObject) {

        // 履歴が表示されている場合
        if self.olReserveKeywordTableView.isHidden == false {
            
            reserveKeywords = []
            self.olReserveKeywordTableView.isHidden = true
            self.olReserveKeywordTableView.reloadData()
        } else {
            reserveKeywords = NKUserInfo.shared.searchHistory
            self.olReserveKeywordTableView.isHidden = false
            self.olReserveKeywordTableView.reloadData()
        }
    }
    
    func readyToSearch() {

        if searchedVideos.count == 0 {
            olSearchTextField.becomeFirstResponder()
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        
        olBottomHistoryMargin.constant = keyboardRectangle.height
        olBottomResultMargin.constant = keyboardRectangle.height
        olReserveKeywordTableView.layoutIfNeeded()        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        olBottomHistoryMargin.constant = 0
        olBottomResultMargin.constant = 0
        olReserveKeywordTableView.layoutIfNeeded()
    }
    
    fileprivate func setSearchHistory() {
        olReserveKeywordTableView.isHidden = false
        reserveKeywords = NKUserInfo.shared.searchHistory
        KLog("reserveKeywords >> \(reserveKeywords)" as AnyObject?)
        olReserveKeywordTableView.reloadData()
    }

    
    func didChangeKeyword(_ notification: Notification) {
        
        let textField = notification.object as! UITextField
        if textField != olSearchTextField {
            return
        }
        
        let searchText = textField.text!
        
        KLog("textDidChange" as AnyObject?)
        KLog("searchText >> \(searchText)" as AnyObject?)
        if searchText == "" {
            reserveKeywords = []
            olReserveKeywordTableView.reloadData()
            setSearchHistory()
            return
        }
        
        NKYouTubeService.sharedInstance.getAutoKeyword(searchText) { (keywordList) -> Void in
            // 이미 다 삭제가 되었다면 반영을 안시킴.
            if self.olSearchTextField.text == "" {
                return
            }
            KLog("keywordList >>\(keywordList)" as AnyObject?)
            self.olReserveKeywordTableView.isHidden = false
            self.reserveKeywords = keywordList
            self.olReserveKeywordTableView.reloadData()
        }
    }
    
    // MARK: - DZNEmptyDataSetSource
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        
        return UIImage(named: "test_network_error")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        // TODO: 이것도 유틸리티로 만들어야 함. 그래야 로컬라이징에도 대응이 되지..
        let attributeString = NSMutableAttributedString(string: "検索さたワード\n見つかりませんでした")
        attributeString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 13), range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSForegroundColorAttributeName, value: NKStyle.lightTextColor, range: NSMakeRange(0, attributeString.length))
        
        attributeString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 23), range: NSMakeRange(0, 7))
        attributeString.addAttribute(NSForegroundColorAttributeName, value: NKStyle.defaultTextColor, range: NSMakeRange(0, 7))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 2.0
        paragraphStyle.alignment = NSTextAlignment.center
        attributeString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributeString.length))

        return attributeString
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        // TODO: 이거 화면사이즈에 맞춰서 비율로 처리를 해야함.
        return -70
    }
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -10
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        KLog("searchBarCancelButtonClicked" as AnyObject?)
        textField.text = ""
        setSearchHistory()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if let keyword = textField.text {
            
            reserveKeywords = []
            olReserveKeywordTableView.reloadData()
            olReserveKeywordTableView.isHidden = true

            if keyword.validateSpace() {
                
                // 연속으로 같은 키워드로 검색할 경우 실제론 검색안함.
                if preKeyword == keyword {
                    olResultTableView.setContentOffset(CGPoint.zero, animated: true)
                    return true
                }
                preKeyword = keyword
                
                // 검색이력
                canPaging = false
                NKUserInfo.shared.setSearchHistory(keyword)
                
                nextPageToken = nil
                keyworkd = keyword
                self.searchedVideos = []
                self.completedPageTokens = []
                self.olResultTableView.reloadData()
                
                fetch()
            }
        }
        return true
    }
    
    
    // MARK: - UITableViewDelegate, DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.olResultTableView {
            return self.searchedVideos.count
        } else {
            let count = self.reserveKeywords.count
            if count >  25 {
                return 25
            }
            return self.reserveKeywords.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
    
        // 검색결과쪽
        if tableView == self.olResultTableView {
            
            if indexPath.row != 0 && indexPath.row%10 == 0 {
                let cell = self.olResultTableView.dequeueReusableCell(withIdentifier: "searchAdCell", for: indexPath) as! NKSearchAdCell
                cell.setBanner(self)
                
                return cell
            } else {
                let cell: NKVideoListCell = self.olResultTableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! NKVideoListCell
                let video = self.searchedVideos[indexPath.row]
                cell.setVideoCellData(video, location: .searchMenu)
                
                // 페이징
                if indexPath.row > searchedVideos.count-3 && canPaging {
                    if let nextPageToken = nextPageToken {
                        if !completedPageTokens.contains(nextPageToken) {
                            completedPageTokens.append(nextPageToken)
                            fetch()
                        }
                    }
                }
                return cell
            }
            
        } else if tableView == self.olReserveKeywordTableView {
            let cell: NKSearchResultCell = self.olReserveKeywordTableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! NKSearchResultCell
            cell.setKeyword(reserveKeywords[indexPath.row])
            return cell
        } else {
            return UITableViewCell(style: .default, reuseIdentifier: "")
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.olResultTableView {
            if indexPath.row != 0 && indexPath.row%10 == 0 {
                return 50
            } else {
                return NKVideoListCell.cellHeight()
            }
        } else {
            return NKSearchResultCell.cellHeight()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
     
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView == olResultTableView {

            let video = searchedVideos[indexPath.row]
            // 재생 로그
            NKAVAudioManager.sharedInstance.startPlay(video)
        } else {
            let keyword = reserveKeywords[indexPath.row]

            reserveKeywords = []
            olReserveKeywordTableView.reloadData()
            olReserveKeywordTableView.isHidden = true                        
            olSearchTextField.text = keyword

            // 검색 발리데이션 체크

            if keyword.validateSpace() {
                // 검색이력
                NKUserInfo.shared.setSearchHistory(keyword)

                NKLoadingView.showLoadingView(.rightSearchView)

                olSearchTextField.resignFirstResponder()
                
                nextPageToken = nil
                NKYouTubeService.sharedInstance.getVideoIdWithKeyword(keyword, nextPageToken: self.nextPageToken, complete: { (videos, nextPageToken, error, canPaging) in
                    self.canPaging = canPaging
                    
                    if error != nil {
                        NKLoadingView.hideLoadingView(.rightSearchView)
                        // 검색결과가 없거나 네트워크 에러임.
                        return
                    }
                    
                    self.keyworkd = keyword
                    self.nextPageToken = nextPageToken
                    self.completedPageTokens = []
                    
                    self.searchedVideos = videos
                    self.olResultTableView.reloadData()
                    self.olResultTableView.setContentOffset(CGPoint.zero, animated: true)
                    NKLoadingView.hideLoadingView(.rightSearchView)
                })
            }
        }
    }
}
