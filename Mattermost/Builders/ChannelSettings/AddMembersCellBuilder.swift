//
//  AddMembersCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 15.02.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    func cellHeight() -> CGFloat
    func cellFor(user: User, indexPath: IndexPath) -> UITableViewCell
    func sectionHeaderHeight() -> CGFloat
}


final class AddMembersCellBuilder {

//MARK: Properties
    fileprivate let tableView: UITableView
    
//MARK: LifeCycle
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    private init?() {
        return nil
    }
}

//MARK: TeamCellBuilderInteface
extension AddMembersCellBuilder: Interface {
    func cellHeight() -> CGFloat {
        return 50
    }
    
    func cellFor(user: User, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MemberInAdditingCell.reuseIdentifier) as! MemberInAdditingCell
        cell.configureWith(user: user)
        
        return cell
    }
    
    func sectionHeaderHeight() -> CGFloat {
        return 1
    }
}
