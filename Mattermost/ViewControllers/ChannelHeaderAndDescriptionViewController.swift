//
//  ChannelHeaderAndDescriptionViewController.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

enum InfoType{
    case header
    case purpose
    case name
}

class ChannelHeaderAndDescriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HeightForTextView  {

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
        var cell: ChannelInfoCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "channelInfoCell") as! ChannelInfoCell
        cell.infoText.text = channel.header
        cell.delgate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*if textViewHeight <= 30.0{
            (tableView.cellForRow(at: indexPath) as! ChannelInfoCell).cancelButton
        }*/
        return textViewHeight + 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func setupNavigationBar() {
        self.title = "Channel info".localized
        
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func heightOfTextView(height: CGFloat) {
        
        textViewHeight = height
        if height < CGFloat(20.0){
            textViewHeight = CGFloat(20.0)
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textViewHeight = ChannelInfoCell.heightWithObject(channel.header!)
    }
}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
