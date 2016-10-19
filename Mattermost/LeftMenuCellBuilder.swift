//
//  LeftMenuCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 19.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol LeftMenuCellBuilderInteface: class {
    func cellHeight() -> CGFloat
    func cellFor(channel: Channel) -> UITableViewCell
}

final class LeftMenuCellBuilder {
    
    fileprivate let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    private init?() {
        return nil
    }
}

extension LeftMenuCellBuilder: LeftMenuCellBuilderInteface {
    func cellHeight() -> CGFloat {
        return 60
    }
    
    func cellFor(channel: Channel) -> UITableViewCell {
        let reuseIdentifier = ChannelsMoreTableViewCell.reuseIdentifier
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ChannelsMoreTableViewCell
        cell.transform = self.tableView.transform
        cell.configureWith(channel: channel)
        cell.checkBoxHandler = {
            try! RealmUtils.realmForCurrentThread().write({
                let oldState = channel.currentUserInChannel
                channel.currentUserInChannel = !oldState
            })
        }
        
        return cell
    }
}
