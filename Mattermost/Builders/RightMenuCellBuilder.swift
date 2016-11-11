//
//  RightMenuCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 20.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol RightMenuCellBuilderInteface: class {
    func cellHeight() -> CGFloat
    func cellFor(indexPath: IndexPath) -> UITableViewCell
}

final class RightMenuCellBuilder {
    
    fileprivate let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    private init?() {
        return nil
    }
}

extension RightMenuCellBuilder: RightMenuCellBuilderInteface {
    func cellHeight() -> CGFloat {
        return 60
    }
    
    func cellFor(indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier:"Cell")
        }
        
        self.configureCellAtIndexPath(cell!, indexPath: indexPath)
        cell?.backgroundColor = ColorBucket.sideMenuBackgroundColor
        cell!.preservesSuperviewLayoutMargins = false;
        cell!.separatorInset = UIEdgeInsets.zero;
        cell!.layoutMargins = UIEdgeInsets.zero;
        cell?.selectionStyle = .default
        
        cell?.selectedBackgroundView = UIView(frame: cell!.bounds)
        cell?.selectedBackgroundView?.backgroundColor = ColorBucket.sideMenuCellHighlightedColor
        
       // cell?.textLabel?.textColor = (indexPath.row == Constants.RightMenuRows.Logout) ? ColorBucket.whiteColor : ColorBucket.rightMenuTextColor
        cell?.textLabel?.font = FontBucket.rightMenuFont
        
        return cell!
    }
    
    fileprivate func configureCellAtIndexPath(_ cell: UITableViewCell, indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case Constants.RightMenuRows.SwitchTeam:
            cell.textLabel?.text = "Switch team"
            cell.textLabel?.textColor = ColorBucket.whiteColor
            cell.imageView?.image = UIImage(named: "menu_switch_icon")
            
        case Constants.RightMenuRows.Files:
            cell.textLabel?.text = "Files"
            cell.textLabel?.textColor = ColorBucket.rightMenuTextColor
            cell.imageView?.image = UIImage(named: "menu_files_icon")
            
        case Constants.RightMenuRows.Settings:
            cell.textLabel?.text = "Settings"
            cell.textLabel?.textColor = ColorBucket.whiteColor
            cell.imageView?.image = UIImage(named: "menu_settings_icon")
        
        case Constants.RightMenuRows.InviteNewMembers:
            cell.textLabel?.text = "Invite new members"
            cell.textLabel?.textColor = ColorBucket.whiteColor
            cell.imageView?.image = UIImage(named: "menu_invite_icon")
            
        case Constants.RightMenuRows.Help:
            cell.textLabel?.text = "Help"
            cell.textLabel?.textColor = ColorBucket.rightMenuTextColor
            cell.imageView?.image = UIImage(named: "menu_help_icon")
            
        case Constants.RightMenuRows.Report:
            cell.textLabel?.text = "Report a Problem"
            cell.textLabel?.textColor = ColorBucket.rightMenuTextColor
            cell.imageView?.image = UIImage(named: "menu_report_icon")
            
        case Constants.RightMenuRows.About:
            cell.textLabel?.text = "About Mattermost"
            cell.textLabel?.textColor = ColorBucket.whiteColor
            cell.imageView?.image = UIImage(named: "menu_question_icon")
            
        case Constants.RightMenuRows.Logout:
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = ColorBucket.whiteColor
            cell.imageView?.image = UIImage(named: "menu_logout_icon")
            
        default:
            return
        }
        
    }
}
