//
//  ChatViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 25.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import SlackTextViewController
import RealmSwift
import ImagePickerSheetController
import UITableView_Cache
import MFSideMenu

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
    func leftMenuButtonAction(_ sender: AnyObject)
    func rigthMenuButtonAction(_ sender: AnyObject)
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
    var tableViewBottomConstraint: NSLayoutConstraint!
    
    var hasNextPage: Bool = true
    var postFromSearch: Post! = nil
    var isLoadingInProgress: Bool = false
    
    var fileUploadingInProgress: Bool = true {
        didSet {
            self.toggleSendButtonAvailability()
        }
    }
    fileprivate var assignedPhotosArray = Array<AssignedPhotoViewItem>()
    //TODO: file array
    fileprivate var assignedFile: File?
    fileprivate var selectedPost: Post! = nil
    fileprivate var selectedAction: String = Constants.PostActionType.SendNew
    fileprivate var emojiResult: [String]?
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
    
    func configureWithPost(post: Post) {
        self.channel = try! Realm().objects(Channel.self).filter("identifier = %@", post.channel.identifier!).first!
        self.title = self.channel?.displayName
        self.postFromSearch = post
        self.resultsObserver = FeedNotificationsObserver(tableView: self.tableView, channel: self.channel!)
        
        loadPostsBeforePost(post: post)
        loadPostsAfterPost(post: post)
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
        setupInitialTableViewConstraints()
    }
    
    func setupTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.register(FeedCommonTableViewCell.self, forCellReuseIdentifier: FeedCommonTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.register(FeedAttachmentsTableViewCell.self, forCellReuseIdentifier: FeedAttachmentsTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.register(FeedFollowUpTableViewCell.self, forCellReuseIdentifier: FeedFollowUpTableViewCell.reuseIdentifier, cacheSize: 18)
        self.tableView.register(FeedTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
        self.autoCompletionView.register(EmojiTableViewCell.classForCoder(), forCellReuseIdentifier: EmojiTableViewCell.reuseIdentifier)
        self.registerPrefixes(forAutoCompletion: [":"])
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
        
        self.leftButton.setImage(UIImage(named: "common_attache_icon"), for: UIControlState())
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
    
    func updateTableViewBottomConstraint(postViewShowed: Bool) {
        let constantValue = postViewShowed ? -80 : 0
        self.tableViewBottomConstraint.constant = CGFloat(constantValue)
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }
    
    func setupInitialTableViewConstraints() {
        let top = NSLayoutConstraint(item: self.tableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        self.tableViewBottomConstraint = NSLayoutConstraint(item: self.tableView, attribute: .bottom, relatedBy: .equal, toItem: self.textView, attribute: .top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: self.tableView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self.tableView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        self.view.addConstraints([top, tableViewBottomConstraint, left, right])
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
        let controller = UIAlertController(title: "Attachment", message: "Choose what you want to attach?", preferredStyle: .actionSheet)
        let gallerySelectionAction = UIAlertAction(title: "Photo/Picture", style: .default, handler: { (action:UIAlertAction) in
            self.assignPhotos()
        })
        gallerySelectionAction.setValue(UIImage(named:"gallery_icon"), forKey: "image")
        controller.addAction(gallerySelectionAction)
        
        let fileSelectionAction = UIAlertAction(title: "File", style: .default, handler: { (action:UIAlertAction) in
            self.proceedToFileSelection()
        })
        fileSelectionAction.setValue(UIImage(named:"iCloud_icon"), forKey: "image")
        controller.addAction(fileSelectionAction)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction) in
            print("canceled")
        }))
        present(controller, animated: true) {}
    }
    
    func hideTopActivityIndicator() {
        self.topActivityIndicatorView!.stopAnimating()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
 
// TODO: Code Review: clean unused code
    
//Images
    func assignPhotos() -> Void {
        //TODO: MORE REFACTOR
        let presentImagePickerController: (UIImagePickerControllerSourceType) -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            let sourceType = source
            controller.sourceType = sourceType
            
            self.present(controller, animated: true, completion: nil)
        }
        
        let controller = ImagePickerSheetController(mediaType: .imageAndVideo)
        controller.maximumSelection = 5
        
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Send", comment: "Action Title"), handler: { _ in
            presentImagePickerController(.camera)
            }, secondaryHandler: { _, numberOfPhotos in
                let convertedAssets = AssetsUtils.convertedArrayOfAssets(controller.selectedImageAssets)
                self.assignedPhotosArray.append(contentsOf: convertedAssets)
                self.postAttachmentsView.showAnimated()
                self.updateTableViewBottomConstraint(postViewShowed: true)
                self.postAttachmentsView.updateAppearance()
                self.uploadImages()
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: NSLocalizedString("Photo Library", comment: "Action Title"), handler: { _ in
            presentImagePickerController(.photoLibrary)
            }, secondaryHandler: { _ in
                presentImagePickerController(.photoLibrary)
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .cancel, handler: { _ in
            print("Cancelled")
        }))
        
        present(controller, animated: true, completion: nil)
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
    @IBAction func leftMenuButtonAction(_ sender: AnyObject) {
        self.menuContainerViewController.setMenuState(MFSideMenuStateLeftMenuOpen, completion: nil)
    }
    
    @IBAction func rigthMenuButtonAction(_ sender: AnyObject) {
        self.menuContainerViewController.setMenuState(MFSideMenuStateRightMenuOpen, completion: nil)
    }
    
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
        self.assignedPhotosArray.removeAll()
        self.postAttachmentsView.hideAnimated()
        self.updateTableViewBottomConstraint(postViewShowed: false)
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
        let identifier = String(describing: SearchChatViewController.self)
        let searchChat = self.storyboard?.instantiateViewController(withIdentifier: identifier) as! SearchChatViewController
        searchChat.configureWithChannel(channel: self.channel!)
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
            
//            self.resultsObserver.unsubscribeNotifications()
//            self.resultsObserver.prepareResults()
//            self.resultsObserver.subscribeNotifications()
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
            
//            self.resultsObserver.unsubscribeNotifications()
//            self.resultsObserver.prepareResults()
//            self.resultsObserver.subscribeNotifications()
        }
    }
    
    func loadPostsBeforePost(post: Post, shortSize: Bool? = false) {
        guard !self.isLoadingInProgress else { return }
        
        self.isLoadingInProgress = true
        Api.sharedInstance.loadPostsBeforePost(post: post, shortList: shortSize) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            if self.hasNextPage {
                self.postFromSearch = nil
                return
            }
            
            self.isLoadingInProgress = false
            
            self.resultsObserver.unsubscribeNotifications()
            self.resultsObserver.prepareResults()
            self.resultsObserver.subscribeNotifications()
        }
    }
    
    func loadPostsAfterPost(post: Post, shortSize: Bool? = false) {
        guard !self.isLoadingInProgress else { return }
        
        self.isLoadingInProgress = true
        Api.sharedInstance.loadPostsAfterPost(post: post, shortList: shortSize) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            self.isLoadingInProgress = false
            
            self.resultsObserver.unsubscribeNotifications()
            self.resultsObserver.prepareResults()
            self.resultsObserver.subscribeNotifications()
        }
    }
    
    func sendPost() {
        PostUtils.sharedInstance.sentPostForChannel(with: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            if (error != nil) {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message!)!, viewController: self)
            }
        }
        self.dismissKeyboard(true)
        self.clearTextView()
    }
    
    func sendPostReply() {
        guard (self.selectedPost != nil) else { return }
        
        PostUtils.sharedInstance.sendReplyToPost(self.selectedPost, channel: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            if (error != nil) {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message!)!, viewController: self)
            }
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
        PostUtils.sharedInstance.uploadImages(self.channel!, images: self.assignedPhotosArray, completion: { (finished, error, item) in
            if error != nil {
                //TODO: handle error
                //refactor обработка этой ошибки в отдельную функцию
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message!)!, viewController: self)
                print("error with \(item.fileName)")
                self.assignedPhotosArray.removeObject(item)
                self.postAttachmentsView.updateAppearance()
                if (self.assignedPhotosArray.count == 0) {
                    self.postAttachmentsView.hideAnimated()
                    self.updateTableViewBottomConstraint(postViewShowed: false)
                }
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
    //refactor mechanism
    func uploadFile(from url:URL, fileItem:AssignedPhotoViewItem) {
        PostUtils.sharedInstance.uploadFiles(self.channel!,fileItem: fileItem, url: url, completion: { (finished, error) in
            if error != nil {
                //TODO: handle error
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message!)!, viewController: self)
                self.assignedPhotosArray.removeObject(fileItem)
                self.postAttachmentsView.updateAppearance()
                if (self.assignedPhotosArray.count == 0) {
                    self.postAttachmentsView.hideAnimated()
                    self.updateTableViewBottomConstraint(postViewShowed: false)
                }
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
        if (tableView == self.tableView) {
            return self.resultsObserver?.numberOfSections() ?? 1
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.tableView) {
            return self.resultsObserver?.numberOfRows(section) ?? 0
        }
        
        return (self.emojiResult != nil) ? (self.emojiResult?.count)! : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.tableView) {
            let post = resultsObserver?.postForIndexPath(indexPath)
            if self.hasNextPage && self.tableView.offsetFromTop() < 200 {
                self.loadNextPageOfData()
            }
        
            let errorHandler = { (post:Post) in
                self.errorAction(post)
            }
            return self.builder.cellForPost(post!, errorHandler: errorHandler)
        }
        else {
            return autoCompletionCellForRowAtIndexPath(indexPath)
        }
    }
}


