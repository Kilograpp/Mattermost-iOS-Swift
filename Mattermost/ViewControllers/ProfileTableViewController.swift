//
//  ProfileViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import QuartzCore

@objc private enum InfoSections : Int {
    case base
    case registration = 1
    
    static var count: Int { return InfoSections.registration.rawValue + 1}
}

protocol ProfileViewControllerConfiguration {
    func configureForCurrentUser()
    func configureFor(user: User)
}


class ProfileViewController: UIViewController {

//MARK: - Properties
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate lazy var cellBuilder: ProfileCellBuilder = ProfileCellBuilder(tableView: self.tableView)
    var user: User?
    
}


extension ProfileViewController: ProfileViewControllerConfiguration {
    func configureForCurrentUser() {
        self.user = DataManager.sharedInstance.currentUser!
    }
    
    func configureFor(user: User) {
        self.user = user
    }
}


protocol ProfileViewControllerLifeCycle {
    func viewDidLoad()
}

protocol ProfileViewControllerSetup {
    func initialSetup()
    func setupNavigationBar()
    func setupHeader()
    func setupTable()
}

protocol ProfileViewControllerAction {
    func backAction()
}

protocol ProfileViewControllerNavigation {
    func returnToChat()
}


//MARK: ProfileViewControllerLifeCycle

extension ProfileViewController: ProfileViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
    }
}


//MARK: ProfileViewControllerSetup

extension ProfileViewController: ProfileViewControllerSetup {
    func initialSetup() {
        setupNavigationBar()
        setupHeader()
        setupTable()
    }
    
    func setupNavigationBar() {
        self.title = "Профиль"

        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func setupHeader() {
        self.nicknameLabel?.font = UIFont.kg_semibold30Font()
        self.nicknameLabel?.textColor = UIColor.kg_blackColor()
        self.nicknameLabel?.text = self.user?.displayName
        
        self.fullnameLabel.font = UIFont.kg_semibold20Font()
        self.fullnameLabel.textColor = UIColor.kg_blackColor()
        self.fullnameLabel.text = (self.user?.firstName)! + " " + (self.user?.lastName)!
        
        self.avatarImageView?.layer.drawsAsynchronously = true
        self.avatarImageView?.backgroundColor = UIColor.red
        self.avatarImageView?.setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
           ImageDownloader.downloadFullAvatarForUser(self.user!) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeProfilePhoto))
        self.avatarImageView?.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(tapGestureRecognizer);
    }
    
    func setupTable() {
        self.tableView?.backgroundColor = UIColor.kg_lightLightGrayColor()
        self.tableView?.register(ProfileTableViewCell.nib, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier, cacheSize: 10)
    }
}


//MARK: ProfileViewControllerAction

extension ProfileViewController: ProfileViewControllerAction {
    func backAction() {
        returnToChat()
        
    }
}


//MARK: ProfileViewControllerNavigation

extension ProfileViewController: ProfileViewControllerNavigation {
    func returnToChat() {
       _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.Profile.SectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? Constants.Profile.FirsSectionDataSource.count : Constants.Profile.SecondSecionDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cellBuilder.cellFor(user: self.user!, indexPath: indexPath)
    }
}


//MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
}


//MARK: - UIImagePickerController

extension ProfileViewController {
    func changeProfilePhoto() {
        guard self.user?.identifier == Preferences.sharedInstance.currentUserId else { return }
        
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let openCameraAction = UIAlertAction.init(title: "Take photo", style: .default) { (action) in
            self.presentImagePickerControllerWithType(.camera)
        }
        let openGalleryAction = UIAlertAction.init(title: "Take from library", style: .default) { (action) in
            self.presentImagePickerControllerWithType(.photoLibrary)
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(openCameraAction)
        alertController.addAction(openGalleryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentImagePickerControllerWithType(_ type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController.init()
        pickerController.sourceType = type
        pickerController.delegate = self
        
        self.present(pickerController, animated: true, completion: nil)
    }
}


//MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.avatarImageView.image = image
        //Api.sharedInstance.updateImageForCurrentUser(image) { (error) in
            
        //}
        
        
        //let image = info.keys.
    }
}

