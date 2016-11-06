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


final class ChatViewController: SLKTextViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AttachmentsModuleDelegate {

//MARK: Properties
    
    var channel : Channel!
    fileprivate var resultsObserver: FeedNotificationsObserver! = nil
    fileprivate lazy var builder: FeedCellBuilder = FeedCellBuilder(tableView: self.tableView)
    override var tableView: UITableView { return super.tableView! }
    fileprivate let completePost: CompactPostView = CompactPostView.compactPostView(ActionType.Edit)
    internal let attachmentsView = PostAttachmentsView()
    fileprivate let emptyDialogueLabel = EmptyDialogueLabel()
    fileprivate var filesAttachmentsModule: AttachmentsModule!
    fileprivate var filesPickingController: FilesPickingController!
    var refreshControl: UIRefreshControl?
    var topActivityIndicatorView: UIActivityIndicatorView?
    var loadingView: UIView?
    
    var hasNextPage: Bool = true
    var postFromSearch: Post! = nil
    var isLoadingInProgress: Bool = false
    
    func uploading(inProgress: Bool) {
        DispatchQueue.main.async { [unowned self] in
            self.rightButton.isEnabled = inProgress
        }
    }
    
    fileprivate var selectedPost: Post! = nil
    fileprivate var selectedAction: String = Constants.PostActionType.SendNew
    fileprivate var emojiResult: [String]?

}

fileprivate protocol Setup {
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
    func setupEmptyDialogueLabel()
    func setupModules()
}

fileprivate protocol Private {
    func showTopActivityIndicator()
    func hideTopActivityIndicator()
    func endRefreshing()
    func clearTextView()
}

private protocol Action {
    func leftMenuButtonAction(_ sender: AnyObject)
    func rigthMenuButtonAction(_ sender: AnyObject)
    func searchButtonAction(_ sender: AnyObject)
    func titleTapAction()
    func sendPostAction()
    func refreshControlValueChanged()
}

private protocol Navigation {
    func proceedToSearchChat()
    func proceedToProfileFor(user: User)
}

private protocol Request {
    func loadFirstPageAndReload()
    func loadFirstPageOfData(isInitial: Bool)
    func loadNextPageOfData()
    func sendPost()
}


//MARK: LifeСycle

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
        
        if (self.postFromSearch != nil) {
            changeChannelForPostFromSearch()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeSLKKeyboardObservers()
    }
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .grouped
    }
    
    func configureWithPost(post: Post) {
        self.postFromSearch = post
    }
    
    func changeChannelForPostFromSearch() {
        ChannelObserver.sharedObserver.selectedChannel = self.postFromSearch.channel
    }
}

//MARK: Setup

extension ChatViewController: Setup {
    fileprivate func initialSetup() {
        setupInputBar()
        setupTableView()
        setupRefreshControl()
        setupPostAttachmentsView()
        setupTopActivityIndicator()
        setupLongCellSelection()
        setupCompactPost()
        setupEmptyDialogueLabel()
        setupModules()
    }
    
    fileprivate func setupModules() {
        self.filesAttachmentsModule = AttachmentsModule(delegate: self, dataSource: self)
        self.filesPickingController = FilesPickingController(dataSource: self)
    }
    