//MARK: UITableViewDelegate

extension ChatViewController {
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard tableView == self.tableView else { return nil }
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
        return (tableView == self.tableView) ? FeedTableViewSectionHeader.height() : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView == self.tableView) {
            let post = resultsObserver?.postForIndexPath(indexPath)
            return self.builder.heightForPost(post!)
        }
        
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.autoCompletionView) {
            guard let emojiResult = self.emojiResult else { return }
            var item = emojiResult[indexPath.row]
            if (self.foundPrefix == ":") {
                item += ":"
            }
            
            item += " "
            
            self.acceptAutoCompletion(with: item, keepPrefix: true)
        }
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
        self.channel = try! Realm().objects(Channel.self).filter("identifier = %@", identifier).first!
        self.title = self.channel?.displayName
        self.resultsObserver = FeedNotificationsObserver(tableView: self.tableView, channel: self.channel!)
        self.loadFirstPageOfData()
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
            self.updateTableViewBottomConstraint(postViewShowed: false)
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
        let controller = UIAlertController(title: "Your message was not sent", message: "Tap resend to send this message again", preferredStyle: .actionSheet)
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


//MARK: UIDocumentPickerDelegate
extension ChatViewController: UIDocumentPickerDelegate {
    func proceedToFileSelection() {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated:true, completion:nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        //TODO: REFACTOR mechanism

        let fileItem = AssignedPhotoViewItem(image: UIImage(named: "attach_file_icon")!)
        fileItem.fileName = File.fileNameFromUrl(url: url)
        fileItem.isFile = true
        self.assignedPhotosArray.append(fileItem)
        self.postAttachmentsView.showAnimated()
        self.updateTableViewBottomConstraint(postViewShowed: true)
        self.postAttachmentsView.updateAppearance()
        self.uploadFile(from:url, fileItem: fileItem)
    }
}

