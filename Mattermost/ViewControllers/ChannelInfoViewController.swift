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
    var channelName : String?
    
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
    
    let defaultTableViewCellReuseIdentifier = "defaultTableViewCellReuseIdentifier"
    let userCellReuseIdentifier = "userCellReuseIdentifier"
    let titleValueCellReuseIdentifier = "titleValueCellReuseIdentifier"
    let showHeaderIdentifier = "showHeader"
    let showPurposeIdentifier = "showPurpose"
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitle()
        setupTitleArray()
        setupDetailArray()
        setupUserArray()
        setupNavigationBar()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.showHeaderIdentifier {
            let vc = segue.destinationViewController as! ChannelHeaderViewController
            vc.channel = self.channel
        }
        if segue.identifier == self.showPurposeIdentifier {
            let vc = segue.destinationViewController as! ChannelPurposeViewController
            vc.channel = self.channel
        }
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
        self.detailArray = []
        if self.channel?.header != nil {
            self.detailArray?.append((self.channel?.header)!)
        } else {
            self.detailArray?.append("")
        }
        if self.channel?.purpose != nil {
            self.detailArray?.append((self.channel?.purpose)!)
        } else {
            self.detailArray?.append("")
        }
        self.detailArray?.append("kilograpp")
        if self.channel?.identifier != nil {
            self.detailArray?.append((self.channel?.identifier)!)
        } else {
            self.detailArray?.append("")
        }

    }
    
    func setupUserArray() {
        self.channelName = self.channel?.displayName
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
            cell?.textLabel!.text = self.channelName
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
            if self.detailArray != nil {
                cell?.detailTextLabel?.text = self.detailArray![indexPath.row]
            }
            
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
            
            if self.users != nil {
                cell?.textLabel!.text = self.users![indexPath.row - 1].username
                ImageDownloader.downloadFeedAvatarForUser(self.users![indexPath.row - 1]) { [weak cell] (image, error) in
                    cell?.imageView?.image = image
                }
            } else {
            cell?.textLabel!.text = "user name"
            }
            cell?.textLabel?.textColor = ColorBucket.blackColor
            
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case Section.sectionTitle.hashValue:
            break
        case Section.sectionInformation.hashValue:
            switch indexPath.row {
            case 0:
                navigateToHeader()
                break
            case 1:
                navigateToPurpose()
                break
            default:
                break
            }
        case Section.sectionNotification.hashValue:
            break
        case Section.sectionMembers.hashValue:
            break
        case Section.sectionLeave.hashValue:
            break
        default:
            break
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        return CGFloat(self.tableViewTitleSectionHeaderHeight)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == Section.sectionTitle.hashValue {
            return CGFloat(self.tableViewTitleCellHeight)
        }
        return CGFloat(self.tableViewCellHeight)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == Section.sectionMembers.hashValue && self.channel?.members.count != 0{
            let header = UITableViewHeaderFooterView.init()
            header.textLabel!.font = FontBucket.postDateFont
            let str = NSString.init(format: "%d MEMBERS", (self.channel?.members.count)!)
            header.textLabel!.text = str as String
            header.textLabel?.textColor = ColorBucket.grayColor
            return header
        }
        return UIView.init()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == Section.sectionTitle.hashValue {
            return CGFloat(self.tableViewOtherSectionHeaderHeight)
        }
        if section == Section.sectionNotification.hashValue {
            return CGFloat(self.tableViewMembersSectionHeaderHeight - self.tableViewOtherSectionHeaderHeight)
        }
        return CGFloat(self.tableViewOtherSectionHeaderHeight)
    }
    
    }

private protocol Private {
    func navigateToHeader()
    func navigateToPurpose()
}

extension ChannelInfoViewController : Private {
    func navigateToHeader() {
        performSegueWithIdentifier(self.showHeaderIdentifier, sender: nil)
    }
    func navigateToPurpose() {
        performSegueWithIdentifier(self.showPurposeIdentifier, sender: nil)
    }
}
