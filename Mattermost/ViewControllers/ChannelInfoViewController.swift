//
//  ChannelInfoViewController.swift
//  Mattermost
//
//  Created by Tatiana on 07/09/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

enum Section : NSInteger {
    case sectionTitle = 0
    case sectionInformation
    case sectionNotification
    case sectionMembers
    case sectionLeave
    case sectionCount
}


final class ChannelInfoViewController : UIViewController {
    
    var channel :Channel?
    var titleArray : Array<String>?
    var detailArray : Array<String>?
    var users : Array<User>?
    
    let sectionCount = 2
    
    let tableViewTitleSectionHeaderHeight = 0.1
    let tableViewMembersSectionHeaderHeight = 40
    let tableViewOtherSectionHeaderHeight = 15
    let tableViewTitleCellHeight = 90
    let tableViewCellHeight = 50
    
    let sectionTitleNumberOfRows = 1
    let sectionInformationNumberOfRows = 4
    let sectionNotificationNumberOfRows = 1
    let sectionMembersMinNumberOfRows = 2
    let sectionLeaveNumberOfRows = 1
    
    let maxVisibleNumberOfMembersRows = 5
    
    let defaultTableViewCellReuseIdentifier = "defaultTableViewCellReuseIdentifier";
    let userCellReuseIdentifier = "userCellReuseIdentifier";
    let titleValueCellReuseIdentifier = "titleValueCellReuseIdentifier";
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitle()
        setupTitleArray()
        setupDetailArray()
        setupUserArray()
        setupNavigationBar()
        
    }
}

private protocol Setup {
    func setupTitle()
    func setupTitleArray()
    func setupDetailArray()
    func setupUserArray()
    func setupNavigationBar()
}

extension ChannelInfoViewController : Setup {
    func setupTitle() {
        self.title = "Channel Info"
    }
    
    func setupTitleArray() {
        self.titleArray = ["Header", "Purpose", "URL", "ID"]
    }
    
    func setupDetailArray() {
        //self.detailArray = [self.channel?.header, self.channel?.purpose, "kilograpp", self.channel?.identifier]
    }
    
    func setupUserArray() {
        Api.sharedInstance.loadExtraInfoForChannel(self.channel!) { (error) in
            self.users = self.channel?.members.reverse()
            self.tableView.reloadData()
        }
    }
    
    func setupNavigationBar() {
        
    }
}

