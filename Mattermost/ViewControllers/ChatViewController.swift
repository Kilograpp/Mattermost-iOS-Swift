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
    private var resultsObserver: FeedNotificationsObserver! = nil
    private lazy var builder: FeedCellBuilder = FeedCellBuilder(tableView: self.tableView)
//    private var results: Results<Post>! = nil
//    private var days: Results<Day>! = nil
    override var tableView: UITableView! { return super.tableView }
    private let completePost: CompactPostView = CompactPostView.compactPostView(ActionType.Edit)
    private let postAttachmentsView = PostAttachmentsView()
    
    var refreshControl: UIRefreshControl?
    var topActivityIndicatorView: UIActivityIndicatorView?
    
    var hasNextPage: Bool = true
    var isLoadingInProgress: Bool = false
    
    var fileUploadingInProgress: Bool = true {
        didSet {
            self.toggleSendButtonAvailability()
        }
    }
    private var assignedPhotosArray = Array<AssignedPhotoViewItem>()
    private var selectedPost: Post! = nil
    private var selectedAction: String = Constants.PostActionType.SendNew
}


//MARK: LifeCycle

extension ChatViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChannelObserver.sharedObserver.delegate = self
        initialSetup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        addSLKKeyboardObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeSLKKeyboardObservers()
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
        self.completePost.hidden = true
        self.completePost.cancelHandler = {
            self.selectedPost = nil
            self.clearTextView()
            self.dismissKeyboard(true)
            self.completePost.hidden = true
            self.configureRightButtonWithTitle("Send", action: Constants.PostActionType.SendNew)
        }
        
        self.view.addSubview(self.completePost)
        
        let horizontal = NSLayoutConstraint(item: self.completePost, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        view.addConstraint(horizontal)
        let vertical = NSLayoutConstraint(item: self.completePost, attribute: .Bottom, relatedBy: .Equal, toItem: self.textView, attribute: .Top, multiplier: 1, constant: 0)
        view.addConstraint(vertical)
        
        let width = NSLayoutConstraint(item: self.completePost, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: size.width)
        view.addConstraint(width)
        
        let height = NSLayoutConstraint(item: self.completePost, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: size.height)
        view.addConstraint(height)
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
    
    func configureRightButtonWithTitle(title: String, action: String) {
            self.rightButton.setTitle(title, forState: .Normal)
            self.selectedAction = action
    }
    
    func showActionSheetControllerForPost(post: Post) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        self.selectedPost = post
        
        let replyAction = UIAlertAction(title: "Reply", style: .Default) { action -> Void in
            self.completePost.configureWithPost(post, action: ActionType.Reply)
            self.configureRightButtonWithTitle("Send", action: Constants.PostActionType.SendReply)
            self.completePost.hidden = false
            self.presentKeyboard(true)
            
        }
        actionSheetController.addAction(replyAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            self.selectedPost = nil
        }
        actionSheetController.addAction(cancelAction)
        
        if (post.author.identifier == Preferences.sharedInstance.currentUserId) {
            let editAction = UIAlertAction(title: "Edit", style: .Default) { action -> Void in
                self.selectedPost = post
                self.completePost.configureWithPost(post, action: ActionType.Edit)
                self.completePost.hidden = false
                self.configureRightButtonWithTitle("Save", action: Constants.PostActionType.SendUpdate)
                self.presentKeyboard(true)
            }
            actionSheetController.addAction(editAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { action -> Void in
                self.selectedAction = Constants.PostActionType.DeleteOwn
                self.deletePost()
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
        switch self.selectedAction {
        case Constants.PostActionType.SendReply:
            sendPostReply()
        case Constants.PostActionType.SendUpdate:
            updatePost()
        default:
            sendPost()
        }
    }
    
    func assignPhotosAction() {
        assignPhotos()
    }
    
    func refreshControlValueChanged() {
        self.loadFirstPageOfData()
    }
    
    func longPressAction(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let indexPath = self.tableView.indexPathForRowAtPoint(gestureRecognizer.locationInView(self.tableView)) else { return }
        let post = resultsObserver?.postForIndexPath(indexPath)
        showActionSheetControllerForPost(post!)
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
            
            self.resultsObserver.unsubscribeNotifications()
            self.resultsObserver.prepareResults()
            self.resultsObserver.subscribeNotifications()
        })
    }
    
    func loadNextPageOfData() {
        guard !self.isLoadingInProgress else { return }
        
        self.isLoadingInProgress = true
        showTopActivityIndicator()
        Api.sharedInstance.loadNextPage(self.channel!, fromPost: resultsObserver.lastPost()) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            self.isLoadingInProgress = false
            self.hideTopActivityIndicator()
            
            self.resultsObserver.unsubscribeNotifications()
            self.resultsObserver.prepareResults()
            self.resultsObserver.subscribeNotifications()
        }
    }
    
    func sendPost() {
        PostUtils.sharedInstance.sentPostForChannel(with: self.channel!, message: self.textView.text, attachments: nil) { (error) in
        }
        self.dismissKeyboard(true)
        self.clearTextView()
    }
    
    func sendPostReply() {
        guard (self.selectedPost != nil) else { return }
        
        PostUtils.sharedInstance.sendReplyToPost(self.selectedPost, channel: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            self.selectedPost = nil
        }
        self.clearTextView()
        self.dismissKeyboard(true)
    }
    
    func updatePost() {
        guard (self.selectedPost != nil) else { return }
        
        PostUtils.sharedInstance.updateSinglePost(self.selectedPost, message: self.textView.text, attachments: nil, completion: { (error) in
            self.selectedPost = nil
            self.clearTextView()
            self.tableView.reloadData()
            self.dismissKeyboard(true)
            self.configureRightButtonWithTitle("Send", action: Constants.PostActionType.SendUpdate)
        })
    }
    
    func deletePost() {
        guard (self.selectedPost != nil) else { return }
        
        PostUtils.sharedInstance.deletePost(self.selectedPost) { (error) in
            self.selectedAction = Constants.PostActionType.SendNew
            RealmUtils.deleteObject(self.selectedPost)
            self.selectedPost = nil
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
        return self.resultsObserver?.numberOfSections() ?? 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultsObserver?.numberOfRows(section) ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = resultsObserver?.postForIndexPath(indexPath)
        if self.hasNextPage && self.tableView.offsetFromTop() < 200 {
            self.loadNextPageOfData()
        }
        
        let errorHandler = { (post:Post) in
            self.errorAction(post)
        }
        
        return self.builder.cellForPost(post!, errorHandler: errorHandler)
    }
}


