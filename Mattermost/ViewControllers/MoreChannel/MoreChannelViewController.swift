//
//  MoreChannelViewController.swift
//  Mattermost
//
//  Created by Mariya on 23.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class MoreChannelViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
    }
    
    
    func setupNavigationBar() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = ColorBucket.sideMenuBackgroundColor
        navigationBarAppearance.barTintColor = ColorBucket.whiteColor
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: ColorBucket.whiteColor]
        self.navigationItem.title = "More Channel"
    }
    
    func setupTableView () {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
    }
    
    
    func configureCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath) {

        //поставить конфигурацию
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.backgroundView?.tintColor = ColorBucket.whiteColor
        cell.textLabel?.tintColor = ColorBucket.blackColor
        configureCellAtIndexPath(cell, indexPath: indexPath)
        return cell
    }
 
}

