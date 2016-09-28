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
    private var results: Results<Post>! = nil
    private var days: Results<Day>! = nil
    private var tableView: UITableView
    private var resultsNotificationToken: NotificationToken?
    private var lastDayNotificationToken: NotificationToken?
    private let channel: Channel!


    
//    private var insertedRows = [NSIndexPath]()
//    private var deletedRows = [NSIndexPath]()
//    private var insertedSections = NSMutableIndexSet()
//    private var deletedSections = NSMutableIndexSet()
    
    init(tableView: UITableView, channel: Channel) {
        self.channel = channel
        self.tableView = tableView
        self.unsubscribeRealmNotifications()
        self.prepareResults()
        self.subscribeNotifications()
    }
    
    deinit {
        unsubscribeRealmNotifications()
    }
    
    @objc func unsubscribeRealmNotifications() {
        self.resultsNotificationToken?.stop()
        self.lastDayNotificationToken?.stop()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func subscribeForRealmNotifications() {
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
            (changes: RealmCollectionChange<Results<Post>> ) in
            
            switch changes {
                case .Initial:
                    self.tableView.reloadData()
                    break
                case .Update(_, let deletions, let insertions, _):
                    if (insertions.count > 0) {
                        self.tableView.beginUpdates()
                        //todo inserting sections
                        if self.days?.first?.posts.count == 1 {
                            self.tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .None)
                        }
                        insertions.forEach({ (index:Int) in
                            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
                            print(self.numberOfRows(0))
                        })
                        self.tableView.endUpdates()
                    }
                    //todo modifications and deletions
                
                default: break
                
            }
        }
        
        let configurationBlock = {
            self.resultsNotificationToken = self.results!.addNotificationBlock(resultsNotificationHandler)
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

//MARK: - Notification Subscription
extension FeedNotificationsObserver {
    func subscribeNotifications() {
        Observer.sharedObserver.subscribeForLogoutNotification(self, selector: #selector(unsubscribeRealmNotifications))
        subscribeForRealmNotifications()
    }
}

//MARK: FetchedResultsController
extension FeedNotificationsObserver {
    func prepareResults() {
        if NSThread.isMainThread() {
            fetchPosts()
            fetchDays()
        } else {
            dispatch_sync(dispatch_get_main_queue()) {
                self.fetchPosts()
                self.fetchDays()
            }
        }
    }
    
    func fetchPosts() {
        let predicate = NSPredicate(format: "channelId = %@", self.channel?.identifier ?? "")
        self.results = RealmUtils.realmForCurrentThread().objects(Post.self).filter(predicate).sorted("createdAt", ascending: false)
    }
    func fetchDays() {
        let predicate = NSPredicate(format: "channelId = %@", self.channel?.identifier ?? "")
        self.days = RealmUtils.realmForCurrentThread().objects(Day.self).filter(predicate).sorted("date", ascending: false)
    }
}
//refactor manager for results and tableViewdelegate
//MARK: FetchedResultsController
extension FeedNotificationsObserver {
    func numberOfRows(section:Int) -> Int {
//        print("in day: \(self.days![section].text) : \(self.days![section].posts.count)")
       return self.days![section].posts.count
    }
    
    func numberOfSections() -> Int {
        return self.days!.count ?? 0
    }
    func postForIndexPath(indexPath:NSIndexPath) -> Post {
        return days![indexPath.section].posts[self.numberOfRows(indexPath.section) - indexPath.row - 1]
    }
    func lastPost() -> Post {
        return results!.last!
    }
    func titleForHeader(section:Int) -> String {
        return self.days![section].text!
    }
}
