//
//  FeedNotificationsObserver.swift
//  Mattermost
//
//  Created by Maxim Gubin on 12/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

private protocol Interface: class {
    func unsubscribeNotifications()
    func subscribeForRealmNotifications()
}


final class FeedNotificationsObserver {

    fileprivate var results: Results<Post>! = nil
    fileprivate var days: Results<Day>! = nil
    fileprivate weak var tableView: UITableView!
    var resultsNotificationToken: NotificationToken?
    fileprivate let channel: Channel!

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
}


//MARK: Interface
extension FeedNotificationsObserver: Interface {
    @objc func unsubscribeNotifications() {
        self.resultsNotificationToken?.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribeForRealmNotifications() {
        let resultsNotificationHandler = { (changes: RealmCollectionChange<Results<Day>> ) in
            switch changes {
                case .initial:
                    self.tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):

                    if deletions.count > 0 {
                        self.tableView.reloadData()
                        break
                    }
                    
                    var rowsToInsert: [IndexPath] = []
                    var sectionsToReload: [Int] = []
                    
                    for index in modifications {
                        let newRowsCount = self.days[index].posts.count - self.tableView.numberOfRows(inSection: index)
                        if newRowsCount == 1 && insertions.count == 0 && index == 0{ // fix me plzzz
                            rowsToInsert.append(IndexPath(row: 0, section: index))
                        } else {
                            guard newRowsCount > 0 else {
                                sectionsToReload.append(index);
                                continue
                            }
                            for row in 0..<newRowsCount {
                                rowsToInsert.append(IndexPath(row: self.tableView.numberOfRows(inSection: index) + row, section: index))
                            }
                        }

                    }

                    
                    self.tableView.beginUpdates()
                    self.tableView.insertSections(IndexSet(insertions), with: .top)
                    self.tableView.reloadSections(IndexSet(sectionsToReload), with: .automatic)
                    self.tableView.insertRows(at: rowsToInsert, with: .automatic)
                    self.tableView.endUpdates()
                    
                default: break
            }
        }
        
        let configurationBlock = {
            self.resultsNotificationToken = self.days!.addNotificationBlock(resultsNotificationHandler)
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
        self.results = RealmUtils.realmForCurrentThread().objects(Post.self).filter(predicate).sorted(byKeyPath: "createdAt", ascending: false)
    }
    func fetchDays() {
        let predicate = NSPredicate(format: "channelId = %@", self.channel?.identifier ?? "")
        self.days = RealmUtils.realmForCurrentThread().objects(Day.self).filter(predicate).sorted(byKeyPath: "date", ascending: false)
    }
}


//MARK: FetchedResultsController
extension FeedNotificationsObserver {
    func numberOfPosts() -> Int {
        return self.results.count
    }
    
    func numberOfRows(_ section:Int) -> Int {
       return self.days![section].posts.count
    }
    func numberOfSections() -> Int {
        return days.count
    }
    func postForIndexPath(_ indexPath:IndexPath) -> Post {
        var postIndex: Int = self.numberOfRows(indexPath.section) - indexPath.row - 1
        if postIndex < 0 {
            postIndex = 0
        }
        return days![indexPath.section].sortedPosts()[postIndex]
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
