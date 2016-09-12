//
//  ProfileViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

@objc private enum InfoSections : Int {
    case Base
    case Registration = 1
    
    static var count: Int { return InfoSections.Registration.rawValue + 1}
}

class ProfileViewController: UIViewController {

//MARK: - Properties
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSourceFirstSection: NSArray?
    var dataSourceSecondSection: NSArray?
    var user: User?
    
    
//MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
     //   initialSetup()
    }
}


//MARK: - Setup

extension ProfileViewController {
    func initialSetup() {
        self.user = DataManager.sharedInstance.currentUser!
    
        setupDataSource()
        setupNavigationBar()
        setupHeader()
        setupTable()
    }
    
    func setupNavigationBar() {
        self.title = "Профиль"
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_close_icon"), style: .Done, target: self, action: #selector(backAction))
        backButton.tintColor = UIColor.blackColor()
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func setupHeader() {
        self.nameLabel?.font = UIFont.kg_semibold30Font()
        self.nameLabel?.textColor = UIColor.kg_blackColor()
        self.nameLabel?.text = self.user!.nickname
        
        self.avatarImageView?.layer.cornerRadius = CGRectGetHeight(self.avatarImageView!.bounds) / 2
        self.avatarImageView?.layer.drawsAsynchronously = true
        self.avatarImageView?.clipsToBounds = true
        self.avatarImageView?.backgroundColor = UIColor.whiteColor()
        self.avatarImageView?.setIndicatorStyle(UIActivityIndicatorViewStyle.Gray)
        //print(self.user?.avatarURL())
        //self.avatarImageView?.sd_setImageWithURL(self.user!.avatarURL(), placeholderImage: nil, completed: nil)
        self.avatarImageView?.image = UIImage.sharedAvatarPlaceholder
        
        ImageDownloader.downloadFeedAvatarForUser(self.user!) { [weak self] (image, error) in
            if (image == nil) {
                print(error?.localizedDescription)
            }
            self?.avatarImageView.image = image
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeProfilePhoto))
        self.avatarImageView?.userInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(tapGestureRecognizer);
    }
    
    func setupTable() {
        self.tableView?.backgroundColor = UIColor.kg_lightLightGrayColor()
        self.tableView?.registerNib(ProfileTableViewCell.nib, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier, cacheSize: 10)
    }
}


//MARK: - Private

extension ProfileViewController {
    func setupDataSource() {
        let firstSection = NSMutableArray()
        firstSection.addObject(ProfileDataSource.entryWithTitle("Name", iconName: "profile_name_icon", info: self.user!.firstName!, handler: {
            NSLog("Navigate to profile")
        }))
        firstSection.addObject(ProfileDataSource.entryWithTitle("Username", iconName: "profile_usename_icon", info: self.user!.nickname!, handler: {
            NSLog("Navigate to profile")
        }))
        firstSection.addObject(ProfileDataSource.entryWithTitle("Nickname", iconName: "profile_nick_icon", info: self.user!.nickname!, handler: {
            NSLog("Navigate to profile")
        }))
        firstSection.addObject(ProfileDataSource.entryWithTitle("Profile photo", iconName: "profile_photo_icon", info: String(), handler: {
            NSLog("Navigate to profile")
        }))
        self.dataSourceFirstSection = firstSection
        
        let secondSection = NSMutableArray()
        secondSection.addObject(ProfileDataSource.entryWithTitle("Email", iconName: "profile_email_icon", info: self.user!.email!, handler: {
            NSLog("Navigate to profile")
        }))
        secondSection.addObject(ProfileDataSource.entryWithTitle("Change password", iconName: "profile_pass_icon", info: String(), handler: {
            NSLog("Navigate to profile")
        }))
        secondSection.addObject(ProfileDataSource.entryWithTitle("Notification", iconName: "profile_notification_icon", info: "On", handler: {
            NSLog("Navigate to profile")
        }))
        self.dataSourceSecondSection = secondSection
    }
}


//MARK: - Actions

extension ProfileViewController {
    func backAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


//MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print(InfoSections.count)
        return InfoSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case InfoSections.Base.rawValue:
            print(self.dataSourceFirstSection?.count)
            return (self.dataSourceFirstSection?.count)!
            
        case InfoSections.Registration.rawValue:
            print(self.dataSourceSecondSection?.count)
            return (self.dataSourceSecondSection?.count)!
            
        default:
            break
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = ProfileTableViewCell.reuseIdentifier
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier:identifier) as! ProfileTableViewCell
        }
        
        switch indexPath.section {
        case InfoSections.Base.rawValue:
            (cell as! ProfileTableViewCell).configureWithObject(self.dataSourceFirstSection![indexPath.row])
            
        case InfoSections.Registration.rawValue:
            (cell as! ProfileTableViewCell).configureWithObject(self.dataSourceSecondSection![indexPath.row])
            
        default:
            break
        }
        return cell!
    }
}


//MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
}


//MARK: - UIImagePickerController

extension ProfileViewController {
    func changeProfilePhoto() {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        let openCameraAction = UIAlertAction.init(title: "Take photo", style: .Default) { (action) in
            self.presentImagePickerControllerWithType(.Camera)
        }
        let openGalleryAction = UIAlertAction.init(title: "Take from library", style: .Default) { (action) in
            self.presentImagePickerControllerWithType(.PhotoLibrary)
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(openCameraAction)
        alertController.addAction(openGalleryAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentImagePickerControllerWithType(type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController.init()
        pickerController.sourceType = type
        pickerController.delegate = self
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
}


//MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.avatarImageView.image = image
        //Api.sharedInstance.updateImageForCurrentUser(image) { (error) in
            
        //}
        
        
        //let image = info.keys.
    }
}