    fileprivate func setupTableView() {
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
    
    fileprivate func setupInputBar() {
        setupTextView()
        setupInputViewButtons()
        setupToolbar()
    }
    
    fileprivate func setupTextView() {
        self.shouldClearTextAtRightButtonPress = false;
        self.textView.delegate = self;
        self.textView.placeholder = "Type something..."
        self.textView.layer.borderWidth = 0;
        self.textInputbar.textView.font = FontBucket.inputTextViewFont;
    }
    
    fileprivate func setupInputViewButtons() {
        let width = UIScreen.screenWidth() / 3
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = ColorBucket.blackColor
        titleLabel.isUserInteractionEnabled = true
        titleLabel.font = FontBucket.titleChannelFont
        titleLabel.textAlignment = .center
        titleLabel.text = self.channel?.displayName
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(titleTapAction))
        self.navigationItem.titleView = titleLabel
        self.navigationItem.titleView?.addGestureRecognizer(tapGestureRecognizer)
        
        self.rightButton.titleLabel!.font = FontBucket.feedSendButtonTitleFont;
        self.rightButton.setTitle("Send", for: UIControlState())
        self.rightButton.addTarget(self, action: #selector(sendPostAction), for: .touchUpInside)
        
        self.leftButton.setImage(UIImage(named: "common_attache_icon"), for: UIControlState())
        self.leftButton.tintColor = UIColor.gray
        self.leftButton.addTarget(self, action: #selector(attachmentSelection), for: .touchUpInside)
    }
    
    fileprivate func setupToolbar() {
        self.textInputbar.autoHideRightButton = false;
        self.textInputbar.isTranslucent = false;
        // TODO: Code Review: Заменить на стиль из темы
        self.textInputbar.barTintColor = UIColor.white
    }
    
    fileprivate func setupRefreshControl() {
        let tableVc = UITableViewController() as UITableViewController
        tableVc.tableView = self.tableView
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        tableVc.refreshControl = self.refreshControl
    }
    
    fileprivate func setupPostAttachmentsView() {
        self.attachmentsView.backgroundColor = UIColor.blue
        self.view.insertSubview(self.attachmentsView, belowSubview: self.textInputbar)
        self.attachmentsView.anchorView = self.textInputbar
    }
    
    fileprivate func setupTopActivityIndicator() {
        self.topActivityIndicatorView  = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.topActivityIndicatorView!.transform = self.tableView.transform;
    }
    
    fileprivate func setupLongCellSelection() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    fileprivate func setupEmptyDialogueLabel() {
        self.emptyDialogueLabel.backgroundColor = self.tableView.backgroundColor
        self.view.insertSubview(self.emptyDialogueLabel, aboveSubview: self.tableView)
    }
    
    fileprivate func setupCompactPost() {
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
    
    override func textWillUpdate() {
        super.textWillUpdate()
        
        guard self.filesPickingController.attachmentItems.count > 0 else { return }
        self.rightButton.isEnabled = !self.filesAttachmentsModule.fileUploadingInProgress
    }
}


//MARK: Private

extension ChatViewController : Private {

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
        self.filesPickingController.pick()
    }
    
    func hideTopActivityIndicator() {
        self.topActivityIndicatorView!.stopAnimating()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
 
    
    func endRefreshing() {
     //   self.emptyDialogueLabel.isHidden = (self.resultsObserver.numberOfSections() > 0)
//        self.refreshControl?.endRefreshing()
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
            self.selectedPost = post
            self.completePost.configureWithPost(self.selectedPost, action: ActionType.Reply)
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
                //self.selectedPost = post
                self.completePost.configureWithPost(self.selectedPost, action: ActionType.Edit)
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
        let state = (self.menuContainerViewController.menuState == MFSideMenuStateLeftMenuOpen) ? MFSideMenuStateClosed : MFSideMenuStateLeftMenuOpen
        self.menuContainerViewController.setMenuState(state, completion: nil)
    }
    
    @IBAction func rigthMenuButtonAction(_ sender: AnyObject) {
        let state = (self.menuContainerViewController.menuState == MFSideMenuStateRightMenuOpen) ? MFSideMenuStateClosed : MFSideMenuStateRightMenuOpen
        self.menuContainerViewController.setMenuState(state, completion: nil)
    }
    
    @IBAction func searchButtonAction(_ sender: AnyObject) {
        proceedToSearchChat()
    }
    
    func titleTapAction() {
        if (self.channel.privateType == Constants.ChannelType.DirectTypeChannel) {
            proceedToProfileFor(user: self.channel.interlocuterFromPrivateChannel())
        }
        else {
            
        }
    }
    
    func sendPostAction() {
        guard self.filesAttachmentsModule.fileUploadingInProgress else {
            let message = "Please, wait until download finishes"
            AlertManager.sharedManager.showWarningWithMessage(message: message, viewController: self)
            return
        }
        
        switch self.selectedAction {
        case Constants.PostActionType.SendReply:
            sendPostReply()
        case Constants.PostActionType.SendUpdate:
            updatePost()
        default:
            sendPost()
        }
        
        self.filesPickingController.reset()
        self.filesAttachmentsModule.reset()
    }
    
    
    func refreshControlValueChanged() {
        self.loadFirstPageOfData(isInitial: false)
        //self.perform(#selector(self.endRefreshing), with: nil, afterDelay: 0.05)
       // self.emptyDialogueLabel.isHidden = (self.resultsObserver.numberOfSections() > 0)
        
        self.refreshControl?.endRefreshing()
    }
    
    func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let indexPath = self.tableView.indexPathForRow(at: gestureRecognizer.location(in: self.tableView)) else { return }
        let post = resultsObserver?.postForIndexPath(indexPath)
        showActionSheetControllerForPost(post!)
    }
    
    func resendAction(_ post:Post) {
        PostUtils.sharedInstance.resendPost(post) { _ in }
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
    
    func proceedToProfileFor(user: User) {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateInitialViewController()
        (profile as! ProfileViewController).configureFor(user: user)
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(profile!, animated:true)
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
    func loadFirstPageOfData(isInitial: Bool) {
        print("loadFirstPageOfData")
        self.isLoadingInProgress = true
        
        if (self.loadingView == nil) && isInitial {
            var frame = UIScreen.main.bounds
            frame.origin.y = 64
            frame.size.height -= 108
            self.loadingView = UIView(frame: frame)
            self.loadingView?.backgroundColor = UIColor.white
            let avtivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            avtivityIndicatorView.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            avtivityIndicatorView.startAnimating()
            self.loadingView?.addSubview(avtivityIndicatorView)
            
            self.view.addSubview(self.loadingView!)
        }
        
        Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
        
            if self.loadingView != nil {
                self.loadingView?.removeFromSuperview()
                self.loadingView = nil
            }

            self.isLoadingInProgress = false
            self.hasNextPage = true
        })
    }
    
    func loadNextPageOfData() {
        print("loadNextPageOfData")
        guard !self.isLoadingInProgress else { return }
        
        self.isLoadingInProgress = true
        showTopActivityIndicator()
        Api.sharedInstance.loadNextPage(self.channel!, fromPost: resultsObserver.lastPost()) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            self.isLoadingInProgress = false
            self.hideTopActivityIndicator()
        
            self.resultsObserver.prepareResults()
          //  self.emptyDialogueLabel.isHidden = (self.resultsObserver.numberOfSections() > 0)

        }
    }
    
    func loadPostsBeforePost(post: Post, shortSize: Bool? = false) {
        print("loadPostsBeforePost")
        guard !self.isLoadingInProgress else { return }
        
        self.isLoadingInProgress = true
        Api.sharedInstance.loadPostsBeforePost(post: post, shortList: shortSize) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            if !self.hasNextPage {
                self.postFromSearch = nil
                return
            }
            
            self.isLoadingInProgress = false
            self.resultsObserver.prepareResults()
            self.loadPostsAfterPost(post: post, shortSize: true)
        }
    }
    
