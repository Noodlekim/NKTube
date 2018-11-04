//
//  NKSelectGroupViewController.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/13.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKSelectGroupViewController: UIViewController, NKInputAccessaryDelegate, UITextFieldDelegate {

    @IBOutlet weak var olTableView: UITableView!

    var selectedVideos: [CachedVideo] = []
    var selectedGroup: String = defaultGroupName
    
    let heightOfSection: CGFloat = 60.0
    var groupTitles: [GroupTitle] {
        
        let groups = NKCoreDataCachedVideo.sharedInstance.getGroupTitles()
        for group in groups {
            KLog("group.order >> \(group.order)")
        }
        return groups.sorted { (group1, group2) -> Bool in
            return (group1.order!.compare(group2.order!) == .orderedAscending)
        }
    }
    
    @IBOutlet weak var olHeightNewGroupView: NSLayoutConstraint!
    @IBOutlet weak var olCreateNewButton: UIButton!
    @IBOutlet weak var olCreateNewLabel: UILabel!
    @IBOutlet weak var olInputField: UITextField!

    @IBAction func acCreateNewGroup(_ sender: AnyObject) {
        
        olCreateNewButton.isHidden = true
        olCreateNewLabel.isHidden = true
        olInputField.becomeFirstResponder()
    }
    
    var checkmarkImage: UIImageView?

    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let actionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 60))
        actionButton.addTarget(self, action: #selector(NKSelectGroupViewController.dismissView), for: .touchUpInside)
        actionButton.setImage(UIImage(named: "icon_dismiss"), for: UIControlState())
        actionButton.contentHorizontalAlignment = .left
        actionButton.backgroundColor = UIColor.clear
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: actionButton)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = NKStyle.defaultTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = "イージーグルーピング"
        
        navigationItem.titleView = titleLabel
        
        let inputAccessary = NKInputAccessary(frame: UIScreen.main.bounds)
        inputAccessary.delegate = self
        olInputField.inputAccessoryView = inputAccessary
        
        let accessary = UIImageView()
        accessary.image = UIImage(named: "icon_check_mark")
        accessary.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        accessary.contentMode = UIViewContentMode.center
        checkmarkImage = accessary

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NKCreatingGroupViewController {
            vc.selectedGroupName = selectedGroup
        }
    }
    
    func dismissView() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "completeCreatingGroup"), object: nil)
    }
    
    func setCreateNewGroupHeader() {
        
        let header = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        header.setTitle("新しいグループ", for: UIControlState())
        header.addTarget(self, action: #selector(NKSelectGroupViewController.createNewGroup), for: .touchUpInside)
        olTableView.tableHeaderView = header
    }
    
    func createNewGroup() {
        if let newName = olInputField.text {
            
            let groups = groupTitles

            for group in groups {
                if newName == group.title! {
                    KLog("중복된 이름입니다.")
                    NKUtility.showMessage(message: "同じグループ名があります")
                    olInputField.text = ""
                    return
                }
            }
            //
            if !newName.validateSpace() {
                NKUtility.showMessage(message: "正しいグループ名を入力してください")
                return
            }
            
            NKOrderManager.sharedInstance.AddNewGroup(newName, complete: { (isSuccess) in
                if isSuccess {
                    self.selectedGroup = newName
                    self.olTableView.reloadData()
                }
            })
            
            olCreateNewButton.isHidden = false
            olCreateNewLabel.isHidden = false
            olInputField.text = ""
            olInputField.resignFirstResponder()
        }
        
    }
    
    
    // MARK: - NKInputAccessaryDelegate
    
    func didComplete() {

        createNewGroup()
    }
    
    func didCancel() {
        olCreateNewButton.isHidden = false
        olCreateNewLabel.isHidden = false
        olInputField.text = ""
        olInputField.resignFirstResponder()
    }

    
    // MARK: - UITableViewDelegate, UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groupTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let groupTitle = groupTitles[indexPath.row].title!
        let cell: NKSelectionGroupCell = self.olTableView.dequeueReusableCell(withIdentifier: "selectionGroupCell", for: indexPath) as! NKSelectionGroupCell
        cell.setData(groupTitle)
        
        if groupTitle == selectedGroup {
            cell.accessoryView = checkmarkImage
        } else {
            cell.accessoryView = nil
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 41.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let groupTitle = groupTitles[indexPath.row].title!
        selectedGroup = groupTitle
        olTableView.reloadData()
        
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        createNewGroup()
        return true
    }
}