//MARK: AutoCompletionView

extension ChatViewController {
    func autoCompletionCellForRowAtIndexPath(_ indexPath: IndexPath) -> EmojiTableViewCell {
        let cell = self.autoCompletionView.dequeueReusableCell(withIdentifier: EmojiTableViewCell.reuseIdentifier) as! EmojiTableViewCell
        cell.selectionStyle = .default
        
        guard let searchResult = self.emojiResult else { return cell }
        guard let prefix = self.foundPrefix else { return cell }
        
        var text = searchResult[indexPath.row]
     //   if (prefix == ":") {
     //       text = ":\(text):"
     //   }
        
        let originalIndex = Constants.EmojiArrays.mattermost.index(of: text)
        cell.configureWith(index: originalIndex)
        //cell.configureWith(name: text, indexPath: indexPath)
        
        return cell
    }
    
    override func shouldProcessText(forAutoCompletion text: String) -> Bool {
        return true
    }
    
    override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {
        var array:Array<String> = []
        self.emojiResult = nil
        
        if (prefix == ":") && word.characters.count > 0 {
            array = Constants.EmojiArrays.mattermost.filter { NSPredicate(format: "self BEGINSWITH[c] %@", word).evaluate(with: $0) };
        }
        
        var show = false
        if array.count > 0 {
            let sortedArray = array.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            self.emojiResult = sortedArray
            show = sortedArray.count > 0
        }
        
        self.showAutoCompletionView(show)
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        guard let smilesResult = self.emojiResult else { return 0 }
        let cellHeight = (self.autoCompletionView.delegate?.tableView!(self.autoCompletionView, heightForRowAt: IndexPath(row: 0, section: 0)))!
        
        return cellHeight * CGFloat(smilesResult.count)
    }
}