    func loadPostsAfterPost(post: Post, shortSize: Bool? = false) {
        print("loadPostsAfterPost")
        guard !self.isLoadingInProgress else { return }
        
        self.isLoadingInProgress = true
        Api.sharedInstance.loadPostsAfterPost(post: post, shortList: shortSize) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            self.isLoadingInProgress = false
            
            self.resultsObserver.unsubscribeNotifications()
            self.resultsObserver.prepareResults()
            self.resultsObserver.subscribeNotifications()
            
            let indexPath =  self.resultsObserver.indexPathForPost(post)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    func sendPost() {
        PostUtils.sharedInstance.sentPostForChannel(with: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            if (error != nil) {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message!)!, viewController: self)
            }
          //  self.emptyDialogueLabel.isHidden = true
            self.hideTopActivityIndicator()
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
        self.selectedAction = Constants.PostActionType.SendNew
        self.clearTextView()
        self.dismissKeyboard(true)
    }
    
    func updatePost() {
        guard (self.selectedPost != nil) else { return }
    
        PostUtils.sharedInstance.updateSinglePost(self.selectedPost, message: self.textView.text, attachments: nil) {_ in 
            self.selectedPost = nil
        }
        self.configureRightButtonWithTitle("Send", action: Constants.PostActionType.SendUpdate)
        self.dismissKeyboard(true)
        self.selectedAction = Constants.PostActionType.SendNew
        self.clearTextView()
    }
    
