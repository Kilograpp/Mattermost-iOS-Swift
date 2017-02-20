//
//  MoreCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 18.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Inteface: class {
    func cellHeight() -> CGFloat
    func cell(resultTuple: ResultTuple) -> UITableViewCell
}


final class MoreCellBuilder {

//MARK: Properties
    fileprivate let tableView: UITableView
    
//MARK: LifeCycle
    init(tableView: UITableView) {
        self.tableView = tableView
    }
}


//MARK: Interface
extension MoreCellBuilder: Inteface {
    internal func cellFor(channel: Channel) -> UITableViewCell {
        return UITableViewCell()
    }

    func cellHeight() -> CGFloat {
        return 60
    }
    
    func cell(resultTuple: ResultTuple) -> UITableViewCell {
        let reuseIdentifier = ChannelsMoreTableViewCell.reuseIdentifier
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ChannelsMoreTableViewCell
        cell.configureWith(resultTuple: resultTuple)
        
        return cell
    }
}
