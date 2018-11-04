//
//  NKSuperVideoListViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/06/29.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

/*
 페이징관련 공통 프로퍼티
 Notification 관련 공통처리 담당
    > Youtube관련VC
    > 메인 관련영상 VC
    > 검색쪽 VC
 */
class NKSuperVideoListViewController: UIViewController {

    @IBOutlet weak var olTableView: UITableView!

    var nextPageToken: String?
    var completedPageTokens: [String] = []
    var canPaging: Bool = false
    var isPaging: Bool = false

    


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
