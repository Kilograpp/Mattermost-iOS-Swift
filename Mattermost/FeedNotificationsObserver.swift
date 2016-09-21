//
//  FeedNotificationsObserver.swift
//  Mattermost
//
//  Created by Maxim Gubin on 12/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift


final class FeedNotificationsObserver {
    private let results: Results<Day>
    private let tableView: UITableView
    private var resultsNotificationToken: NotificationToken?
    private var lastDayNotificationToken: NotificationToken?

    
//    private var insertedRows = [NSIndexPath]()
//    private var deletedRows = [NSIndexPath]()
//    private var insertedSections = NSMutableIndexSet()
//    private var deletedSections = NSMutableIndexSet()
    
    init(results: Results<Day>, tableView: UITableView) {
        self.results = results
        self.tableView = tableView
        self.subscribeForNotifications()
    }
    
    deinit {
        self.resultsNotificationToken?.stop()
        self.lastDayNotificationToken?.stop()
    }
    
    
    
    func subscribeForNotifications() {
//        let lastDayNotificationsBlock = { (changes: RealmCollectionChange<LinkingObjects<Post>> ) in
//            switch changes {
//                case .Update(_, let deletions, let insertions, _):
//                    // Query results have changed, so apply them to the UITableView
//                    self.tableView.beginUpdates()
//                    self.tableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: self.lastDaySection) } , withRowAnimation: .Automatic)
//                    self.tableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: self.lastDaySection) }, withRowAnimation: .Automatic)
//                    self.tableView.endUpdates()
//                    break
//                default: break
//            }
//        }
//        
        let resultsNotificationHandler = {
            (changes: RealmCollectionChange<Results<Day>> ) in
            
            switch changes {
                case .Initial:
                    self.tableView.reloadData()
                    break
                case .Update(_, let deletions, let insertions, _):
                    // Query results have changed, so apply them to the UITableView
  
                    // temp: while insertions.count = 0,  error on line 72 (insertions[0])
                    if (insertions.count == 0 && deletions.count == 0) {
                        return
                    }
                    
                    guard insertions.count > 0 || deletions.count > 0 else {
                        self.tableView.reloadData()
                        return
                    }
                    
                    guard insertions[0] != 0 && insertions.count != 1 else {
                        self.tableView.reloadData()
                        return
                    
                    }
                    var insertedRows = [NSIndexPath]()
                    
                    let lastDaySection = self.tableView.numberOfSections - 1
                    let currentNumberOfRows = self.tableView.numberOfRowsInSection(lastDaySection)
                    let updatedNumberOfRows = self.results[lastDaySection].posts.count
                    
                    for index in currentNumberOfRows..<updatedNumberOfRows {
                        insertedRows.append(NSIndexPath(forRow: index , inSection: lastDaySection))
                    }
                    
                    let insertedSections = NSMutableIndexSet()
                    for section in insertions {
                        let postsCount = self.results[section].posts.count
                        insertedSections.addIndex(section)
                        for row in 0..<postsCount {
                            insertedRows.append(NSIndexPath(forRow: row, inSection: section))
                        }
                    }
                    
                    var deletedRows = [NSIndexPath]()
                    let deletedSections = NSMutableIndexSet()
                    for section in deletions {
                        let postsCount = self.tableView.numberOfRowsInSection(section)
                        deletedSections.addIndex(section)
                        for row in 0..<postsCount {
                            deletedRows.append(NSIndexPath(forRow: row, inSection: section))
                        }
                    }
                    
                    UIView.setAnimationsEnabled(false)
                    self.tableView.beginUpdates()
                    self.tableView.insertSections(insertedSections, withRowAnimation: .None)
                    self.tableView.deleteSections(deletedSections, withRowAnimation: .None)
                    self.tableView.deleteRowsAtIndexPaths(deletedRows, withRowAnimation: .None)
                    self.tableView.insertRowsAtIndexPaths(insertedRows, withRowAnimation: .None)
                    
                    self.tableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                    break
                default: break
            }
        }
        
        let configurationBlock = {
            self.resultsNotificationToken = self.results.addNotificationBlock(resultsNotificationHandler)
            //self.lastDayNotificationToken = self.results.last?.posts.addNotificationBlock(lastDayNotificationsBlock)
        }
    
        if NSThread.isMainThread() {
            configurationBlock()
            
        } else {
            dispatch_sync(dispatch_get_main_queue()) {
                configurationBlock()
            }
        }

    }
}