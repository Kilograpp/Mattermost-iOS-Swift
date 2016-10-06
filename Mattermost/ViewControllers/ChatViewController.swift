//
//  ChatViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 25.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import SlackTextViewController
import RealmSwift
// import ImagePickerSheetController
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
    func searchButtonAction(_ sender: AnyObject)
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
    
    fileprivate var channel : Channel?
    fileprivate var resultsObserver: FeedNotificationsObserver! = nil
    fileprivate lazy var builder: FeedCellBuilder = FeedCellBuilder(tableView: self.tableView)
//    private var results: Results<Post>! = nil
//    private var days: Results<Day>! = nil
    override var tableView: UITableView! { return super.tableView }
    fileprivate let completePost: CompactPostView = CompactPostView.compactPostView(ActionType.Edit)
    fileprivate let postAttachmentsView = PostAttachmentsView()
    
    var refreshControl: UIRefreshControl?
    var topActivityIndicatorView: UIActivityIndicatorView?
    
    var hasNextPage: Bool = true
    var isLoadingInProgress: Bool = false
    
    var fileUploadingInProgress: Bool = true {
        didSet {
            self.toggleSendButtonAvailability()
        }
    }
    fileprivate var assignedPhotosArray = Array<AssignedPhotoViewItem>()
    fileprivate var selectedPost: Post! = nil
    fileprivate var selectedAction: String = Constants.PostActionType.SendNew
}


//MARK: LifeCycle

