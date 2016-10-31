//
//  MoreCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 18.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

// CODEREVIEW: fileprivate
// CODEREVIEW: MoreCellBuilder избыточен, достаточно Interface
private protocol MoreCellBuilderInteface: class {
    func cellHeight() -> CGFloat
    // CODEREVIEW: cell(forChannel)
    func cellFor(channel: Channel) -> UITableViewCell
}

final class MoreCellBuilder {
    
    fileprivate let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    // CODEREVIEW: Точно ли тут нужен пустой init?
    private init?() {
        return nil
    }
}

extension MoreCellBuilder: MoreCellBuilderInteface {
    func cellHeight() -> CGFloat {
        return 60
    }
    
    // CODEREVIEW: Переименовать в cell(forChannel:)
    func cellFor(channel: Channel) -> UITableViewCell {
        let reuseIdentifier = ChannelsMoreTableViewCell.reuseIdentifier
        // CODEREVIEW: Заменить на генерик, чтобы не надо было использовать reuseIdentifier
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ChannelsMoreTableViewCell
        cell.transform = self.tableView.transform
        cell.configureWith(channel: channel)
        cell.checkBoxHandler = {
            // CODEREVIEW: Слишком глубокая вложенность. Действие надо определить предварительно, а потом уже засунуть в handler
            try! RealmUtils.realmForCurrentThread().write({
                let oldState = channel.currentUserInChannel
                channel.currentUserInChannel = !oldState
            })
        }
        
        return cell
    }
}
