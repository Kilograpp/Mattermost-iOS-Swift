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

private protocol Setup {
    func initialSetup()
    func setupTableView()
    func setupInputBar()
    func setupTextView()
    func setupInputViewButtons()
    func setupToolbar()
    func setupRefreshControl()
    func setupPostAttachmentsView()
    func setupTopActivityIndicator()
    func setupCompactPost()
}

private protocol Private {
    func showAttachmentsView()
    func hideAttachmentsView()
    func showTopActivityIndicator()
    func hideTopActivityIndicator()
    func assignPhotos()
    func toggleSendButtonAvailability()
    func endRefreshing()
    func clearTextView()
}

private protocol Action {
    func searchButtonAction(sender: AnyObject)
    func sendPostAction()
    func assignPhotosAction()
    func refreshControlValueChanged()
}

private protocol Navigation {
    func proceedToSearchChat()
}

private protocol FetchedResultsController {

}

private protocol Request {
    func loadFirstPageAndReload()
    func loadFirstPageOfData()
    func loadNextPageOfData()
    func sendPost()
    func uploadImages()
}


final class ChatViewController: SLKTextViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//MARK: Properties
    
    private var channel : Channel?
    private var resultsObserver: FeedNotificationsObserver?
    private lazy var builder: FeedCellBuilder = FeedCellBuilder(tableView: self.tableView)
    private var results: Results<Day>! = nil
    override var tableView: UITableView! { return super.tableView }
    private let completePost: CompactPostView = CompactPostView.compactPostView(ActionType.Edit)
    
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
}


//MARK: LifeCycle

extension ChatViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        ChannelObserver.sharedObserver.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Grouped
    }
}


//MARK: Setup

extension ChatViewController: Setup {
    func initialSetup() {
        setupInputBar()
        setupTableView()
        setupRefreshControl()
        setupPostAttachmentsView()
        setupTopActivityIndicator()
        setupLongCellSelection()
        setupCompactPost()
    }
    
    func setupTableView() {
        self.tableView.separatorStyle = .None
        self.tableView.keyboardDismissMode = .OnDrag
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.registerClass(FeedCommonTableViewCell.self, forCellReuseIdentifier: FeedCommonTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.registerClass(FeedAttachmentsTableViewCell.self, forCellReuseIdentifier: FeedAttachmentsTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.registerClass(FeedFollowUpTableViewCell.self, forCellReuseIdentifier: FeedFollowUpTableViewCell.reuseIdentifier, cacheSize: 18)
        self.tableView.registerClass(FeedTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
    }
    
    func setupInputBar() {
        setupTextView()
        setupInputViewButtons()
        setupToolbar()
    }
    
    func setupTextView() {
        self.shouldClearTextAtRightButtonPress = false;
        self.textView.delegate = self;
        self.textView.placeholder = "Type something..."
        self.textView.layer.borderWidth = 0;
        self.textInputbar.textView.font = FontBucket.inputTextViewFont;
    }
    
    func setupInputViewButtons() {
        self.rightButton.titleLabel!.font = FontBucket.feedSendButtonTitleFont;
        self.rightButton.setTitle("Send", forState: .Normal)
        self.rightButton.addTarget(self, action: #selector(sendPostAction), forControlEvents: .TouchUpInside)
        
        self.leftButton.setImage(UIImage(named: "chat_photo_icon"), forState: .Normal)
        self.leftButton.tintColor = UIColor.grayColor()
        self.leftButton.addTarget(self, action: #selector(assignPhotosAction), forControlEvents: .TouchUpInside)
    }
    
    func setupToolbar() {
        self.textInputbar.autoHideRightButton = false;
        self.textInputbar.translucent = false;
        // TODO: Code Review: Заменить на стиль из темы
        self.textInputbar.barTintColor = UIColor.whiteColor()
    }
    
    private func setupRefreshControl() {
        let tableVc = UITableViewController.init() as UITableViewController
        tableVc.tableView = self.tableView
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged), forControlEvents: .ValueChanged)
        tableVc.refreshControl = self.refreshControl
    }
    
    private func setupPostAttachmentsView() {
        self.postAttachmentsView.backgroundColor = UIColor.blueColor()
        self.view.insertSubview(self.postAttachmentsView, belowSubview: self.textInputbar)
        self.postAttachmentsView.anchorView = self.textInputbar
        
        self.postAttachmentsView.dataSource = self
        self.postAttachmentsView.delegate = self
    }
    
    func setupTopActivityIndicator() {
        self.topActivityIndicatorView  = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.topActivityIndicatorView!.transform = self.tableView.transform;
    }
    
    func setupLongCellSelection() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func setupCompactPost() {
        let size = self.completePost.requeredSize()
        self.completePost.translatesAutoresizingMaskIntoConstraints = false
//TODO: Will be uncomment 
       // self.view.addSubview(self.completePost)
        
        /*let horizontal = NSLayoutConstraint(item: self.completePost, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        view.addConstraint(horizontal)
        let vertical = NSLayoutConstraint(item: self.completePost, attribute: .Bottom, relatedBy: .Equal, toItem: self.textView, attribute: .Top, multiplier: 1, constant: 0)
        view.addConstraint(vertical)
        
        let width = NSLayoutConstraint(item: self.completePost, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: size.width)
        view.addConstraint(width)
        
        let height = NSLayoutConstraint(item: self.completePost, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: size.height)
        view.addConstraint(height)*/
    }
}


//MARK: Private

extension ChatViewController : Private {
//AttachmentsView
    func showAttachmentsView() {
        var oldInset = self.tableView.contentInset
        oldInset.top = PostAttachmentsView.attachmentsViewHeight
        self.tableView.contentInset = oldInset
    }
    
    func hideAttachmentsView() {
        var oldInset = self.tableView.contentInset
        oldInset.top = 0
        self.tableView.contentInset = oldInset
    }

//TopActivityIndicator
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
 
//Images
    func assignPhotos() -> Void {
        //TODO: MORE REFACTOR
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
                self.uploadImages()
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

//Interface
    func toggleSendButtonAvailability() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.rightButton.enabled = self.fileUploadingInProgress
        }
    }
    
    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }
    
    func clearTextView() {
        self.textView.text = nil
    }
    
    func showActionSheetControllerForPost(post: Post) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
     
        let replyAction = UIAlertAction(title: "Reply", style: .Default) { action -> Void in
           // self.sendRepyToPost(post)
            self.presentKeyboard(true)
            let size = self.completePost.requeredSize()
            self.completePost.frame = CGRectMake(0, 60, size.width, size.height)
            self.completePost.layoutIfNeeded()
            self.view.addSubview(self.completePost)
        }
        actionSheetController.addAction(replyAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelAction)
        
        if (post.author.identifier == Preferences.sharedInstance.currentUserId) {
            let editAction = UIAlertAction(title: "Edit", style: .Default) { action -> Void in
                self.presentKeyboard(true)
                
                
                
                
               // print("Edit")
                print(post.message)
                if (post.message == "zzz") {
                    /*    PostUtils.sharedInstance.update1Post(post, message: "sdds", attachments: nil, completion: { (error) in
                     print("yeaaap2")
                     if (error != nil) {
                     print(error?.message)
                     }
                     })*/
                }

            }
            actionSheetController.addAction(editAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { action -> Void in
                //print("Delete")
                PostUtils.sharedInstance.deletePost(post, completion: { (error) in
                  print("Deleted")
                })
            }
            actionSheetController.addAction(deleteAction)
        }
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }

    private func showCompletePost(post: Post, action: String) {
        
    }

}


//MARK: Action

extension ChatViewController: Action {
    @IBAction func searchButtonAction(sender: AnyObject) {
        proceedToSearchChat()
    }
    
