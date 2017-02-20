//
//  AllMembersCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 16.02.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    func cellHeight() -> CGFloat
    func cellFor(user: User, indexPath: IndexPath) -> UITableViewCell
    func sectionHeaderHeight() -> CGFloat
}

final class AllMembersCellBuilder {
    
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
extension AllMembersCellBuilder: Interface {
    func cellHeight() -> CGFloat {
        return 50
    }
    
    func cellFor(user: User, indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: MemberChannelSettingsCell.reuseIdentifier) as! MemberChannelSettingsCell
        cell.configureWith(user: user)
        
        return cell
    }
    
    func sectionHeaderHeight() -> CGFloat {
        return 1
    }
}
