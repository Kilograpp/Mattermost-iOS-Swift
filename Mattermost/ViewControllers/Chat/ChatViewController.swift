//
//  ChatViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 25.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import SlackTextViewController
import RealmSwift
import UITableView_Cache
import SwiftFetchedResultsController

class ChatViewController: SLKTextViewController {
    private var channel : Channel?
    lazy var fetchedResultsController: FetchedResultsController<Post> = self.realmFetchedResultsController()
    var realm: Realm?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureInputBar()
        self.configureTableView()
        
        Preferences.sharedInstance.serverUrl = "https://mattermost.kilograpp.com"
        Api.sharedInstance.login("getmaxx@kilograpp.com", password: "102Aky5i") { (error) in
            Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
                print(RealmUtils.realmForCurrentThread().objects(User).filter("username = 'jufina'").first!)
                Api.sharedInstance.loadChannels(with: { (error) in
                    print(RealmUtils.realmForCurrentThread().objects(User).filter("username = 'jufina'").first!)
                    self.channel = try! Realm().objects(Channel).filter("privateTeamId != ''").first!
                    self.title = self.channel?.displayName
                    Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
                        print(RealmUtils.realmForCurrentThread().objects(User).filter("username = 'jufina'").first!)
                        self.fetchedResultsController = self.realmFetchedResultsController()
                        self.tableView?.reloadData()
                    })
                })
            })
        }
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Grouped
    }
    
    
    //MARK: - Configuration
    
    func configureTableView() -> Void {
        self.tableView?.separatorStyle = .None
        self.tableView?.keyboardDismissMode = .OnDrag
        self.tableView?.backgroundColor = ColorBucket.whiteColor
        self.tableView!.registerClass(FeedCommonTableViewCell.self, forCellReuseIdentifier: FeedCommonTableViewCell.reuseIdentifier(), cacheSize: 10)
        self.tableView!.registerClass(FeedAttachmentsTableViewCell.self, forCellReuseIdentifier: FeedAttachmentsTableViewCell.reuseIdentifier(), cacheSize: 10)
        self.tableView!.registerClass(FeedFollowUpTableViewCell.self, forCellReuseIdentifier: FeedFollowUpTableViewCell.reuseIdentifier(), cacheSize: 10)
        
        self.tableView?.registerClass(FeedTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView.isEqual(self.tableView)) {
            let prevIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section) as NSIndexPath
            let post = self.fetchedResultsController.objectAtIndexPath(indexPath)! as Post
            let prevPost = self.fetchedResultsController.objectAtIndexPath(prevIndexPath) as Post?
            
            var reuseIdentifier : String!
            
            if (prevPost != nil && post.hasSameAuthor(prevPost)) {
                reuseIdentifier = post.hasAttachments() ? FeedAttachmentsTableViewCell.reuseIdentifier() : FeedFollowUpTableViewCell.reuseIdentifier()
            } else {
                reuseIdentifier = post.hasAttachments() ? FeedAttachmentsTableViewCell.reuseIdentifier() : FeedCommonTableViewCell.reuseIdentifier()
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! FeedTableViewCellProtocol
            (cell as! UITableViewCell).transform = tableView.transform
            cell.configureWithPost(post)
            (cell as! UITableViewCell).selectionStyle = .None
            
            return cell as! UITableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(FeedCommonTableViewCell.reuseIdentifier()) as! FeedCommonTableViewCell
            cell.backgroundColor = UIColor.redColor()
            return cell
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(FeedTableViewSectionHeader.reuseIdentifier()) as! FeedTableViewSectionHeader
        let frcTitleForHeader = self.fetchedResultsController.titleForHeaderInSection(section) as String
        let titleDate = NSDateFormatter.sharedConversionSectionsDateFormatter.dateFromString(frcTitleForHeader)! as NSDate
        let titleString = titleDate.feedSectionDateFormat()
        view.configureWithTitle(titleString)
        view.transform = tableView.transform
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FeedTableViewSectionHeader.height()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (tableView.isEqual(self.tableView)) {
            let prevIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section) as NSIndexPath
            let post = self.fetchedResultsController.objectAtIndexPath(indexPath)! as Post
            let prevPost = self.fetchedResultsController.objectAtIndexPath(prevIndexPath) as Post?
            
            if (prevPost != nil && post.hasSameAuthor(prevPost)) {
                return post.hasAttachments() ? FeedAttachmentsTableViewCell.heightWithPost(post) : FeedFollowUpTableViewCell.heightWithPost(post)
            } else {
                return post.hasAttachments() ? FeedAttachmentsTableViewCell.heightWithPost(post) : FeedCommonTableViewCell.heightWithPost(post)
            }
        } else {
            return 0
        }
    }

    
    // MARK: - FetchedResultsController
    
    func realmFetchedResultsController() -> FetchedResultsController<Post> {
        let predicate = NSPredicate(format: "privateChannelId = %@", self.channel?.identifier ?? "")
        let realm = try! Realm()
        let fetchRequest = FetchRequest<Post>(realm: realm, predicate: predicate)
        let sortDescriptorSection = SortDescriptor(property: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptorSection]
        let fetchedResultsController = FetchedResultsController<Post>(fetchRequest: fetchRequest, sectionNameKeyPath: "creationDayString", cacheName: "testCache")
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch()

        return fetchedResultsController
    }
    
    
    // MARK: - Configuration
    
    func configureInputBar() -> Void {
        self.configureTextView()
        self.configureInputViewButtons()
        self.configureToolbar()
    }
    
    func configureTextView() -> Void {
        self.shouldClearTextAtRightButtonPress = false;
        self.textView.delegate = self;
        self.textView.placeholder = "Type something..."
        self.textView.layer.borderWidth = 0;
        self.textInputbar.textView.font = FontBucket.inputTextViewFont;
    }
    
    func configureInputViewButtons() -> Void {
        self.rightButton.titleLabel!.font = FontBucket.feedSendButtonTitleFont;
        self.rightButton.setTitle("Send", forState: .Normal)
        self.rightButton.addTarget(self, action: #selector(sendPost), forControlEvents: .TouchUpInside)
        
        self.leftButton.setImage(UIImage.init(named: "chat_photo_icon"), forState: .Normal)
        self.leftButton.tintColor = UIColor.grayColor()
        self.leftButton.addTarget(self, action: #selector(assignPhotos), forControlEvents: .TouchUpInside)
    }
    
    func configureToolbar() -> Void {
        self.textInputbar.autoHideRightButton = false;
        self.textInputbar.translucent = false;
        // TODO: Code Review: Заменить на стиль из темы
        self.textInputbar.barTintColor = UIColor.whiteColor()
    }
    
    func sendPost() -> Void {
        PostUtils.sharedInstance.sentPostForChannel(with: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            self.clearTextView()
        }
    }
    func assignPhotos() -> Void {
    }
}


// MARK: - FetchedResultsControllerDelegate

extension ChatViewController: FetchedResultsControllerDelegate {
    func controllerWillChangeContent<T : Object>(controller: FetchedResultsController<T>) {
        self.tableView!.beginUpdates()
    }
    
    func controllerDidChangeObject<T : Object>(controller: FetchedResultsController<T>, anObject: SafeObject<T>, indexPath: NSIndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let tableView = self.tableView
        
        switch changeType {
            
        case .Insert:
            
            tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
        case .Delete:
            
            tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
        case .Update:
            
            tableView!.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
        case .Move:
            
            tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
            tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func controllerDidChangeSection<T : Object>(controller: FetchedResultsController<T>, section: FetchResultsSectionInfo<T>, sectionIndex: UInt, changeType: NSFetchedResultsChangeType) {
        
        let tableView = self.tableView
        
        if changeType == NSFetchedResultsChangeType.Insert {
            
            let indexSet = NSIndexSet(index: Int(sectionIndex))
            
            tableView!.insertSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        }
        else if changeType == NSFetchedResultsChangeType.Delete {
            
            let indexSet = NSIndexSet(index: Int(sectionIndex))
            
            tableView!.deleteSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func controllerDidChangeContent<T : Object>(controller: FetchedResultsController<T>) {
        self.tableView!.endUpdates()
    }
    
    func controllerWillPerformFetch<T : Object>(controller: FetchedResultsController<T>) {}
    func controllerDidPerformFetch<T : Object>(controller: FetchedResultsController<T>) {}
}


// MARK: - Utils

extension ChatViewController {
    func clearTextView() -> Void {
        self.textView.text = nil
    }
}