extension ChatViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChannelObserver.sharedObserver.delegate = self
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        addSLKKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeSLKKeyboardObservers()
    }
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .grouped
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
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.register(FeedCommonTableViewCell.self, forCellReuseIdentifier: FeedCommonTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.register(FeedAttachmentsTableViewCell.self, forCellReuseIdentifier: FeedAttachmentsTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.register(FeedFollowUpTableViewCell.self, forCellReuseIdentifier: FeedFollowUpTableViewCell.reuseIdentifier, cacheSize: 18)
        self.tableView.register(FeedTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
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
        self.rightButton.setTitle("Send", for: UIControlState())
        self.rightButton.addTarget(self, action: #selector(sendPostAction), for: .touchUpInside)
        
        self.leftButton.setImage(UIImage(named: "chat_photo_icon"), for: UIControlState())
        self.leftButton.tintColor = UIColor.gray
        self.leftButton.addTarget(self, action: #selector(attachmentSelection), for: .touchUpInside)
    }
    
    func setupToolbar() {
        self.textInputbar.autoHideRightButton = false;
        self.textInputbar.isTranslucent = false;
        // TODO: Code Review: Заменить на стиль из темы
        self.textInputbar.barTintColor = UIColor.white
    }
    
    fileprivate func setupRefreshControl() {
        let tableVc = UITableViewController.init() as UITableViewController
        tableVc.tableView = self.tableView
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        tableVc.refreshControl = self.refreshControl
    }
    
    fileprivate func setupPostAttachmentsView() {
        self.postAttachmentsView.backgroundColor = UIColor.blue
        self.view.insertSubview(self.postAttachmentsView, belowSubview: self.textInputbar)
        self.postAttachmentsView.anchorView = self.textInputbar
        
        self.postAttachmentsView.dataSource = self
        self.postAttachmentsView.delegate = self
    }
    
    func setupTopActivityIndicator() {
        self.topActivityIndicatorView  = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.topActivityIndicatorView!.transform = self.tableView.transform;
    }
    
    func setupLongCellSelection() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func setupCompactPost() {
        let size = self.completePost.requeredSize()
        self.completePost.translatesAutoresizingMaskIntoConstraints = false
        self.completePost.isHidden = true
        self.completePost.cancelHandler = {
            self.selectedPost = nil
            self.clearTextView()
            self.dismissKeyboard(true)
            self.completePost.isHidden = true
            self.configureRightButtonWithTitle("Send", action: Constants.PostActionType.SendNew)
        }
        
        self.view.addSubview(self.completePost)
        
        let horizontal = NSLayoutConstraint(item: self.completePost, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontal)
        let vertical = NSLayoutConstraint(item: self.completePost, attribute: .bottom, relatedBy: .equal, toItem: self.textView, attribute: .top, multiplier: 1, constant: 0)
        view.addConstraint(vertical)
        
        let width = NSLayoutConstraint(item: self.completePost, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.width)
        view.addConstraint(width)
        
        let height = NSLayoutConstraint(item: self.completePost, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.height)
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
        let activityIndicatorHeight = self.topActivityIndicatorView!.bounds.height
        let tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: activityIndicatorHeight * 2))
        self.topActivityIndicatorView!.center = CGPoint(x: tableFooterView.center.x, y: tableFooterView.center.y - activityIndicatorHeight / 5)
        tableFooterView.addSubview(self.topActivityIndicatorView!)
        self.tableView.tableFooterView = tableFooterView;
        self.topActivityIndicatorView!.startAnimating()
    }
    
    func attachmentSelection() {
        let controller = UIAlertController(title: "Attachment", message: "Choose what u want to attach", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Photo", style: .default, handler: { (action:UIAlertAction) in
            self.assignPhotos()
        }))
        controller.addAction(UIAlertAction(title: "File", style: .default, handler: { (action:UIAlertAction) in
//            let path = NSBundle.mainBundle().resourcePath!
//            let fileManager = NSFileManager()
            self.proceedToFileSelection()
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction) in
            print("canceled")
        }))
        present(controller, animated: true) {}
    }
    
    func hideTopActivityIndicator() {
        self.topActivityIndicatorView!.stopAnimating()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
 
//Images
    func assignPhotos() -> Void {
        /*
        //TODO: MORE REFACTOR
        let presentImagePickerController: (UIImagePickerControllerSourceType) -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            let sourceType = source
            controller.sourceType = sourceType
            
            self.present(controller, animated: true, completion: nil)
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
 */
    }

//Interface
    func toggleSendButtonAvailability() {
        DispatchQueue.main.async { [unowned self] in
            self.rightButton.isEnabled = self.fileUploadingInProgress
        }
    }
    
    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }
    
    func clearTextView() {
        self.textView.text = nil
    }
    
    func configureRightButtonWithTitle(_ title: String, action: String) {
            self.rightButton.setTitle(title, for: UIControlState())
            self.selectedAction = action
    }
    
    func showActionSheetControllerForPost(_ post: Post) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.selectedPost = post
        
        let replyAction = UIAlertAction(title: "Reply", style: .default) { action -> Void in
            self.completePost.configureWithPost(post, action: ActionType.Reply)
            self.configureRightButtonWithTitle("Send", action: Constants.PostActionType.SendReply)
            self.completePost.isHidden = false
            self.presentKeyboard(true)
        }
        actionSheetController.addAction(replyAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.selectedPost = nil
        }
        actionSheetController.addAction(cancelAction)
        
        if (post.author.identifier == Preferences.sharedInstance.currentUserId) {
            let editAction = UIAlertAction(title: "Edit", style: .default) { action -> Void in
                self.selectedPost = post
                self.completePost.configureWithPost(post, action: ActionType.Edit)
                self.completePost.isHidden = false
                self.configureRightButtonWithTitle("Save", action: Constants.PostActionType.SendUpdate)
                self.presentKeyboard(true)
                self.textView.text = self.selectedPost.message
            }
            actionSheetController.addAction(editAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action -> Void in
                self.selectedAction = Constants.PostActionType.DeleteOwn
                self.deletePost()
            }
            actionSheetController.addAction(deleteAction)
        }
        
        self.present(actionSheetController, animated: true, completion: nil)
    }

    fileprivate func showCompletePost(_ post: Post, action: String) {
        
    }

}


//MARK: Action

extension ChatViewController: Action {
    @IBAction func searchButtonAction(_ sender: AnyObject) {
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
    
    func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let indexPath = self.tableView.indexPathForRow(at: gestureRecognizer.location(in: self.tableView)) else { return }
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
        self.navigationController!.view.layer.add(transaction, forKey: kCATransition)
        
        let searchChat = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchChatViewController())) as! SearchChatViewController
        self.navigationController?.pushViewController(searchChat, animated: false)
    }
}


//MARK: Requests

