//
//  GitLabViewController.swift
//  Mattermost
//
//  Created by Florin Peter on 16.04.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import UIKit

class GitLabViewController: UIViewController, UIWebViewDelegate {

    //MARK: Properties
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loader: UIView!
    let titleName =  NSLocalizedString("GitLab", comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        login()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
            if let cookies = HTTPCookieStorage.shared.cookies {
                for cookie in cookies {
                    if cookie.name == "MMAUTHTOKEN" {
                        Api.sharedInstance.loginWithToken(cookie.value) { (error) in
                            guard (error == nil) else {
                                let message = (error?.message == nil ? "an error occurred" : (error?.message))
                                AlertManager.sharedManager.showErrorWithMessage(message: message!)
                                
                                self.login()
                                
                                return
                            }
                            
                            self.loadTeams();
                        }
                    }
                }
            }
        
        
        return true
    }
}

fileprivate protocol Setup {
    func initialSetup()
}

//MARK: Setup
extension GitLabViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
    }
    
    fileprivate func setupNavigationBar() {
        let titleAttribute = [ NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: FontBucket.normalTitleFont ]
        guard let navigationController = self.navigationController else { return }
        
        navigationController.navigationBar.titleTextAttributes = titleAttribute
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.backgroundColor = UIColor.clear
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.title = self.titleName
        self.setNeedsStatusBarAppearanceUpdate()
    }    
}

fileprivate protocol Request {
    func login()
    func loadTeams()
}


//MARK: Request
extension GitLabViewController: Request {
    func login() {
        webView.delegate = self
        
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        
        let url = URL(string: Preferences.sharedInstance.serverUrl! + "/api/v3/oauth/gitlab/login")
        let request = URLRequest(url: url!)
        
        webView.loadRequest(request)
    }
    
    func loadTeams() {
        Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
            guard (error == nil) else { self.hideLoaderView(); return }
            
            if userShouldSelectTeam {
                self.hideLoaderView()
                self.proceedToTeams()
            }
            else {
                self.loadTeamChannels()
            }
        })
    }
    
    func proceedToTeams() {
        let teamViewController = self.storyboard?.instantiateViewController(withIdentifier: "TeamViewController")
        self.navigationController?.pushViewController(teamViewController!, animated: true)
    }
    
    func loadTeamChannels() {
        Api.sharedInstance.loadChannels { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            self.loadPreferedDirectChannelsInterlocuters()
        }
    }
    
    func loadPreferedDirectChannelsInterlocuters() {
        let preferences = Preference.preferedUsersList()
        var usersIds = Array<String>()
        preferences.forEach{ usersIds.append($0.name!) }
        
        Api.sharedInstance.loadUsersListBy(ids: usersIds) { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            self.loadTeamMembers()
        }
    }
    
    func loadTeamMembers() {
        let predicate = NSPredicate(format: "identifier != %@ AND identifier != %@", Preferences.sharedInstance.currentUserId!,
                                    Constants.Realm.SystemUserIdentifier)
        let users = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate)
        var ids = Array<String>()
        users.forEach{ ids.append($0.identifier) }
        
        Api.sharedInstance.loadTeamMembersListBy(ids: ids) { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            Api.sharedInstance.getChannelMembers { (error) in
                guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
                DispatchQueue.main.async {
                    self.hideLoaderView()
                    RouterUtils.loadInitialScreen()
                }
            }
        }
    }

}
