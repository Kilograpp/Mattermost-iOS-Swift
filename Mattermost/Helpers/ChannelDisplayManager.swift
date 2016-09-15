//
//  ChannelDisplayManager.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 15.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

// saved for height. refactor
//private let nameChannelRowHeight :CGFloat = 70.0;
//private let infoChannelRowHeight :CGFloat = 50.0;
//private let peoplesChannelRowHeight :CGFloat = 50.0;


private enum ChannelSection : Int {
    case Title  = 0
    case Info
    case Notification
    case Members
    case Leave
    
    case Count
}
//Refactor (all as enums, see InfoRows + case Count)
private enum RowsCount : Int {
    case TitleRows = 1
    case InfoRows = 4
    case MembersMinimumRows = 2
    case MemberMaximumRows = 7
}

private enum InfoRows : Int {
    case PurposeRow = 0
    case UrlRow
    case HeaderRow
    case CommentRow
}


final class ChannelDisplayManager {
    let tableView: UITableView?
    let channel:Channel //Need for number of rows in Members Section and header!
    private let builder: ChannelInfoCellBuilder
    
    init(tableView:UITableView, channel:Channel) {
        self.tableView = tableView
        self.channel = channel
        self.builder = ChannelInfoCellBuilder(tableView:tableView,channel:channel)
    }
}

private protocol DisplayData {
    func numberOfSections() -> Int
    func numberOfRowsInSection(section:Int) -> Int
    func cellForIndexPath(indexPath:NSIndexPath) -> UITableViewCell
    func heightForRowAtIndexPath(indexPath:NSIndexPath) -> CGFloat
    func headerForMembersSection() -> UIView // UIView ?
}

//MARK: - DisplayData
extension ChannelDisplayManager: DisplayData {
    func numberOfSections() -> Int {
        return ChannelSection.Count.rawValue
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        switch (section) {
            case ChannelSection.Info.rawValue:
            return RowsCount.InfoRows.rawValue
        case ChannelSection.Title.rawValue:
            return RowsCount.TitleRows.rawValue
        case ChannelSection.Members.rawValue:
            return min((channel.members.count) + RowsCount.MembersMinimumRows.rawValue, RowsCount.MemberMaximumRows.rawValue)
        case ChannelSection.Notification.rawValue:
            return RowsCount.TitleRows.rawValue
        case ChannelSection.Leave.rawValue:
            return RowsCount.TitleRows.rawValue
            
        default:
            return 1
        }
    }
    func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        // refactor
        return 50
    }
    func cellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func headerForMembersSection() -> UIView {
        // todo uiView for count of members
        return UIView()
    }
}