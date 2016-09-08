//
//  ChannelInfoViewController.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 08.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftFetchedResultsController

private let nameChannelRowHeight :CGFloat = 70.0;
private let infoChannelRowHeight :CGFloat = 50.0;
private let peoplesChannelRowHeight :CGFloat = 50.0;

final class ChannelInfoViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    
    private enum ChannelSection : Int {
        case nameSection  = 0
        case infoSection
        case peoplesSection
        
        case sectionsCount
    }
    
    private enum ChannelRows : Int {
        case nameSectionRows = 1
        case infoSectionRows = 4
        case peoplesSectionMinRows  = 2
        
        case rowsCount
    }
    
    private enum InfoRows : Int {
        case purposeRow = 0
        case urlRow
        case headerRow
        case commentRow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupTitle()
    }
    
    private func setupTableView() -> Void {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func setupTitle() -> Void {
        title = "Channel info"
    }
    
    func configureCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch indexPath.section {
        case ChannelSection.nameSection.rawValue:
            cell.textLabel?.text = "[channel name]"
            cell.imageView?.image = UIImage(named: "menu_switch_icon")
            
        case ChannelSection.infoSection.rawValue:
            switch indexPath.row {
            case InfoRows.headerRow.rawValue:
                cell.textLabel?.text = "[channel header]"
            case InfoRows.commentRow.rawValue:
                cell.textLabel?.text = "[channel comment]"
            case InfoRows.purposeRow.rawValue:
                cell.textLabel?.text = "[channel purpose]"
            case InfoRows.urlRow.rawValue:
                cell.textLabel?.text = "[channel url]"
            default:
                break
            }
        case ChannelSection.peoplesSection.rawValue:
            switch indexPath.row {
            case InfoRows.headerRow.rawValue:
                cell.textLabel?.text = "[channel header]"
                cell.imageView?.image = UIImage(named: "menu_switch_icon")
            case InfoRows.commentRow.rawValue:
                cell.textLabel?.text = "[channel comment]"
                cell.imageView?.image = UIImage(named: "menu_switch_icon")
            case InfoRows.purposeRow.rawValue:
                cell.textLabel?.text = "[channel purpose]"
                cell.imageView?.image = UIImage(named: "menu_switch_icon")
            case InfoRows.urlRow.rawValue:
                cell.textLabel?.text = "[channel url]"
                cell.imageView?.image = UIImage(named: "menu_switch_icon")
            default:
                break
            }
            
        default:
            return
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = ChannelSection.init(rawValue: section) {
            switch (section) {
            case .nameSection :
                return ChannelRows.nameSectionRows.rawValue
            case .infoSection :
                return ChannelRows.infoSectionRows.rawValue
            case .peoplesSection :
                return min(ChannelRows.peoplesSectionMinRows.rawValue /*+ peoples.count*/, 5)
                
            default :
                break
            }
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ChannelSection.sectionsCount.rawValue
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = ChannelSection.init(rawValue: indexPath.section)!
        switch (section) {
        case .nameSection :
            return nameChannelRowHeight
        case .infoSection :
            return infoChannelRowHeight
        case .peoplesSection :
            return peoplesChannelRowHeight
            
        default :
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        configureCellAtIndexPath(cell,indexPath: indexPath)
        return cell
    }
    
}
