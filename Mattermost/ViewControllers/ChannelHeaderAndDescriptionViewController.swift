//
//  ChannelHeaderAndDescriptionViewController.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

enum InfoType: String{
    case header = "header"
    case purpose = "purpose"
}

class ChannelHeaderAndDescriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellUpdated  {
    
    @IBOutlet weak var tableView: UITableView!
    var channel: Channel!
    var textViewHeight = CGFloat(40.0)
    var type: InfoType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setupNavigationBar()
        tableView.estimatedRowHeight = 70.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "ChannelInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "channelInfoCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return setupCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return textViewHeight + 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func setupNavigationBar() {
        self.title = "Edit " + type.rawValue
        
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonAction))
        self.navigationItem.rightBarButtonItem = saveButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func saveButtonAction(){
        navigationItem.rightBarButtonItem?.isEnabled = false
        switch self.type!{
        case .header:
            Api.sharedInstance.updateHeader((tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ChannelInfoCell).infoText.text, channel: channel, completion: { (error) in
                guard (error == nil) else { return }
                AlertManager.sharedManager.showSuccesWithMessage(message: "Header was updated".localized)
                Api.sharedInstance.loadChannels(with: { (error) in
                    guard (error == nil) else { return }
                    Api.sharedInstance.loadExtraInfoForChannel(self.channel.identifier!, completion: { (error) in
                        guard (error == nil) else { return }
                    })
                })
            })
        case .purpose:
            Api.sharedInstance.updatePurpose((tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ChannelInfoCell).infoText.text, channel: channel, completion: { (error) in
                guard (error == nil) else { return }
                AlertManager.sharedManager.showSuccesWithMessage(message: "Purpose was updated".localized)
                Api.sharedInstance.loadChannels(with: { (error) in
                    guard (error == nil) else { return }
                    Api.sharedInstance.loadExtraInfoForChannel(self.channel.identifier!, completion: { (error) in
                        guard (error == nil) else { return }
                    })
                })
            })
        }
    }
    
    func cellUpdated(text: String) {
        
        textViewHeight = ChannelInfoCell.heightWithObject(text)
        if ChannelInfoCell.heightWithObject(text) < CGFloat(20.0){
            textViewHeight = CGFloat(20.0)
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func setupCell() -> UITableViewCell{
        var cell: ChannelInfoCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "channelInfoCell") as! ChannelInfoCell
        cell.delgate = self
        switch self.type!{
        case .header:
            cell.infoText.text = channel.header
        case .purpose:
            if let purpose = channel.purpose{
                cell.infoText.text = purpose
            } else {
                cell.infoText.text = ""
            }
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch self.type!{
        case .header:
            textViewHeight = ChannelInfoCell.heightWithObject(channel.header!)
        case .purpose:
            if let purpose = channel.purpose{
                textViewHeight = ChannelInfoCell.heightWithObject(purpose)
            } else {
                textViewHeight = ChannelInfoCell.heightWithObject("")
            }
        }
    }
}