    func deletePost() {
        guard (self.selectedPost != nil) else { return }
        
        PostUtils.sharedInstance.deletePost(self.selectedPost) { (error) in
            self.selectedAction = Constants.PostActionType.SendNew
           // RealmUtils.deleteObject(self.selectedPost)
            self.selectedPost = nil
        }
    }
}


//MARK: UITableViewDataSource

extension ChatViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (tableView == self.tableView) {
            self.emptyDialogueLabel.isHidden = (self.resultsObserver.numberOfSections() > 0)
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
            
            let cell = self.builder.cellForPost(post!, errorHandler: errorHandler)
            if (cell.isKind(of: FeedCommonTableViewCell.self)) {
                (cell as! FeedCommonTableViewCell).avatarTapHandler = {
                    guard (post?.author.identifier != "SystemUserIdentifier") else { return }
                    self.proceedToProfileFor(user: (post?.author)!)
                }
            }
            
            return cell
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
        //old channel
        //unsubscribing from realm and channelActions
        if resultsObserver != nil {
            resultsObserver.unsubscribeNotifications()
        }
        self.resultsObserver = nil
        self.emptyDialogueLabel.isHidden = true
        if self.channel != nil {
            //remove action observer from old channel
            //after relogin
            NotificationCenter.default.removeObserver(self,
                                                    name: NSNotification.Name(ActionsNotification.notificationNameForChannelIdentifier(channel?.identifier)),
                                                    object: nil)
        }
        
        self.typingIndicatorView?.dismissIndicator()
        
        //new channel
        self.channel = try! Realm().objects(Channel.self).filter("identifier = %@", identifier).first!
        self.title = self.channel?.displayName
        
        if (self.navigationItem.titleView != nil) {
            (self.navigationItem.titleView as! UILabel).text = self.channel?.displayName
        }
        self.resultsObserver = FeedNotificationsObserver(tableView: self.tableView, channel: self.channel!)
        
        self.textView.resignFirstResponder()
        
        if (self.postFromSearch == nil) {
            self.loadFirstPageOfData(isInitial: true)
        }
        else {
            loadPostsBeforePost(post: self.postFromSearch, shortSize: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleChannelNotification),
                                                         name: NSNotification.Name(ActionsNotification.notificationNameForChannelIdentifier(channel?.identifier)),
                                                         object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogoutNotification),
                                                         name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserLogoutNotificationName),
                                                         object: nil)
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


//MARK: UITextViewDelegate

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

extension ChatViewController: FilesPickingControllerDataSource {
    func attachmentsModule(controller: FilesPickingController) -> AttachmentsModule {
        return self.filesAttachmentsModule
    }
}

extension ChatViewController: AttachmentsModuleDataSource {
    func tableView(attachmentsModule: AttachmentsModule) -> UITableView {
        return self.tableView
    }
    func postAttachmentsView(attachmentsModule: AttachmentsModule) -> PostAttachmentsView {
        return self.attachmentsView
    }
    func channel(attachmentsModule: AttachmentsModule) -> Channel {
        return self.channel
    }
}

//MARK: AutoCompletionView

extension ChatViewController {
    func autoCompletionCellForRowAtIndexPath(_ indexPath: IndexPath) -> EmojiTableViewCell {
        let cell = self.autoCompletionView.dequeueReusableCell(withIdentifier: EmojiTableViewCell.reuseIdentifier) as! EmojiTableViewCell
        cell.selectionStyle = .default
        
        guard let searchResult = self.emojiResult else { return cell }
        guard let prefix = self.foundPrefix else { return cell }
        
        let text = searchResult[indexPath.row]
        let originalIndex = Constants.EmojiArrays.mattermost.index(of: text)
        cell.configureWith(index: originalIndex)
        
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
