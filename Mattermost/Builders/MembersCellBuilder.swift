//
//  MembersCellBuilder.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 15.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class MembersCellBuilder {
    private let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    private init?(){
        return nil
    }
}


private protocol Interface: class {
    func cellForMember(member: User, strategy:MembersStrategy) -> UITableViewCell
}
//MARK: - Interface
extension MembersCellBuilder: Interface {
    func cellForMember(member: User, strategy:MembersStrategy) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(MembersTableViewCell.reuseIdentifier) as! MembersTableViewCell
        cell.transform = self.tableView.transform
        cell.configureWithMember(member,strategy: strategy)
        return cell
    }
}