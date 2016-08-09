//
//  ProfileTableViewController.swift
//  Mattermost
//
//  Created by Tatiana on 09/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

private protocol Lifecycle {
    func viewDidLoad()
}

private protocol UITableViewDataSource {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
}

private protocol Setup {
    func setup()
}

private protocol ImagePickerControllerDelegate {
    //func setup()
}

final class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTitleLabel: UILabel!
    
    var userId: String?
    private var user: User?
    private var isCurrentUser: Bool?
    let kCellReuseIdentifier = "userCellReuseIdentifier"
    
    func changeProfilePhoto() {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        let openCameraAction = UIAlertAction.init(title: "Take photo", style: .Default) { (action) in
            self.presentPickerControllerWithType(.Camera)
        }
        let openGalleryAction = UIAlertAction.init(title: "Take from library", style: .Default) { (action) in
            self.presentPickerControllerWithType(.PhotoLibrary)
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(openCameraAction)
        alertController.addAction(openGalleryAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentPickerControllerWithType(type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController.init()
        pickerController.sourceType = type
        pickerController.delegate = self
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            switch indexPath.row {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            case 3:
                self.changeProfilePhoto()
                break
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            default:
                break
            }
        }

    }
}


//MARK: - Lifecycle

extension ProfileTableViewController:Lifecycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
}


//MARK: - Setup

extension ProfileTableViewController:Setup {
    func setup() {
        self.user = try! Realm().objects(User).filter("identifier = %@", self.userId!).first!
        if self.userId == Preferences.sharedInstance.currentUserId {
            self.isCurrentUser = true
        }
        self.nameTitleLabel.font = FontBucket.titleProfileFont
        self.nameTitleLabel.textColor = ColorBucket.blackColor
        self.avatarImageView.layer.cornerRadius = 65
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.backgroundColor = ColorBucket.whiteColor
        self.nameTitleLabel.text = self.user?.username
        self.avatarImageView.setImageWithURL(self.user?.avatarURL())
    }
}

extension ProfileTableViewController: UITableViewDataSource {
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.min
        } else {
            return 30
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.isCurrentUser != nil {
                return 4
            } else {
                return 3
            }
        } else {
            if self.isCurrentUser != nil {
                return 3
            } else {
                return 1
            }
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell.init(style: .Value1, reuseIdentifier: kCellReuseIdentifier)
        }
        if (self.isCurrentUser != nil) {
            cell?.accessoryType = .DisclosureIndicator
        } else {
            cell?.selectionStyle = .None
        }
        if (indexPath.section == 0) {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = "Name"
                cell?.detailTextLabel?.text = self.user?.firstName
                cell?.imageView?.image = UIImage.init(named: "profile_name_icon")
                break
            case 1:
                cell?.textLabel?.text = "Username"
                cell?.detailTextLabel?.text = self.user?.username
                cell?.imageView?.image = UIImage.init(named: "profile_usename_icon")
                break
            case 2:
                cell?.textLabel?.text = "Nickname"
                cell?.detailTextLabel?.text = self.user?.nickname
                cell?.imageView?.image = UIImage.init(named: "profile_nick_icon")
                break
            case 3:
                cell?.textLabel?.text = "Profile photo"
                cell?.imageView?.image = UIImage.init(named: "profile_photo_icon")
                break
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = "Email"
                cell?.detailTextLabel?.text = self.user?.email
                cell?.imageView?.image = UIImage.init(named: "profile_email_icon")
                break
            case 1:
                cell?.textLabel?.text = "Change password"
                cell?.imageView?.image = UIImage.init(named: "profile_pass_icon")
                break
            case 2:
                cell?.textLabel?.text = "Notification"
                cell?.imageView?.image = UIImage.init(named: "profile_notification_icon")
                break
            default:
                break
            }
        }
        return cell!
    }
}

extension ProfileTableViewController: ImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.avatarImageView.image = image
        
        
        
        //let image = info.keys.
    }
}