extension ChannelInfoViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.sectionCount.hashValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.sectionTitle.hashValue:
            return self.sectionTitleNumberOfRows
        case Section.sectionInformation.hashValue:
            return self.sectionInformationNumberOfRows
        case Section.sectionNotification.hashValue:
            return self.sectionNotificationNumberOfRows
        case Section.sectionMembers.hashValue:
            //FIXME add number of members  in channel
            return self.sectionMembersMinNumberOfRows + min((self.channel?.members.count)!, self.maxVisibleNumberOfMembersRows)
        case Section.sectionLeave.hashValue:
            return self.sectionLeaveNumberOfRows
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.sectionTitle.hashValue:
            var cell = tableView.dequeueReusableCellWithIdentifier(self.defaultTableViewCellReuseIdentifier)
            if cell == nil {
                cell = UITableViewCell.init(style: .Default, reuseIdentifier: self.defaultTableViewCellReuseIdentifier)
            }
            cell?.textLabel!.text = self.channel!.displayName
            cell?.textLabel?.textColor = ColorBucket.blackColor
            cell?.imageView!.image = UIImage.init(named: "about_kg_icon")
            cell?.textLabel?.textAlignment = .Left
            return cell!
        case Section.sectionInformation.hashValue:
            var cell = tableView.dequeueReusableCellWithIdentifier(self.titleValueCellReuseIdentifier)
            if cell == nil {
                cell = UITableViewCell.init(style: .Value1, reuseIdentifier: self.titleValueCellReuseIdentifier)
            }
            cell?.textLabel!.text = self.titleArray![indexPath.row]
            cell?.textLabel?.textColor = ColorBucket.blackColor
            //cell.detail
            
            cell?.accessoryType = .DisclosureIndicator
            return cell!
        case Section.sectionNotification.hashValue:
            var cell = tableView.dequeueReusableCellWithIdentifier(self.titleValueCellReuseIdentifier)
            if cell == nil {
                cell = UITableViewCell.init(style: .Value1, reuseIdentifier: self.titleValueCellReuseIdentifier)
            }
            cell?.textLabel!.text = "Notification"
            cell?.textLabel?.textColor = ColorBucket.blackColor
            cell?.imageView!.image = UIImage.init(named: "profile_notification_icon")
            cell?.accessoryType = .DisclosureIndicator
            return cell!
        case Section.sectionMembers.hashValue:
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier(self.defaultTableViewCellReuseIdentifier)
                if cell == nil {
                    cell = UITableViewCell.init(style: .Default, reuseIdentifier: self.defaultTableViewCellReuseIdentifier)
                }
                cell?.textLabel?.text = "Add Members"
                cell?.textLabel?.textColor = ColorBucket.blueColor
                return cell!
            }
            
            if indexPath.row == (self.sectionMembersMinNumberOfRows + min((self.channel?.members.count)!, self.maxVisibleNumberOfMembersRows) - 1) {
                var cell = tableView.dequeueReusableCellWithIdentifier(self.defaultTableViewCellReuseIdentifier)
                if cell == nil {
                    cell = UITableViewCell.init(style: .Default, reuseIdentifier: self.defaultTableViewCellReuseIdentifier)
                }
                cell?.textLabel!.text = "See all members"
                cell?.textLabel?.textColor = ColorBucket.blueColor
                cell?.imageView!.image = nil
                cell?.textLabel?.textAlignment = .Center
                return cell!
            }
            
            var cell = tableView.dequeueReusableCellWithIdentifier(self.userCellReuseIdentifier)
            if cell == nil {
                cell = UITableViewCell.init(style: .Value1, reuseIdentifier: self.userCellReuseIdentifier)
            }

            //let user = self.users![indexPath.row - 1]
            if self.users != nil {
                cell?.textLabel!.text = self.users![indexPath.row - 1].username
                cell?.imageView?.setImageWithURL(self.users![indexPath.row - 1].avatarURL())
            } else {
            cell?.textLabel!.text = "user name"
            }
            cell?.textLabel?.textColor = ColorBucket.blackColor
            //cell?.imageView.image = UIImage.init(named: <#T##String#>)
            
            
            
            
            return cell!
        case Section.sectionLeave.hashValue:
            var cell = tableView.dequeueReusableCellWithIdentifier(self.defaultTableViewCellReuseIdentifier)
            if cell == nil {
                cell = UITableViewCell.init(style: .Default, reuseIdentifier: self.defaultTableViewCellReuseIdentifier)
            }
            cell?.textLabel!.text = "Leave Channel"
            cell?.textLabel?.textColor = ColorBucket.blueColor
            cell?.imageView!.image = nil
            cell?.textLabel?.textAlignment = .Center
            
            return cell!
        default:
            break
        }
        return UITableViewCell.init()
    }
}

extension ChannelInfoViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == Section.sectionTitle.hashValue {
            return CGFloat(self.tableViewTitleSectionHeaderHeight)
        }
        if section == Section.sectionMembers.hashValue {
            return CGFloat(self.tableViewMembersSectionHeaderHeight)
        }
        return CGFloat(self.tableViewOtherSectionHeaderHeight)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == Section.sectionTitle.hashValue {
            return CGFloat(self.tableViewTitleCellHeight)
        }
        return CGFloat(self.tableViewCellHeight)
    }
    
}

private protocol Private {
    func configareUserName(user: User) -> String
}

//extension ChannelInfoViewController : Private {
//    func configareUserName(user: User) -> String {
//        if user.lastName!.characters.count == 0 {
//            return user.firstName
//        }
//    }
//}