    func sendPostAction() {
        sendPost()
    }
    
    func assignPhotosAction() {
        assignPhotos()
    }
    
    func refreshControlValueChanged() {
        self.prepareResults()
        self.loadFirstPageOfData()
    }
    
    func longPressAction(gestureRecognizer: UILongPressGestureRecognizer) {
        let indexPath = self.tableView.indexPathForRowAtPoint(gestureRecognizer.locationInView(self.tableView))
        let day = self.results[indexPath!.section]
        let post = day.posts.sorted(PostAttributes.createdAt.rawValue, ascending: false)[indexPath!.row]
        showActionSheetControllerForPost(post)
    }
}


//MARK: Navigation

extension ChatViewController: Navigation {
    func proceedToSearchChat() {
        let transaction = CATransition()
        transaction.duration = 0.3
        transaction.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transaction.type = kCATransitionMoveIn
        transaction.subtype = kCATransitionFromBottom
        self.navigationController!.view.layer.addAnimation(transaction, forKey: kCATransition)
        
        let searchChat = self.storyboard?.instantiateViewControllerWithIdentifier(String(SearchChatViewController)) as! SearchChatViewController
        self.navigationController?.pushViewController(searchChat, animated: false)
    }
}


//MARK: Requests

extension ChatViewController: Request {
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
    
    func sendPost() {
        PostUtils.sharedInstance.sentPostForChannel(with: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            self.clearTextView()
            //self.prepareResults()
            self.performSelector(#selector(self.prepareResults), withObject: nil, afterDelay: 1)
        }
    }
    
    func sendRepyToPost(post: Post) {
        PostUtils.sharedInstance.sendReplyToPost(post, channel: self.channel!, message: "test reply", attachments: nil) { (error) in
            self.prepareResults()
            self.tableView.reloadData()
            self.clearTextView()
        }
    }
    
    func uploadImages() {
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
    }
}


//MARK: UITableViewDataSource

extension ChatViewController {
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
}


//MARK: UITableViewDelegate

extension ChatViewController {
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
}


//MARK: FetchedResultsController

extension ChatViewController: FetchedResultsController {
    func prepareResults() {
        if NSThread.isMainThread() {
            fetchPosts()
        } else {
            dispatch_sync(dispatch_get_main_queue()) {
                self.fetchPosts()
            }
        }
    }
    
    func fetchPosts() {
        let predicate = NSPredicate(format: "channelId = %@", self.channel?.identifier ?? "")
        self.results = RealmUtils.realmForCurrentThread().objects(Day.self).filter(predicate).sorted("date", ascending: false)
        self.resultsObserver = FeedNotificationsObserver(results: self.results, tableView: self.tableView)
    }
}


//MARK: ChannelObserverDelegate

extension ChatViewController: ChannelObserverDelegate {
    func didSelectChannelWithIdentifier(identifier: String!) -> Void {
        self.channel = try! Realm().objects(Channel).filter("identifier = %@", identifier).first!
        self.title = self.channel?.displayName
        self.prepareResults()
        self.loadFirstPageOfData()
    }
}


//MARK: PostAttachmentViewDataSource

extension ChatViewController: PostAttachmentViewDataSource {
    func itemAtIndex(index: Int) -> AssignedPhotoViewItem {
        return self.assignedPhotosArray[index]
    }
    
    func numberOfItems() -> Int {
        return self.assignedPhotosArray.count
    }
}


//MARK: PostAttachmentViewDelegate

extension ChatViewController: PostAttachmentViewDelegate {
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