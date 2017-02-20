//
//  ChannelHeaderAndDescriptionTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 13.02.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    func configureWith(channelId: String, infoType: InfoType)
}

class ChannelHeaderAndDescriptionTableViewController: UITableViewController, ChannelInfoCellDelegate {

//MARK: Properties
    @IBOutlet weak var infoCell: ChannelInfoCell!
    
    var saveButton: UIBarButtonItem!
    
    var channel: Channel!
    var infoType: InfoType!
    var textViewHeight = CGFloat(40)
    
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
    }
}


//MARK: Interface
extension ChannelHeaderAndDescriptionTableViewController: Interface {
    func configureWith(channelId: String, infoType: InfoType) {
        self.channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId)
        self.infoType = infoType
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func setupInfoCell()
}

fileprivate protocol Action: class {
    func saveAction()

}

fileprivate protocol Navigation: class {

}

fileprivate protocol Request: class {
    func updateHeader()
    func updatePurpose()
}


//MARK: Setup
extension ChannelHeaderAndDescriptionTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupInfoCell()
    }
    
    func setupNavigationBar() {
        self.title = "Edit " + self.infoType.rawValue
        
        self.saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAction))
        self.saveButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
    
    func setupInfoCell() {
        let text = (self.infoType == InfoType.header) ? self.channel.header : self.channel.purpose
        self.infoCell.configureWith(delegate: self, text: text!, infoType: self.infoType)
    }
}


//MARK: Action
extension ChannelHeaderAndDescriptionTableViewController: Action {
    func saveAction() {
        if self.infoType == InfoType.header {
            updateHeader()
        } else {
            updatePurpose()
        }
    }
}


//MARK: Navigation
extension ChannelHeaderAndDescriptionTableViewController: Navigation {
    func returnToChannelSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension ChannelHeaderAndDescriptionTableViewController: Request {
    func updateHeader() {
        guard Api.sharedInstance.isNetworkReachable() else { self.handleErrorWith(message: Constants.ErrorMessages.message[0]); return }
        
        let header = self.infoCell.infoText
        Api.sharedInstance.updateHeader(header, channel: channel, completion: { (error) in
            guard (error == nil) else { self.handleSuccesWith(message: (error?.message!)!); return }
            
            self.saveButton.isEnabled = false
            self.handleSuccesWith(message: "Header was updated".localized)
        })
    }
    
    func updatePurpose() {
        guard Api.sharedInstance.isNetworkReachable() else { self.handleErrorWith(message: Constants.ErrorMessages.message[0]); return }
        
        let purpose = self.infoCell.infoText
        Api.sharedInstance.updatePurpose(purpose, channel: channel, completion: { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            
            self.saveButton.isEnabled = false
            self.handleSuccesWith(message: "Purpose was updated".localized)
        })
    }
}


//MARK: UITableViewDelegate
extension ChannelHeaderAndDescriptionTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.textViewHeight
    }
}


//MARK: ChannelInfoCellDelegate
extension ChannelHeaderAndDescriptionTableViewController {
    func cellWasUpdatedWith(text: String, height: CGFloat) {
        self.saveButton.isEnabled = true
        self.textViewHeight = max(20, height) + 10
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
}
