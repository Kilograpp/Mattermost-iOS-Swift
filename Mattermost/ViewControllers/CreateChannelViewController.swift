//
//  CreateChannelViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 09.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class CreateChannelViewController: UIViewController {

//MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var fields: [ChannelCreateField] = [ChannelCreateField("Channel Name","displayName"),
                                                    ChannelCreateField("Channel handle","handle"),
                                                    ChannelCreateField("Enter header (optional)","header"),
                                                    ChannelCreateField("Purpose header (optional)","purpose")]
    fileprivate var createButton: UIBarButtonItem!
    fileprivate var privateType: String! = ""
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        setupNibs()
    }
}


/*//MARK: Configuration
extension CreateChannelViewController: CreateChannelViewControllerConfiguration {
    func configure(privateType: String) {
        self.privateType = privateType
    }
}

fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
}

fileprivate protocol Action: class {
    func backAction()
    func createAction()
}

fileprivate protocol Navigation: class {
    func returnToChannel()
}

fileprivate protocol Request: class {

}


//MARK: UpdateFields
extension CreateChannelViewController: UpdateFields{
    func updateFields(_ index: Int, _ text: String) {
        fields[index].value = text
    }
}
//MARK: Setup
extension CreateChannelViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupSwipeRight()
        setupNameTextField()
       // setupHeaderTextField()
       // setupPurposeTextField()
    }
    
    func setupNavigationBar() {
        if self.privateType == "P"{
            self.title = "New private group"
        }else{
            self.title = "New channel"
        }
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.createButton = UIBarButtonItem.init(title: "Create", style: .done, target: self, action: #selector(createAction))
        self.createButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.createButton
    }
    
    func setupSwipeRight() {
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(backAction))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    func setupNameTextField() {
        if self.privateType == "P"{
            self.nameTextField.placeholder = "Group Name"
        }else{
            self.nameTextField.placeholder = "Channel Name"
        }
    }
}


//MARK: Action
extension CreateChannelViewController: Action {
    func backAction() {
        returnToChannel()
    }
    
    func createAction() {
        createChannel()
    }
}


//MARK: Navigation
extension CreateChannelViewController: Navigation {
    func returnToChannel() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func returnToNew(channel: Channel) {
        (self.menuContainerViewController.leftMenuViewController as! LeftMenuViewController).updateSelectionFor(channel)
        ChannelObserver.sharedObserver.selectedChannel = channel
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension CreateChannelViewController: Request {
    func createChannel() {
        let name = self.nameTextField.text
        let header = self.headerTextView.text
        let purpose = self.purposeTextView.text
        self.createButton.isEnabled = false
        Api.sharedInstance.createChannel(self.privateType, name: name!, header: header!, purpose: purpose!) { (channel, error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                self.createButton.isEnabled = true
                return
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
            let typeName = (self.privateType == "O") ? "Channel" : "Group"
            AlertManager.sharedManager.showSuccesWithMessage(message: typeName + " was successfully created")
            self.returnToNew(channel: channel!)
        }
    }
}*/

extension CreateChannelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Handle"
        case 2: return "Header"
        case 3: return "Purpose"
        default:
            return nil
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch (indexPath.section) {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "createChannelNameCell") as! CreateChannelNameCell!
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "channelInfoCell") as! CreateChannelHandleCell!
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "channelInfoCell") as! CreateChannelHeaderAndPurposeCell!
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "channelInfoCell") as! CreateChannelHeaderAndPurposeCell!
            default: break
        }
        (cell as! CreateChannelNameCell).delgate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 90 }
        return ChannelInfoCell.heightWithObject(fields[indexPath.section].value)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 1.0 }
        return 15.0
    }
    
    fileprivate func setupNibs() {
        let nib1 = UINib(nibName: "CreateChannelNameCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "createChannelNameCell")
        
        let nib2 = UINib(nibName: "CreateChannelHeaderAndPurposeCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "channelInfoCell")
        
        let nib3 = UINib(nibName: "CreateChannelHandleCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "channelInfoCell")
    }
}

extension CreateChannelViewController: CellUpdated {
    func cellUpdated(text: String) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

