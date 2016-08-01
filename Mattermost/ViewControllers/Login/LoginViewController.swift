//
//  LoginViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

class LoginViewController: UIViewController {

    @IBAction func loginAction(sender: AnyObject) {
        Preferences.sharedInstance.serverUrl = Preferences.sharedInstance.predefinedServerUrl()
        Api.sharedInstance.login(Preferences.sharedInstance.predefinedLogin()!, password: Preferences.sharedInstance.predefinedPassword()!) { (error) in
            Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
                Api.sharedInstance.loadChannels(with: { (error) in
                    let channels = RealmUtils.realmForCurrentThread().objects(Channel)
                    try! RealmUtils.realmForCurrentThread().write({
                        channels.forEach{ $0.computeDispayNameIfNeeded()}
                    })
                    RouterUtils.loadInitialScreen(true)
                })
            })
        }

    }
}
