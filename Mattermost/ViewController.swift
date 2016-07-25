//
//  ViewController.swift
//  Mattermost
//
//  Created by Maxim Gubin on 28/06/16.
//  Copyright (c) 2016 Kilograpp. All rights reserved.
//


import UIKit
import RealmSwift

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        Preferences.sharedInstance.serverUrl = "https://mattermost.kilograpp.com"
        Api.sharedInstance.login("maxim@kilograpp.com", password: "loladin") { (error) in
            Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
                Api.sharedInstance.loadChannels(with: { (error) in
                    Api.sharedInstance.loadFirstPage(try! Realm().objects(Channel).first!, completion: { (error) in
                        
                    })
                })
            })
            
        }
    // Do any additional setup after loading the view, typically from a nib.
    }


    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }




}
