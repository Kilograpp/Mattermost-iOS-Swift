//
//  NSettingsCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 08.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Inteface: class {
    func cellFor(notifyProps: NotifyProps, indexPath: IndexPath) -> UITableViewCell
}

final class NSettingsCellBuilder {

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


//MARK: Interface
extension NSettingsCellBuilder: Inteface {
    func cellFor(notifyProps: NotifyProps, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.cellForRow(at: indexPath) as! CommonSettingsTableViewCell
        
        switch indexPath.section {
        case 2:
            cell.descriptionLabel?.text = notifyProps.allMobilePush()
        case 3:
            cell.descriptionLabel?.text = notifyProps.allSensitiveWord()
        default:
            break
        }
        
        return cell
    }
}
