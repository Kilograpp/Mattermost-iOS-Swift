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
    fileprivate var results: Results<Post>! = nil
    fileprivate var days: Results<Day>! = nil
    fileprivate var tableView: UITableView
    fileprivate var resultsNotificationToken: NotificationToken?
    fileprivate var lastDayNotificationToken: NotificationToken?
    fileprivate let channel: Channel!


    
//    private var insertedRows = [NSIndexPath]()
//    private var deletedRows = [NSIndexPath]()
//    private var insertedSections = NSMutableIndexSet()
//    private var deletedSections = NSMutableIndexSet()
    
    init(tableView: UITableView, channel: Channel) {
        self.channel = channel
        self.tableView = tableView
        self.unsubscribeNotifications()
        self.prepareResults()
        self.subscribeNotifications()
    }
    
    deinit {
        unsubscribeNotifications()
    }
    
    @objc func unsubscribeNotifications() {
        self.resultsNotificationToken?.stop()
        NotificationCenter.default.removeObserver(self)
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
                case .initial:
                    self.tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    

                        if deletions.count > 0 {
//                            // for last section (don't work at others) with 0 posts
//                            if (self.numberOfRows(0) == 0) {
////                                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
//                                self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .None)
//                            } else {
//                                //for other posts
//                                deletions.forEach({ (index:Int) in
//                                    let row = self.indexPathForPost(self.results[index]).row - 1
//                                    let section = self.indexPathForPost(self.results[index]).section
//                                    self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: section)], withRowAnimation: .Automatic)
//                                    print ("deletion on section \(self.indexPathForPost(self.results[index]).section) and row:\(self.indexPathForPost(self.results[index]).row)")
//                                })
//                            }
                            //TEMP:
                            self.tableView.reloadData()
                            
                        }
                        self.tableView.beginUpdates()
                        if (insertions.count > 0) {
                        
                            // IndexSet
                            if self.days?.first?.posts.count == 1 {
                                self.tableView.insertSections(NSIndexSet(index: 0) as IndexSet, with: .none)
                            }
                            insertions.forEach({ (index:Int) in
                                self.tableView.insertRows(at: [NSIndexPath(row: 0, section: 0) as IndexPath], with: .automatic)
                            })
                        
                        }
                    
                        if modifications.count > 0 {
                        modifications.forEach({ (index:Int) in
                            self.tableView.reloadRows(at: [self.indexPathForPost(self.results[index])], with: .automatic)
                        })
                        }

                    
                    self.tableView.endUpdates()
                
                default: break
                
            }
        }
        
        let configurationBlock = {
            self.resultsNotificationToken = self.results!.addNotificationBlock(resultsNotificationHandler)
            //self.lastDayNotificationToken = self.results.last?.posts.addNotificationBlock(lastDayNotificationsBlock)
        }

        if Thread.isMainThread {
            configurationBlock()
            
        } else {
            DispatchQueue.main.sync {
                configurationBlock()
            }
        }

    }
}

//MARK: - Notification Subscription
extension FeedNotificationsObserver {
    func subscribeNotifications() {
        Observer.sharedObserver.subscribeForLogoutNotification(self, selector: #selector(unsubscribeNotifications))
        subscribeForRealmNotifications()
    }
}

//MARK: FetchedResultsController
extension FeedNotificationsObserver {
    func prepareResults() {
        if Thread.isMainThread {
            fetchPosts()
            fetchDays()
        } else {
            DispatchQueue.main.sync {
                self.fetchPosts()
                self.fetchDays()
            }
        }
    }
    
    func fetchPosts() {
        let predicate = NSPredicate(format: "channelId = %@", self.channel?.identifier ?? "")
        self.results = RealmUtils.realmForCurrentThread().objects(Post.self).filter(predicate).sorted(byProperty: "createdAt", ascending: false)
    }
    func fetchDays() {
        let predicate = NSPredicate(format: "channelId = %@", self.channel?.identifier ?? "")
        self.days = RealmUtils.realmForCurrentThread().objects(Day.self).filter(predicate).sorted(byProperty: "date", ascending: false)
    }
}
//refactor
//MARK: FetchedResultsController
extension FeedNotificationsObserver {
    func numberOfRows(_ section:Int) -> Int {
       return self.days![section].posts.count
    }
    
    func numberOfSections() -> Int {
        return days.count
//        let daysCount = days.filter { (day:Day) -> Bool in
//            return day.posts.count > 0
//        }.count
//        return daysCount
    }
    func postForIndexPath(_ indexPath:IndexPath) -> Post {
//        return days![indexPath.section].posts[self.numberOfRows(indexPath.section) - indexPath.row - 1]
        return days![indexPath.section].sortedPosts()[self.numberOfRows(indexPath.section) - indexPath.row - 1]
    }
    func lastPost() -> Post {
        return results!.last!
    }
    func titleForHeader(_ section:Int) -> String {
        return self.days![section].text!
    }
    fileprivate func indexPathForPost(_ post: Post) -> IndexPath {
        let day = post.day
        let daysPosts = day?.sortedPosts()
        let indexOfDay = (self.days?.index(of: day!))!
//        let invertedIndexOfPost = (day?.posts.count)! - 1 - (day?.posts.indexOf(post))!
        let indexOfPost = (day?.posts.count)! - 1 - (daysPosts?.index(of: post))!
        let indexPath = NSIndexPath(row: indexOfPost, section: indexOfDay) as IndexPath
        
        return indexPath
    }
}
