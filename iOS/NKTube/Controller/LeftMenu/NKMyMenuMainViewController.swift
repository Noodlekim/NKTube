//
//  NKMyMenuMainViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/04/02.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

protocol NKMyMenuMainViewControllerDelegate {
    func didStartEditMode(_ isEdit: Bool)
    func didSuccessYouTubeLogin()
    func didLogoutFromYouTube()
    func didChangeDownloadListView(_ open: Bool, height: CGFloat)
}

class NKMyMenuMainViewController: UIViewController, UISearchBarDelegate, NKCachedMovieListViewControllerDelegate, NKYouTubeMenuViewControllerDelegate, NKDownloadStatusViewControllerDelegate {

    @IBOutlet weak var olHeightDownloadStatusView: NSLayoutConstraint!
    @IBOutlet weak var olHeightYoutubeView: NSLayoutConstraint!
    @IBOutlet weak var olHeightCacheView: NSLayoutConstraint!
    @IBOutlet weak var olScrollView: UIScrollView!
    @IBOutlet weak var olHeightContentView: NSLayoutConstraint!
    @IBOutlet weak var olSearchBar: UISearchBar!
    
    var currentHeight: CGFloat = 0.0
    
    var delegate: NKMyMenuMainViewControllerDelegate?
    
    var youtubeMenuViewController: NKYouTubeMenuViewController?
    var cachedMovieListViewController: NKCachedMovieListViewController?
    var downloadStatusViewController: NKDownloadStatusViewController?
    
    var creatingGroupView: UINavigationController?
    
    var priviousHeightOfLoginView: CGFloat = 80.0 + 66.0
    let heightCreatingGroupButton: CGFloat = 60.0
    let helghtCell: CGFloat = 40.0
    
    var isShowingSearchBar: Bool = false
    var isLoadedSearchBar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // 그룹 등록용 Notification등록
        NotificationCenter.default.addObserver(self, selector: #selector(NKMyMenuMainViewController.dismissCreatingGroupView), name: NSNotification.Name(rawValue: "completeCreatingGroup"), object: nil)
        
        // 다운로드 뷰 초기화
        olHeightDownloadStatusView.constant = 0
        
        // ContainerView에서 각각의 ViewController확보
        if self.childViewControllers.count > 1 {
            
            for childVC in childViewControllers {
                
                if let vc = childVC as? NKYouTubeMenuViewController {
                    vc.delegate = self
                    self.youtubeMenuViewController = vc
                }
                
                if let vc = childVC as? NKCachedMovieListViewController {
                    vc.delegate = self
                    self.cachedMovieListViewController = vc
                }

                if let vc = childVC as? NKDownloadStatusViewController {
                    vc.delegate = self
                    self.downloadStatusViewController = vc
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func dismissCreatingGroupView() {
        
        if let navi = creatingGroupView {
            
            UIView.animate(withDuration: aniDuration, animations: { () -> Void in
                navi.view.frame.origin.y = self.view.bounds.height

                }, completion: { (isFinish) -> Void in
                    navi.removeFromParentViewController()
                    navi.view.removeFromSuperview()
            })
            
            if let delegate = self.delegate {
                delegate.didStartEditMode(false)
            }
            creatingGroupView = nil

        }
    }
    
    // MARK: - Private
    fileprivate func loadSearchView() {
        
        let cacheSearchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cacheSearchViewController") as! NKCacheSearchViewController
        self.addChildViewController(cacheSearchViewController)
        self.view.addSubview(cacheSearchViewController.view)
        cacheSearchViewController.loadCacheSearchView(self.view)

    }
    
    fileprivate func updateEntireContireView() {
        
        olHeightContentView.constant = olHeightYoutubeView.constant + olHeightCacheView.constant + olHeightDownloadStatusView.constant

    }

    
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        loadSearchView()
        return false
    }
    
    // MARK: - UIScrollViewDelegate
    // 아마 평소에는 숨겨져 있다가 스크롤이 끝까지 되었을때 좀 더 자연스럽게 보여지면 좋을 것 같음.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // 서치바 보임
        if self.isLoadedSearchBar == false && isShowingSearchBar == false {
            
            if scrollView.contentOffset.y < -8 {
                isShowingSearchBar = true

                UIView.animate(withDuration: aniDuration*2, animations: { () -> Void in
                    scrollView.layoutIfNeeded()
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: true)
                    self.updateEntireContireView()
                    }, completion: { (isFinish) -> Void in
                        self.isLoadedSearchBar = true
                        self.isShowingSearchBar = false
                })
            }
        }
        // 서치바 사라짐
        else if (self.isLoadedSearchBar == true && isShowingSearchBar == false) {
            if scrollView.contentOffset.y < 44 && scrollView.contentOffset.y > 5 {
                isShowingSearchBar = false
                UIView.animate(withDuration: aniDuration*2, animations: { () -> Void in
                    scrollView.layoutIfNeeded()
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: true)
                    self.updateEntireContireView()
                    }, completion: { (isFinish) -> Void in

                        self.isLoadedSearchBar = false
                        self.isShowingSearchBar = false
                })
            }
        }
    }
    
