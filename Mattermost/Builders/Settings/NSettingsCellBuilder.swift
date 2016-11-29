//
//  NSettingsCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 08.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

fileprivate let sectionTitles: Array = [ "DESCTOP NOTIFICATIONS", "EMAIL NOTIFICATIONS", "MOBILE PUSH NOTIFICATIONS", "WORDS THAT TRIGGER MENTIONES", "REPLY NOTIFICATIONS" ]

private protocol Inteface: class {
    func numberOfSections() -> Int
    func numberOfRows() -> Int
    func cellFor(notifyProps: NotifyProps, indexPath: IndexPath) -> UITableViewCell
    func title(section: Int) -> String
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
    func numberOfSections() -> Int {
        return sectionTitles.count
    }
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func cellFor(notifyProps: NotifyProps, indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommonSettingsTableViewCell", for: indexPath) as! CommonSettingsTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.descriptionLabel?.text = notifyProps.completeDesktop()
        case 1:
            cell.descriptionLabel?.text = notifyProps.completeEmail()
        case 2:
            cell.descriptionLabel?.text = notifyProps.completeMobilePush()
        case 3:
            cell.descriptionLabel?.text = notifyProps.completeTriggerWords()
        case 4:
            cell.descriptionLabel?.text = notifyProps.completeReply()
            cell.descriptionLabel?.textColor = UIColor.lightGray
        default:
            break
        }
        
        return cell
    }
    
    func title(section: Int) -> String {
        return sectionTitles[section]
    }
}
