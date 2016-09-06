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
import ImagePickerSheetController
import UITableView_Cache

private protocol Private : class {
    func setupPostAttachmentsView()
    func showAttachmentsView()
    func hideAttachmentsView()
}

final class ChatViewController: SLKTextViewController, ChannelObserverDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var channel : Channel?
    private var resultsObserver: FeedNotificationsObserver?
    private lazy var builder: FeedCellBuilder = FeedCellBuilder(tableView: self.tableView)
    private var results: Results<Day>! = nil
    override var tableView: UITableView! { return super.tableView }
    
    var refreshControl: UIRefreshControl?
    var topActivityIndicatorView: UIActivityIndicatorView?
    
    var hasNextPage: Bool = true
    var isLoadingInProgress: Bool = false
    
    var fileUploadingInProgress: Bool = true {
        didSet {
            self.toggleSendButtonAvailability()
        }
    }
    
    private let postAttachmentsView = PostAttachmentsView()
    private var assignedPhotosArray = Array<AssignedPhotoViewItem>()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//FIXME: вызов методов не должен быть через self
        self.configureInputBar()
        self.configureTableView()
        self.setupRefreshControl()
        setupPostAttachmentsView()
        setupTopActivityIndicator()
        
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
        return self.results?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results[section].posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let day = self.results[indexPath.section]
        let post = day.posts.sorted(PostAttributes.createdAt.rawValue, ascending: false)[indexPath.row]

        if self.hasNextPage && self.tableView.offsetFromTop() < 200 {
            self.loadNextPageOfData()
        }

        return self.builder.cellForPost(post)
    }
    
//    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        let post = self.results[indexPath.section].posts[indexPath.row]
//        (cell as! FeedBaseTableViewCell).configureWithPost(post)
//    }
//
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(FeedTableViewSectionHeader.reuseIdentifier()) as! FeedTableViewSectionHeader
        let frcTitleForHeader = self.results[section].text!
        let titleDate = NSDateFormatter.sharedConversionSectionsDateFormatter.dateFromString(frcTitleForHeader)!
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
        let day = self.results[indexPath.section]
        let post = day.posts.sorted(PostAttributes.createdAt.rawValue, ascending: false)[indexPath.row]
        return self.builder.heightForPost(post)
    }

    
    // MARK: - FetchedResultsController
    
    
    private func prepareResults() {
        if NSThread.isMainThread() {
            let predicate = NSPredicate(format: "channelId = %@", self.channel?.identifier ?? "")
            self.results = RealmUtils.realmForCurrentThread().objects(Day.self).filter(predicate).sorted("date", ascending: false)
            self.resultsObserver = FeedNotificationsObserver(results: self.results, tableView: self.tableView)

        } else {
            dispatch_sync(dispatch_get_main_queue()) {
                let predicate = NSPredicate(format: "channelId = %@", self.channel?.identifier ?? "")
                self.results = RealmUtils.realmForCurrentThread().objects(Day.self).filter(predicate).sorted("date", ascending: false)
                self.resultsObserver = FeedNotificationsObserver(results: self.results, tableView: self.tableView)
            }
        }
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
        
        self.leftButton.setImage(UIImage(named: "chat_photo_icon"), forState: .Normal)
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
        //TODO: REFACTOR
        let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            let sourceType = source
            controller.sourceType = sourceType
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
        let controller = ImagePickerSheetController(mediaType: .ImageAndVideo)
        controller.maximumSelection = 5

        controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Send", comment: "Action Title"), handler: { _ in
            presentImagePickerController(.Camera)
            }, secondaryHandler: { _, numberOfPhotos in
                let convertedAssets = AssetsUtils.convertedArrayOfAssets(controller.selectedImageAssets)
                self.assignedPhotosArray.appendContentsOf(convertedAssets)
                self.postAttachmentsView.showAnimated()
                self.postAttachmentsView.updateAppearance()
                PostUtils.sharedInstance.uploadImages(self.channel!, images: self.assignedPhotosArray, completion: { (finished, error) in
                    if error != nil {
                        //TODO: handle error
                    } else {
                        self.fileUploadingInProgress = finished
                    }
                    }) { (value, index) in
                        self.assignedPhotosArray[index].uploaded = value == 1
                        self.assignedPhotosArray[index].uploading = value < 1
                        self.assignedPhotosArray[index].uploadProgress = value
                        self.postAttachmentsView.updateProgressValueAtIndex(index, value: value)
                }
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: NSLocalizedString("Photo Library", comment: "Action Title"), handler: { _ in
            presentImagePickerController(.PhotoLibrary)
            }, secondaryHandler: { _ in
                presentImagePickerController(.PhotoLibrary)
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
            print("Cancelled")
        }))
        
        presentViewController(controller, animated: true, completion: nil)
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
        self.prepareResults()
        self.loadFirstPageOfData()
    }
}