    // MARK: - NKCachedMovieListViewControllerDelegate
    func didChangeHeight(_ isEdit: Bool, height: CGFloat) {

        UIView.animate(withDuration: aniDuration, animations: { () -> Void in
            
            if isEdit {
                self.olHeightCacheView.constant = self.view.frame.height-20
            } else {
                self.olHeightCacheView.constant = height
                
                var heightCacheView = height
                let heightScreen = UIScreen.main.bounds.height-20
                if heightScreen > heightCacheView + self.olHeightYoutubeView.constant + self.olHeightDownloadStatusView.constant {
                    heightCacheView = heightScreen - self.olHeightYoutubeView.constant - self.olHeightDownloadStatusView.constant
                }
                self.olHeightCacheView.constant = heightCacheView+1

            }
            self.updateEntireContireView()
            self.view.layoutIfNeeded()
        }) 
    }

    func beginEditMode(_ modeOn: Bool) {
       
        if let delegate = self.delegate {
            delegate.didStartEditMode(modeOn)
        }
        
        UIView.animate(withDuration: aniDuration, animations: { () -> Void in
            
            if modeOn {
                self.olHeightYoutubeView.constant = 0.0
            } else {
                self.olHeightYoutubeView.constant = self.priviousHeightOfLoginView
            }
            self.olScrollView.isScrollEnabled = !modeOn
            self.view.layoutIfNeeded()
        }) 
    }
    
    func beginCreateGroup() {

        if creatingGroupView != nil {
            return
        }

        if let delegate = self.delegate {
            delegate.didStartEditMode(true)
        }

        let navi = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreatingGroupNavigationController") as! UINavigationController
        navi.view.frame = self.view.bounds
        navi.view.frame.origin.y = self.view.bounds.height
        self.addChildViewController(navi)
        self.view.addSubview(navi.view)

        UIView.animate(withDuration: aniDuration, animations: { () -> Void in

            navi.view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }) 
        creatingGroupView = navi
    }
    
    

    // MARK: - MainViewCommonProtocol

    func doScrollToTop() {
        let numberOfChild = self.navigationController?.viewControllers.count
        if numberOfChild == 1 {
            olScrollView.setContentOffset(CGPoint.zero, animated: true)
        } else {
            if let vc = self.navigationController?.viewControllers.last as? MainViewCommonProtocol {
                vc.doScrollToTop()
            }
        }
    }
    
    func doNeedToReload() {
        let numberOfChild = self.navigationController?.viewControllers.count
        if numberOfChild == 1 {
            olScrollView.setContentOffset(CGPoint.zero, animated: true)
        } else {
            if let vc = self.navigationController?.viewControllers.last as? MainViewCommonProtocol {
                vc.doNeedToReload()
            }
        }
    }


    // MARK: - NKYouTubeMenuViewControllerDelegate
    
    func didLoginYouTube(_ height: CGFloat) {
        priviousHeightOfLoginView = height
        
        if let delegate = self.delegate {
            delegate.didSuccessYouTubeLogin()
        }
        
        olHeightYoutubeView.constant = priviousHeightOfLoginView
        updateEntireContireView()
        cachedMovieListViewController?.cacheTableView.reloadData()
        view.layoutIfNeeded()
    }
    
    func didLogoutYouTube() {
        
        priviousHeightOfLoginView = 80+66
        if let delegate = self.delegate {
            delegate.didLogoutFromYouTube()
        }
        
        olHeightYoutubeView.constant = 80+66
        updateEntireContireView()
        cachedMovieListViewController?.cacheTableView.reloadData()
        view.layoutIfNeeded()
    }
    
    func toggleDownloadHeight(_ complete:((_ finish: Bool)-> Void)?) {
        UIView.animate(withDuration: aniDuration, animations: {
            var isOpen = false
            if self.olHeightDownloadStatusView.constant == self.helghtCell {
                isOpen = false
                self.olHeightDownloadStatusView.constant = self.currentHeight
            } else {
                isOpen = true
                self.olHeightDownloadStatusView.constant = self.helghtCell
            }
            if let delegate = self.delegate {
                delegate.didChangeDownloadListView(!isOpen, height: self.olHeightDownloadStatusView.constant)
            }
            self.updateEntireContireView()
            self.view.layoutIfNeeded()

            }, completion: complete)
    }
    
    // MARK: - NKDownloadStatusViewControllerDelegate
    func toggleDownloadListView(_ height: CGFloat) {
        currentHeight = height
        toggleDownloadHeight(nil)
    }
    
    func updateDownloadListView(_ height: CGFloat) {
        if let delegate = self.delegate {
            delegate.didChangeDownloadListView(!(self.currentHeight == height), height: height)
        }

        currentHeight = height
        UIView.animate(withDuration: aniDuration, animations: { () -> Void in
            
            self.olHeightDownloadStatusView.constant = height
            self.updateEntireContireView()
            self.view.layoutIfNeeded()
        }) 
    }

    func addVideoInQue(_ height: CGFloat) {
        currentHeight = height
    }
    
    func didStartDownload() {
        
        currentHeight = helghtCell
        if let delegate = self.delegate {
            delegate.didChangeDownloadListView(false, height: currentHeight)
        }

        UIView.animate(withDuration: aniDuration, animations: { () -> Void in
            
            self.olHeightDownloadStatusView.constant = self.currentHeight
            self.updateEntireContireView()
            self.view.layoutIfNeeded()
        }) 
    }
    
    func didFinishAllDownload() {
        UIView.animate(withDuration: aniDuration, animations: { () -> Void in
            
            self.olHeightDownloadStatusView.constant = 0.0
            self.updateEntireContireView()
            self.view.layoutIfNeeded()
        }) 
    }
    

}