extension ChatViewController: Request {
    func loadFirstPageAndReload() {
        self.isLoadingInProgress = true
        Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
            self.perform(#selector(self.endRefreshing), with: nil, afterDelay: 0.05)
            self.isLoadingInProgress = false
            self.hasNextPage = true
        })
    }
    func loadFirstPageOfData() {
        self.isLoadingInProgress = true
        Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
            self.perform(#selector(self.endRefreshing), with: nil, afterDelay: 0.05)
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
            self.dismissKeyboard(true)
            self.selectedAction = Constants.PostActionType.SendNew
//            self.configureRightButtonWithTitle("Send", action: Constants.PostActionType.SendUpdate)
        })
        
        self.clearTextView()
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.resultsObserver?.numberOfSections() ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultsObserver?.numberOfRows(section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard resultsObserver != nil else { return UIView() }
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: FeedTableViewSectionHeader.reuseIdentifier()) as? FeedTableViewSectionHeader
        if view == nil {
            view = FeedTableViewSectionHeader(reuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
        }
        let frcTitleForHeader = resultsObserver.titleForHeader(section)
        let titleDate = DateFormatter.sharedConversionSectionsDateFormatter?.date(from: frcTitleForHeader)!
        let titleString = titleDate?.feedSectionDateFormat()
        view!.configureWithTitle(titleString!)
        view!.transform = tableView.transform
        
        return view!
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FeedTableViewSectionHeader.height()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = resultsObserver?.postForIndexPath(indexPath)
        return self.builder.heightForPost(post!)
    }
}

//MARK: ChannelObserverDelegate

extension ChatViewController: ChannelObserverDelegate {

    func didSelectChannelWithIdentifier(_ identifier: String!) -> Void {
        //unsubscribing from realm and channelActionNotifications
        if resultsObserver != nil {
            resultsObserver.unsubscribeNotifications()
        }
        self.resultsObserver = nil
        if self.channel != nil {
            //remove action observer from old channel
            //after relogin
            NotificationCenter.default.removeObserver(self,
                                                                name: NSNotification.Name(ActionsNotification.notificationNameForChannelIdentifier(channel?.identifier)),
                                                                object: nil)
        }
        self.channel = try! Realm().objects(Channel).filter("identifier = %@", identifier).first!
        self.title = self.channel?.displayName
        self.resultsObserver = FeedNotificationsObserver(tableView: self.tableView, channel: self.channel!)
        self.loadFirstPageOfData()
        let notificationName = NSNotification.Name(rawValue: ActionsNotification.notificationNameForChannelIdentifier(channel?.identifier))
        NotificationCenter.default.addObserver(self, selector: #selector(handleChannelNotification),
                                                         name: NSNotification.Name(ActionsNotification.notificationNameForChannelIdentifier(channel?.identifier)),
                                                         object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogoutNotification),
                                                         name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserLogoutNotificationName),
                                                         object: nil)
    }
}


//MARK: PostAttachmentViewDataSource

extension ChatViewController: PostAttachmentViewDataSource {
    func itemAtIndex(_ index: Int) -> AssignedPhotoViewItem {
        return self.assignedPhotosArray[index]
    }
    
    func numberOfItems() -> Int {
        return self.assignedPhotosArray.count
    }
}


//MARK: PostAttachmentViewDelegate

extension ChatViewController: PostAttachmentViewDelegate {
    func didRemovePhoto(_ photo: AssignedPhotoViewItem) {
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
    func handleChannelNotification(_ notification: Notification) {
        if let actionNotification = notification.object as? ActionsNotification {
            let user = User.self.objectById(actionNotification.userIdentifier)
            switch (actionNotification.event!) {
            case .Typing:
                //refactor (to methods)
                if (actionNotification.userIdentifier != Preferences.sharedInstance.currentUserId) {
                    typingIndicatorView?.insertUsername(user?.displayName)
                }
            default:
                typingIndicatorView?.removeUsername(user?.displayName)
            }
        }
    }
    
    func handleLogoutNotification() {
        self.channel = nil
        self.resultsObserver = nil
        ChannelObserver.sharedObserver.delegate = nil
    }
    
    func errorAction(_ post: Post) {
        let controller = UIAlertController(title: "Error on sending post", message: "What to do?", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Resend", style: .default, handler: { (action:UIAlertAction) in
            self.resendAction(post)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            print("Cancelled")
            }))
        present(controller, animated: true) {}
    }
}
//MARK: - Action {
extension ChatViewController {
    func resendAction(_ post:Post) {
        PostUtils.sharedInstance.resendPost(post) { _ in }

    }
}

//MARK: - UITextViewDelegate
extension ChatViewController {
    func addSLKKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardWillHideeNotification), name: NSNotification.Name.SLKKeyboardWillHide, object: nil)
    }
    
    func removeSLKKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.SLKKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardWillHideeNotification() {
        self.completePost.isHidden = true
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        SocketManager.sharedInstance.sendNotificationAboutAction(.Typing, channel: channel!)
    }
}


extension ChatViewController: UIDocumentPickerDelegate {
    func proceedToFileSelection() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .open)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated:true, completion:nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url is : \(url)")
    }
}
