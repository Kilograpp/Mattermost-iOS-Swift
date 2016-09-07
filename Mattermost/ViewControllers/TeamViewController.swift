//
//  TeamViewController.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 02.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import SwiftFetchedResultsController
import RealmSwift

let teamCellHeight: CGFloat = 60

final class TeamViewController: UIViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    lazy var fetchedResultsController: FetchedResultsController<Team> = self.realmFetchedResultsController()
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
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.registerClass(TeamTableViewCell.classForCoder(), forCellReuseIdentifier: TeamTableViewCell.reuseIdentifier)
    }
    
    private func setupTitleLabel() {
        self.titleLabel.font = FontBucket.titleURLFont
        self.titleLabel.text = Preferences.sharedInstance.siteName
        self.titleLabel.textColor = ColorBucket.whiteColor
    }
    
    private func setupNavigationView() {
        let bgLayer = CAGradientLayer.blueGradientForNavigationBar()
        bgLayer.frame = CGRect(x:0,y:0,width:CGRectGetWidth(self.navigationView.bounds),height: CGRectGetHeight(self.navigationView.bounds))
        bgLayer.animateLayerInfinitely(bgLayer)
        self.navigationView.layer.insertSublayer(bgLayer, atIndex: 0)
        self.navigationView.bringSubviewToFront(self.titleLabel)
    }
}

// MARK: - UITableViewDelegate
extension TeamViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return teamCellHeight;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let team = self.fetchedResultsController.objectAtIndexPath(indexPath) as Team?
        if (Preferences.sharedInstance.currentTeamId != team?.identifier) {
            // Change in preferences
            Preferences.sharedInstance.currentTeamId = team?.identifier
            //Reload channels and chat
            self.reloadChat()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension TeamViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.numberOfRowsForSectionIndex(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TeamTableViewCell.reuseIdentifier, forIndexPath: indexPath)
        let team = self.fetchedResultsController.objectAtIndexPath(indexPath) as Team?
        (cell as! TeamTableViewCell).configureWithTeam(team!)
        return cell
    }
}


extension TeamViewController {
    // MARK: - FetchedResultsController
    func realmFetchedResultsController() -> FetchedResultsController<Team> {
        let predicate = NSPredicate(format: "identifier != %@", "fds")
        let realm = try! Realm()
        let fetchRequest = FetchRequest<Team>(realm: realm, predicate: predicate)
        fetchRequest.predicate = nil
        let sortDescriptorName = SortDescriptor(property: TeamAttributes.displayName.rawValue, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorName]
        let fetchedResultsController = FetchedResultsController<Team>(fetchRequest: fetchRequest, sectionNameKeyPath:nil, cacheName: nil)
        fetchedResultsController.delegate = nil//self
        fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }
    // MARK: - Navigation
    func reloadChat() {
        Api.sharedInstance.loadChannels(with: { (error) in
            Api.sharedInstance.loadCompleteUsersList({ (error) in
                RouterUtils.loadInitialScreen()
                //reload chat и left menu
            })
        })
    }
}