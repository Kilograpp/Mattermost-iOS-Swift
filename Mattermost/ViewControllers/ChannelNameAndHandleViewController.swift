//
//  ChannelHeaderAndDescriptionViewController.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class ChannelNameAndHandleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
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
        
        let nib = UINib(nibName: "ChannelNameAndHandleCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "channelNameAndHandleCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Name"
        case 1:
            return "Handle"
        default:
            return nil
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ChannelNameAndHandleCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "channelNameAndHandleCell") as! ChannelNameAndHandleCell
        switch indexPath.section{
        case 0:
            cell.textField.text = channel.displayName!
        case 1:
            cell.textField.text = channel.name!
            if channel.name! == "town-square"{
                cell.textField.isEnabled = false
                cell.cancelButton.isHidden = true
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return textViewHeight + 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func setupNavigationBar() {
        self.title = "Channel info".localized
        
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonAction))
        self.navigationItem.rightBarButtonItem = saveButton
        //navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func saveButtonAction(){
        let newDisplayName = (tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ChannelNameAndHandleCell).textField.text
        let newName = (tableView.cellForRow(at: IndexPath.init(row: 0, section: 1)) as! ChannelNameAndHandleCell).textField.text
        
        Api.sharedInstance.update(newDisplayName: newDisplayName!, newName: newName!, channel: channel!, completion: { (error) in
            guard (error == nil) else { return }
            AlertManager.sharedManager.showSuccesWithMessage(message: "Channel was updated".localized)
        })
    }
}
