//
//  ChatViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 25.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import SlackTextViewController
import RealmSwift
import SwiftFetchedResultsController

final class ChatViewController: SLKTextViewController, ChannelObserverDelegate {
    private var channel : Channel?
    private lazy var resultsControllerDelegate: SimpleFRCDelegateImplementation = SimpleFRCDelegateImplementation(tableView: self.tableView)
    private lazy var builder: FeedCellBuilder = FeedCellBuilder(tableView: self.tableView, fetchedResultsController: self.fetchedResultsController)
    
    override var tableView: UITableView! { return super.tableView }
    
    lazy var fetchedResultsController: FetchedResultsController<Post> = self.realmFetchedResultsController()
    
    var refreshControl: UIRefreshControl?
    
    var hasNextPage: Bool = true
    var isLoadingInProgress: Bool = false
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureInputBar()
        self.configureTableView()
        self.setupRefreshControl()
        
        ChannelObserver.sharedObserver.delegate = self
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Grouped
    }
    
    
    //MARK: - Configuration
    
    func configureTableView() -> Void {
        self.tableView.separatorStyle = .None
        self.tableView.keyboardDismissMode = .OnDrag
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.registerClass(FeedCommonTableViewCell.self, forCellReuseIdentifier: FeedCommonTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.registerClass(FeedAttachmentsTableViewCell.self, forCellReuseIdentifier: FeedAttachmentsTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.registerClass(FeedFollowUpTableViewCell.self, forCellReuseIdentifier: FeedFollowUpTableViewCell.reuseIdentifier, cacheSize: 18)
        self.tableView.registerClass(FeedTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = self.fetchedResultsController.objectAtIndexPath(indexPath)!
        let previousPost = self.fetchedResultsController.objectAtIndexPath(indexPath.previousPath)
//
        if self.hasNextPage && self.tableView.offsetFromTop() < 200 {
            self.loadNextPageOfData()
        }
        
        return self.builder.cellForPost(post, previous: previousPost, indexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let post = self.fetchedResultsController.objectAtIndexPath(indexPath)!
        (cell as! FeedBaseTableViewCell).configureWithPost(post)
    }
//
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(FeedTableViewSectionHeader.reuseIdentifier()) as! FeedTableViewSectionHeader
        let frcTitleForHeader = self.fetchedResultsController.titleForHeaderInSection(section)
        let titleDate = NSDateFormatter.sharedConversionSectionsDateFormatter.dateFromString(frcTitleForHeader)!
        let titleString = titleDate.feedSectionDateFormat()
        view.configureWithTitle(titleString)
        view.transform = tableView.transform
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FeedTableViewSectionHeader.height()
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = self.fetchedResultsController.objectAtIndexPath(indexPath)!
        let previousPost = self.fetchedResultsController.objectAtIndexPath(indexPath.previousPath)
        return self.builder.heightForPost(post, previous: previousPost, indexPath: indexPath)
    }

    
    // MARK: - FetchedResultsController
    
    func reloadContent() {
        self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "channelId = %@ && type == ''", self.channel?.identifier ?? "")
        self.fetchedResultsController.performFetch()
    }
    
    func realmFetchedResultsController() -> FetchedResultsController<Post> {
        let predicate = NSPredicate(format: "channelId = %@ && type == ''", self.channel?.identifier ?? "")
        let realm = try! Realm()
        let fetchRequest = FetchRequest<Post>(realm: realm, predicate: predicate)
        let sortDescriptorSection = SortDescriptor(property: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptorSection]
        let fetchedResultsController = FetchedResultsController<Post>(fetchRequest: fetchRequest, sectionNameKeyPath: "creationDayString", cacheName: "testCache")
        fetchedResultsController.delegate = self.resultsControllerDelegate
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

// MARK: - Utils

extension ChatViewController {
    func clearTextView() {
        self.textView.text = nil
    }
    
    func didSelectChannelWithIdentifier(identifier: String!) -> Void {
        self.channel = try! Realm().objects(Channel).filter("identifier = %@", identifier).first!
        self.title = self.channel?.displayName
        self.fetchedResultsController = self.realmFetchedResultsController()
        self.builder.updateWithFRC(self.fetchedResultsController)
        self.tableView?.reloadData()
        self.loadFirstPageOfData()
        
    }
}


// MARK: - UI Helpers

extension ChatViewController {
    func setupRefreshControl() {
        let tableVc = UITableViewController.init() as UITableViewController
        tableVc.tableView = self.tableView
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged), forControlEvents: .ValueChanged)
        tableVc.refreshControl = self.refreshControl
    }
    
    func refreshControlValueChanged() {
        self.loadFirstPageOfData()
    }
    
    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }
}


//MARK: - Requests

extension ChatViewController {
    
    func loadFirstPageAndReload() {
        self.isLoadingInProgress = true
        Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
            self.performSelector(#selector(self.endRefreshing), withObject: nil, afterDelay: 0.05)
            self.fetchedResultsController = self.realmFetchedResultsController()
            self.tableView?.reloadData()
            self.isLoadingInProgress = false
            self.hasNextPage = true
        })
    }
    func loadFirstPageOfData() {
        self.isLoadingInProgress = true
        Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
            self.performSelector(#selector(self.endRefreshing), withObject: nil, afterDelay: 0.2)
            self.isLoadingInProgress = false
            self.hasNextPage = true
        })
    }
    
    func loadNextPageOfData() {
        guard !self.isLoadingInProgress else { return }

        self.isLoadingInProgress = true
        self.builder.weldIndexPaths.append(self.tableView.lastIndexPath())
        Api.sharedInstance.loadNextPage(self.channel!, fromPost: self.fetchedResultsController.fetchedObjects.last!) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            self.isLoadingInProgress = false
            if error != nil {
                self.builder.weldIndexPaths.removeLast()
            }
        }
    }
}

//extension ChatViewController : ChannelObserverDelegate {
//    func didSelectChannelWithIdentifier(identifier: String!) -> Void {
//        self.channel = try! Realm().objects(Channel).filter("identifier = %@", identifier).first!
//        print("\(self.channel?.displayName)")
//    }
//}

