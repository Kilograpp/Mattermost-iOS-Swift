//
//  RightMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 15.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

@objc private enum RightMenuRows : Int {
    case SwitchTeam
    case Settings = 1
    case InviteNewMembers = 2
    case About = 3
    case Logout = 4
}

class RightMenuViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//FIXME: вызов методов не должен быть через self
        self.configureTableView()
        self.configureHeaderVIew()
    }
}

private protocol PrivateConfig {
    func configureTableView()
    func configureHeaderVIew()
    func configureCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath)
}

extension RightMenuViewController : PrivateConfig {
    private func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
    }
    
    private func configureHeaderVIew() {
        self.headerView.backgroundColor = ColorBucket.sideMenuHeaderBackgroundColor
        self.usernameLabel.font = FontBucket.rightMenuFont
        self.usernameLabel.textColor = ColorBucket.whiteColor
        
        self.usernameLabel.text = DataManager.sharedInstance.currentUser?.displayName
    }
    
    func configureCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath) {
        switch indexPath.row {
        case RightMenuRows.SwitchTeam.rawValue:
            cell.textLabel?.text = "Switch team"
            cell.imageView?.image = UIImage(named: "menu_switch_icon")
            
        case RightMenuRows.Settings.rawValue:
            cell.textLabel?.text = "Settings"
            cell.imageView?.image = UIImage(named: "menu_settings_icon")
            
        case RightMenuRows.InviteNewMembers.rawValue:
            cell.textLabel?.text = "Invite new members"
            cell.imageView?.image = UIImage(named: "menu_invite_icon")
            
        case RightMenuRows.About.rawValue:
            cell.textLabel?.text = "About Mattermost"
            cell.imageView?.image = UIImage(named: "menu_question_icon")
            
        case RightMenuRows.Logout.rawValue:
            cell.textLabel?.text = "Logout"
            cell.imageView?.image = UIImage(named: "menu_logout_icon")
            
        default:
            return
        }

    }
}

extension RightMenuViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
            case RightMenuRows.SwitchTeam.rawValue:
                navigateToTeams()
            
            default:
                break
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

//MARK: - Navigation
extension RightMenuViewController {
    func navigateToTeams() {
        let teamViewController = UIStoryboard(name:  "Login",
            bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("TeamViewController")
        let loginNavigationController = LoginNavigationController(rootViewController: teamViewController)
        self.presentViewController(loginNavigationController, animated: true, completion: nil)
        self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
    }
}

extension RightMenuViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier:"Cell")
        }
        
        self.configureCellAtIndexPath(cell!, indexPath: indexPath)
        cell?.backgroundColor = ColorBucket.sideMenuBackgroundColor
        cell!.preservesSuperviewLayoutMargins = false;
        cell!.separatorInset = UIEdgeInsetsZero;
        cell!.layoutMargins = UIEdgeInsetsZero;
        cell?.selectionStyle = .Default
        
        cell?.selectedBackgroundView = UIView(frame: cell!.bounds)
        cell?.selectedBackgroundView?.backgroundColor = ColorBucket.sideMenuCellHighlightedColor
        
        cell?.textLabel?.textColor = indexPath.row == RightMenuRows.Logout.rawValue ? ColorBucket.whiteColor : ColorBucket.rightMenuTextColor
        cell?.textLabel?.font = FontBucket.rightMenuFont
        
        return cell!
    }
}