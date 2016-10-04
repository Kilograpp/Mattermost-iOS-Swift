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
        
        let user = DataManager.sharedInstance.currentUser
        self.usernameLabel.text = user!.displayName
        self.avatarImageView?.sd_setImageWithURL(user!.avatarURL(), placeholderImage: nil, completed: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapAction))
        self.headerView.addGestureRecognizer(tapGestureRecognizer)
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


//MARK: - Private

extension RightMenuViewController {
    private func toggleRightSideMenu() {
        self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
    }
}


//MARK: - Actions

extension RightMenuViewController {
    func headerTapAction() {
        toggleRightSideMenu()
        proceedToProfile()
    }
}


//MARK: - UITableViewDelegate

extension RightMenuViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case RightMenuRows.Settings.rawValue:
            toggleRightSideMenu()
            proceedToSettings()
        case RightMenuRows.SwitchTeam.rawValue:
            proceedToTeams()
        case RightMenuRows.About.rawValue:
            toggleRightSideMenu()
            proceedToAbout()
        case RightMenuRows.Logout.rawValue:
            logOut()
            
        default:
            return
        }
    }
}


//MARK: - UITableViewDataSource

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

//MARK: - Navigation
extension RightMenuViewController {
    func proceedToTeams() {
        let teamViewController = UIStoryboard(name:  "Login",
            bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("TeamViewController")
        let loginNavigationController = LoginNavigationController(rootViewController: teamViewController)
        self.presentViewController(loginNavigationController, animated: true, completion: nil)
        self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
    }
    
    func proceedToProfile() {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateInitialViewController()
        let navigation = self.menuContainerViewController.centerViewController
        navigation!.pushViewController(profile!, animated:true)
    }
    
    func proceedToAbout() {
        // UNCOMMENT THIS
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let about = storyboard.instantiateViewControllerWithIdentifier(String(AboutViewController))
//        let navigation = self.menuContainerViewController.centerViewController
//        navigation!.pushViewController(about, animated:true)
        // DELETE THIS
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let about = storyboard.instantiateViewControllerWithIdentifier(String("MembersViewController"))
        let navigation = self.menuContainerViewController.centerViewController
        navigation!.pushViewController(about, animated:true)
    }
    
    func proceedToSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let settings = storyboard.instantiateInitialViewController()
        let navigation = self.menuContainerViewController.centerViewController
        navigation!.pushViewController(settings!, animated:true)
    }
    func logOut() {
        UserStatusManager.sharedInstance.logout()
    }
}