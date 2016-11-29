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

//MARK: Properties
    fileprivate var results: Results<Post>! = nil
    fileprivate var days: Results<Day>! = nil
    fileprivate var tableView: UITableView
    fileprivate var resultsNotificationToken: NotificationToken?
    fileprivate var lastDayNotificationToken: NotificationToken?
    fileprivate let channel: Channel!
    
//MARK: LifeCycle
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
        let resultsNotificationHandler = {
            (changes: RealmCollectionChange<Results<Post>> ) in
            
            switch changes {
                case .initial:
                    self.tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    
                        if insertions.count > 1 || deletions.count > 1 || modifications.count > 1 {
                            self.tableView.reloadData()
                            break
                        }
                        
                        if deletions.count > 0 {
                            //TEMP:
                            self.tableView.reloadData()
                        }
                        self.tableView.beginUpdates()
                        if (insertions.count > 0) {
                            if self.days?.first?.posts.count == 1 {
                                self.tableView.insertSections(NSIndexSet(index: 0) as IndexSet, with: .none)
                            }
                            insertions.forEach({ (index:Int) in
                                self.tableView.insertRows(at: [NSIndexPath(row: 0, section: 0) as IndexPath], with: .automatic)
                            })
                        }
                    
                        if modifications.count > 0 {
                        modifications.forEach({ (index:Int) in
                            let post = self.results[index]
                            var rowsForReload = Array<IndexPath>()
                            rowsForReload.append(self.indexPathForPost(post))
                            //self.tableView.reloadRows(at: [self.indexPathForPost(post)], with: .automatic)
                            if let postIdentifier = post.identifier {
                                let comments = RealmUtils.realmForCurrentThread().objects(Post.self).filter("\(PostAttributes.parentId) == %@", postIdentifier)
                                for comment in comments {
                                    rowsForReload.append(self.indexPathForPost(comment))
                                }
                                self.tableView.reloadRows(at: rowsForReload, with: .automatic)
                            }
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
    }
    func postForIndexPath(_ indexPath:IndexPath) -> Post {
        return days![indexPath.section].sortedPosts()[self.numberOfRows(indexPath.section) - indexPath.row - 1]
    }
    func lastPost() -> Post {
        return results!.last!
    }
    func titleForHeader(_ section:Int) -> String {
        return self.days![section].text!
    }
    func indexPathForPost(_ post: Post) -> IndexPath {
        let day = post.day
        let daysPosts = day?.sortedPosts()
        let indexOfDay = (self.days?.index(of: day!))!
        let indexOfPost = (day?.posts.count)! - 1 - (daysPosts?.index(of: post))!
        let indexPath = NSIndexPath(row: indexOfPost, section: indexOfDay) as IndexPath
        
        return indexPath
    }
}
