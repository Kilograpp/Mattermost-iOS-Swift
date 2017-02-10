//
//  CreateChannelViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 09.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class CreateChannelViewController: UIViewController, UITableViewDataSource {

//MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    fileprivate var fields: [ChannelCreateField] = [ChannelCreateField("Channel Name","displayName"),
                                                    ChannelCreateField("Channel handle","handle"),
                                                    ChannelCreateField("Enter header (optional)","header"),
                                                    ChannelCreateField("Purpose header (optional)","purpose")]
    fileprivate var createButton: UIBarButtonItem!
    fileprivate var privateType: String!
    fileprivate var handleError: Bool = false
    fileprivate var channelNameError: Bool = false
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNibs()
        setupKeyboardNotification()
        tableView.dataSource = self
        tableView.delegate = self
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        replaceStatusBar()
    }
    
    fileprivate func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown (notification: NSNotification)
    {
        if let info = notification.userInfo {
            if let keyboardSize =  (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
                var contentInsets:UIEdgeInsets
                if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
                    contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
                }
                else {
                    contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.width, 0.0)
                }
            
                tableView.contentInset = contentInsets
            
                tableView.scrollIndicatorInsets = tableView.contentInset
            }
        }
    }
    
    func keyboardWillBeHidden (notification: NSNotification)
    {
       tableView.contentInset = UIEdgeInsets.zero
       tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    fileprivate func setupNibs() {
        let nib1 = UINib(nibName: "CreateChannelNameCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "createChannelNameCell")
        
        let nib2 = UINib(nibName: "ChannelInfoCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "channelInfoCell")

        
    }
}


//MARK: Configuration
extension CreateChannelViewController {
    func configure(privateType: String) {
        self.privateType = privateType
    }
}

fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
}

fileprivate protocol Action: class {
    func createAction()
}

fileprivate protocol Navigation: class {
    func returnToNew(channelId: String)
}

fileprivate protocol Request: class {

}

//MARK: Setup
extension CreateChannelViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        if self.privateType == "P"{
            self.title = "New Group"
        }else{
            self.title = "New Channel"
        }
        
        self.createButton = UIBarButtonItem.init(title: "Create", style: .done, target: self, action: #selector(createAction))
        self.navigationItem.rightBarButtonItem = self.createButton
    }
    
    func setupNameTextField() {
        if self.privateType == "P"{
            self.fields[0].placeholder = "Group Name"
        }else{
            self.fields[0].placeholder = "Channel Name"
        }
    }
}


//MARK: Action
extension CreateChannelViewController: Action {
    func createAction() {
        createChannel()
    }
}


//MARK: Navigation
extension CreateChannelViewController: Navigation {
    func returnToNew(channelId: String) {
        guard let channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId) else { return }
        (self.menuContainerViewController.leftMenuViewController as! LeftMenuViewController).updateSelectionFor(channel)
        ChannelObserver.sharedObserver.selectedChannel = channel
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension CreateChannelViewController: Request {
    func createChannel() {
        let displayName = self.fields[0].value
        let name        = self.fields[1].value
        let header      = self.fields[2].value
        let purpose     = self.fields[3].value
        
        if self.fields[0].value.characters.count < 1 {
            AlertManager.sharedManager.showErrorWithMessage(message: "Incorrect Channel Name")
            channelNameError = true
            self.tableView.reloadData()
            return
        }
        
        Api.sharedInstance.createChannel(self.privateType, displayName: displayName, name: name, header: header, purpose: purpose) { (channelId, error) in
            guard error == nil else {
                var message = (error?.message)!
                if error?.code == 500 {
                    self.handleError = true
                    self.tableView.reloadData()
                    message = "Incorrect Handle"
                }
                AlertManager.sharedManager.showErrorWithMessage(message: message)
                self.createButton.isEnabled = true
                return
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
            let typeName = (self.privateType == "O") ? "Channel" : "Group"
            AlertManager.sharedManager.showSuccesWithMessage(message: typeName + " was successfully created")
            self.returnToNew(channelId: channelId!)
        }
    }
}

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
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1: return "Please use only Latin letters, digits and symbol \"-\""
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
            let cell0 = tableView.dequeueReusableCell(withIdentifier: "createChannelNameCell") as! CreateChannelNameCell
            cell0.field = self.fields[indexPath.section]
            cell0.handleField = self.fields[1]
            cell0.placeholder.textColor = channelNameError ? .red : UIColor.kg_lightGrayTextColor()
            cell0.delegate = self
            cell = cell0
        case 1:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "channelInfoCell") as! ChannelInfoCell
            cell1.field = self.fields[indexPath.section]
            cell1.isHandlerCell = true
            cell1.infoText.text = self.fields[indexPath.section].value.lowercased().replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range:nil)
            cell1.placeholder.textColor = handleError ? .red : UIColor.kg_lightGrayTextColor()
            cell1.infoText.textColor = handleError ? .red : .black
            cell1.delegate = self
            cell1.limitLength = 48.0
            cell = cell1
        case 2:
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "channelInfoCell") as! ChannelInfoCell
            cell2.field = self.fields[indexPath.section]
            cell2.infoText.text = self.fields[indexPath.section].value
            cell2.delegate = self
            cell = cell2
        case 3:
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "channelInfoCell") as! ChannelInfoCell
            cell3.field = self.fields[indexPath.section]
            cell3.infoText.text = self.fields[indexPath.section].value
            cell3.delegate = self
            cell = cell3
            default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 90 }
        return ChannelInfoCell.heightWithObject(fields[indexPath.section].value)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 1.0 }
        if section == 2 { return 35.0 }
        return 15.0
    }
}

extension CreateChannelViewController: CellUpdated {
    func cellUpdated(text: String) {
        if let handleCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 1)) {
            (handleCell as! ChannelInfoCell).infoText.text = fields[1].value.lowercased()
            (handleCell as! ChannelInfoCell).placeholder.isHidden = fields[1].value != "" ? true : false
            if self.fields[1].value != "" {
                (handleCell as! ChannelInfoCell).placeholder.textColor = UIColor.kg_lightGrayTextColor()
                (handleCell as! ChannelInfoCell).infoText.textColor = .black
                handleError = false
            }
        }
        if let channelNameCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) {
            if self.fields[0].value != "" {
                (channelNameCell as! CreateChannelNameCell).placeholder.textColor = UIColor.kg_lightGrayTextColor()
                channelNameError = false
            }
            
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