//MARK: UITableViewDelegate

extension ChatViewController {
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard resultsObserver != nil else { return UIView() }
        var view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(FeedTableViewSectionHeader.reuseIdentifier()) as? FeedTableViewSectionHeader
        if view == nil {
            view = FeedTableViewSectionHeader(reuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
        }
        let frcTitleForHeader = resultsObserver.titleForHeader(section)
        let titleDate = NSDateFormatter.sharedConversionSectionsDateFormatter.dateFromString(frcTitleForHeader)!
        let titleString = titleDate.feedSectionDateFormat()
        view!.configureWithTitle(titleString)
        view!.transform = tableView.transform
        
        return view!
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FeedTableViewSectionHeader.height()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = resultsObserver?.postForIndexPath(indexPath)
        return self.builder.heightForPost(post!)
    }
}

//MARK: ChannelObserverDelegate

extension ChatViewController: ChannelObserverDelegate {

    func didSelectChannelWithIdentifier(identifier: String!) -> Void {
        //unsubscribing from realm and channelActionNotifications
        if resultsObserver != nil {
            resultsObserver.unsubscribeNotifications()
        }
        self.resultsObserver = nil
        if self.channel != nil {
            //remove action observer from old channel
            //after relogin
            NSNotificationCenter.defaultCenter().removeObserver(self,
                                                                name: ActionsNotification.notificationNameForChannelIdentifier(channel?.identifier),
                                                                object: nil)
        }
        self.channel = try! Realm().objects(Channel).filter("identifier = %@", identifier).first!
        self.title = self.channel?.displayName
        self.resultsObserver = FeedNotificationsObserver(tableView: self.tableView, channel: self.channel!)
        self.loadFirstPageOfData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleChannelNotification),
                                                         name: ActionsNotification.notificationNameForChannelIdentifier(channel?.identifier),
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleLogoutNotification),
                                                         name: Constants.NotificationsNames.UserLogoutNotificationName,
                                                         object: nil)
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


//MARK: Handlers
extension ChatViewController {
    func handleChannelNotification(notification: NSNotification) {
        if let actionNotification = notification.object as? ActionsNotification {
            let user = User.self.objectById(actionNotification.userIdentifier)
            switch (actionNotification.event!) {
            case .Typing:
                //refactor (to methods)
                if (actionNotification.userIdentifier != Preferences.sharedInstance.currentUserId) {
                    typingIndicatorView?.insertUsername(user?.displayName)
                }
            default:
                //how to handle this?
                typingIndicatorView?.removeUsername(user?.displayName)
            }
        }
    }
    
    func handleLogoutNotification() {
        self.channel = nil
        self.resultsObserver = nil
        ChannelObserver.sharedObserver.delegate = nil
    }
    
    func errorAction(post: Post) {
        let controller = UIAlertController(title: "Error on sending post", message: "What to do?", preferredStyle: .ActionSheet)
        controller.addAction(UIAlertAction(title: "Resend", style: .Default, handler: { (action:UIAlertAction) in
            self.resendAction(post)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
            print("Cancelled")
            }))
        presentViewController(controller, animated: true) {}
    }
}
//MARK: - Action {
extension ChatViewController {
    func resendAction(post:Post) {
        PostUtils.sharedInstance.resendPost(post) { (error) in
            self.clearTextView()
        }

    }
}

//MARK: - UITextViewDelegate
extension ChatViewController {
    func addSLKKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleKeyboardWillHideeNotification), name: SLKKeyboardWillHideNotification, object: nil)
    }
    
    func removeSLKKeyboardObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SLKKeyboardWillHideNotification, object: nil)
    }
    
    func handleKeyboardWillHideeNotification() {
        self.completePost.hidden = true
    }
    
    override func textViewDidChange(textView: UITextView) {
        SocketManager.sharedInstance.sendNotificationAboutAction(.Typing, channel: channel!)
    }
}
