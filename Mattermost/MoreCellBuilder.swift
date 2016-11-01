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
    internal func cellFor(channel: Channel) -> UITableViewCell {
        return UITableViewCell()
    }

    func cellHeight() -> CGFloat {
        return 60
    }
    
    // CODEREVIEW: Переименовать в cell(forChannel:)
    func cellFor(resultTuple: ResultTuple) -> UITableViewCell {
        let reuseIdentifier = ChannelsMoreTableViewCell.reuseIdentifier
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ChannelsMoreTableViewCell
        cell.transform = self.tableView.transform
        cell.configureWith(resultTuple: resultTuple)
        //cell.configureWith(channel: channel)
        /*cell.checkBoxHandler = {
            resultTuple.checked = true
        }*/
        
        return cell
    }
    

}
