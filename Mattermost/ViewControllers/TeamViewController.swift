//
//  TeamViewController.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 02.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

let teamCellHeight: CGFloat = 60

final class TeamViewController: UIViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    

    var realm: Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitleLabel()
        setupTableView()
        setupNavigationView()
    }
}

private protocol Setup {
    func setupTitleLabel()
    func setupTableView()
    func setupNavigationView()
}

// MARK: - Setup
extension TeamViewController: Setup {
    fileprivate func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.register(TeamTableViewCell.classForCoder(), forCellReuseIdentifier: TeamTableViewCell.reuseIdentifier)
    }
    
    fileprivate func setupTitleLabel() {
        self.titleLabel.font = FontBucket.titleURLFont
        self.titleLabel.text = Preferences.sharedInstance.siteName
        self.titleLabel.textColor = ColorBucket.whiteColor
    }
    
    fileprivate func setupNavigationView() {
        let bgLayer = CAGradientLayer.blueGradientForNavigationBar()
        bgLayer.frame = CGRect(x:0,y:0,width:self.navigationView.bounds.width,height: self.navigationView.bounds.height)
        bgLayer.animateLayerInfinitely(bgLayer)
        self.navigationView.layer.insertSublayer(bgLayer, at: 0)
        self.navigationView.bringSubview(toFront: self.titleLabel)
    }
}

// MARK: - UITableViewDelegate
extension TeamViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return teamCellHeight;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = Team()
        if (Preferences.sharedInstance.currentTeamId != team.identifier) {
            Preferences.sharedInstance.currentTeamId = team.identifier
            self.reloadChat()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension TeamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamTableViewCell.reuseIdentifier, for: indexPath)
        let team = Team()
        (cell as! TeamTableViewCell).configureWithTeam(team)
        return cell
    }
}


extension TeamViewController {
    // TODO: without FRC
    
    // MARK: - Navigation
    func reloadChat() {
        Api.sharedInstance.loadChannels(with: { (error) in
            Api.sharedInstance.loadCompleteUsersList({ (error) in
                RouterUtils.loadInitialScreen()
            })
        })
    }
}