// MARK: - UI Helpers

extension ChatViewController {
    private func setupRefreshControl() {
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
    
    func toggleSendButtonAvailability() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.rightButton.enabled = self.fileUploadingInProgress
        }
    }
}


//MARK: - Requests

extension ChatViewController {
    
    func loadFirstPageAndReload() {
        self.isLoadingInProgress = true
        Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
            self.performSelector(#selector(self.endRefreshing), withObject: nil, afterDelay: 0.05)
            self.isLoadingInProgress = false
            self.hasNextPage = true
        })
    }
    func loadFirstPageOfData() {
        self.isLoadingInProgress = true
        Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
            self.performSelector(#selector(self.endRefreshing), withObject: nil, afterDelay: 0.05)
            self.isLoadingInProgress = false
            self.hasNextPage = true
            
        })
    }
    
    func loadNextPageOfData() {
        guard !self.isLoadingInProgress else { return }

        self.isLoadingInProgress = true
        showTopActivityIndicator()
        Api.sharedInstance.loadNextPage(self.channel!, fromPost: self.results.last!.posts.sorted(PostAttributes.createdAt.rawValue, ascending: false).last!) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            self.isLoadingInProgress = false
            self.hideTopActivityIndicator()
        }
    }
}

extension ChatViewController : Private {
    private func setupPostAttachmentsView() {
        self.postAttachmentsView.backgroundColor = UIColor.blueColor()
        self.view.insertSubview(self.postAttachmentsView, belowSubview: self.textInputbar)
        self.postAttachmentsView.anchorView = self.textInputbar
        
        self.postAttachmentsView.dataSource = self
        self.postAttachmentsView.delegate = self
    }
    
    private func showAttachmentsView() {
        var oldInset = self.tableView.contentInset
        oldInset.top = PostAttachmentsView.attachmentsViewHeight
        self.tableView.contentInset = oldInset
    }
    
    private func hideAttachmentsView() {
        var oldInset = self.tableView.contentInset
        oldInset.top = 0
        self.tableView.contentInset = oldInset
    }
}

extension ChatViewController : PostAttachmentViewDataSource {
    func itemAtIndex(index: Int) -> AssignedPhotoViewItem {
        return self.assignedPhotosArray[index]
    }
    
    func numberOfItems() -> Int {
        return self.assignedPhotosArray.count
    }
}

extension ChatViewController : PostAttachmentViewDelegate {
    func didRemovePhoto(photo: AssignedPhotoViewItem) {
        PostUtils.sharedInstance.cancelImageItemUploading(photo)
        self.assignedPhotosArray.removeObject(photo)
        
        guard self.assignedPhotosArray.count != 0 else {
            self.postAttachmentsView.hideAnimated()
            return
        }
    }
    
    func attachmentsViewWillAppear() {
        var oldInset = self.tableView.contentInset
        oldInset.bottom = PostAttachmentsView.attachmentsViewHeight
        self.tableView.contentInset = oldInset
    }
    
    func attachmentViewWillDisappear() {
        var oldInset = self.tableView.contentInset
        oldInset.top = 0
        self.tableView.contentInset = oldInset
    }
}
//
//extension ChatViewController : UIImagePickerControllerDelegate {
//    
//}

//MARK: - ActivityIndicator

extension ChatViewController {
    
    func setupTopActivityIndicator() {
        self.topActivityIndicatorView  = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.topActivityIndicatorView!.transform = self.tableView.transform;
    }
    
    func showTopActivityIndicator() {
        let activityIndicatorHeight = CGRectGetHeight(self.topActivityIndicatorView!.bounds)
        let tableFooterView = UIView(frame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), activityIndicatorHeight * 2))
        self.topActivityIndicatorView!.center = CGPointMake(tableFooterView.center.x, tableFooterView.center.y - activityIndicatorHeight / 5)
        tableFooterView.addSubview(self.topActivityIndicatorView!)
        self.tableView.tableFooterView = tableFooterView;
        self.topActivityIndicatorView!.startAnimating()
    }
    
    func hideTopActivityIndicator() {
        self.topActivityIndicatorView!.stopAnimating()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
}