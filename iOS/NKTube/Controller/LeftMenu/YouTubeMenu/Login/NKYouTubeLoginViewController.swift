//
//  NKYouTubeLoginViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/04/02.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit
import Alamofire

class NKYouTubeLoginViewController: UIViewController {

    var isLoad: Bool = false
    var loginViewController: UIViewController?

    var isVerified: Bool = false
    var stoken: String?
    var loading = UIActivityIndicatorView(frame: CGRect(x: 100, y: 100, width: 40, height: 40))
        
    @IBOutlet weak var signInButton: GIDSignInButton!    
    @IBOutlet weak var olWebView: UIWebView!
    
    // MARK: - View life cycle
    let loginUrlStr = "https://accounts.google.com/o/oauth2/auth?client_id="+clientId+"&redirect_uri=http://localhost/oauth2callback&scope="+scope+"&response_type=code&access_type=offline"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = NKStyle.backButtonItem(self.navigationController!)
        navigationItem.titleView = NKStyle.navititleLabel("ログリン")

        loading.color = UIColor.white
        view.addSubview(loading)
        NKFlurryManager.sharedInstance.viewForYouTubeMenuLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if let encodeUrl = loginUrlStr.addingPercentEscapes(using: String.Encoding.utf8) {
            if let loginUrl = URL(string: encodeUrl) {
                olWebView.loadRequest(URLRequest(url: loginUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0))
            }
        }
        
    }
    
    // MARK: - Private
    func getAccessToken() {
        
        if let stoken = stoken {
            let postbody = "code="+stoken+"&client_id="+clientId+"&client_secret=&redirect_uri=http://localhost/oauth2callback&grant_type=authorization_code"
            let postData = postbody.data(using: String.Encoding.ascii, allowLossyConversion: true)
            let postLength = "\(postData!.count)"
            
            let accessUrl = "https://accounts.google.com/o/oauth2/token"

            let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: accessUrl)!)
            request.httpMethod = "POST"
            request.setValue(postLength, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = postData
            
            
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue(), completionHandler: { (response, data, error) -> Void in
                
                if error == nil {
                    
                    if let httpresp = response as? HTTPURLResponse {
                        
                        if httpresp.statusCode == 200 {
                            
                            do {
                                let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [AnyHashable: Any]

                                if let dict = dict {
                                    let creds = MAB_GoogleUserCredentials.sharedInstance()
                                    creds?.token = MAB_GoogleAccessToken.init(from: dict)
                                    
                                    DispatchQueue.main.async {
                                        creds?.saveToken()
                                        // Token저장
                                        let accessToken = MAB_GoogleUserCredentials.sharedInstance().token.accessToken
                                        NKUserInfo.sharedInstance.setAccessToken(accessToken!)
                                        NKFlurryManager.sharedInstance.actionForYoutubeLoginSuccess()
                                        NKUtility.showMessage(message: "ログイン成功しました")
                                        // 돌아가기
                                        self.navigationController?.popToRootViewController(animated: true)
                                    }
                                }

                            } catch let tokenError as NSError {
                                // 에러
                                // 역시나 돌아가기?
                                KLog("Get Token Error: \(tokenError)");
                                NKFlurryManager.sharedInstance.actionForYoutubeLoginFailGetToken()
                                NKUtility.showMessage(message: "ログイン失敗しました")
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                } else {
                    KLog("Http Error: \(error)");
                    NKFlurryManager.sharedInstance.actionForYoutubeLoginFailHttpError()
                    NKUtility.showMessage(message: "ログイン失敗しました")
                    self.navigationController?.popToRootViewController(animated: true)

                }
            })
        }
    }
    
    //MARK: - UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        if request.url?.absoluteString.range(of: "http://localhost/oauth2callback?code=") != nil {
            
            if !isVerified {
               isVerified = true
                
                stoken = request.url?.absoluteString .components(separatedBy: "code=")[1]
                self.getAccessToken()
            }
            return false
        }
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        loading.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loading.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: NSError?) {
        loading.stopAnimating()
        KLog("webView didFailError : \(error)")
    }
}
