//
//  MembersViewController.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 09.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import SwiftFetchedResultsController

final class MembersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController
    
}
private protocol Setup {
    func setupNavigationBar()
    func setupTableView()
    func setupSearchController()
}

extension MembersViewController: Setup {
    
}

extension MembersViewController: UITableViewDataSource {
    
}

extension MembersViewController: UITableViewDelegate {
    
}

extension MembersViewController:FetchedResultsControllerDelegate {
    
}