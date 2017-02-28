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
import NVActivityIndicatorView


protocol ChatViewControllerInterface: class {
    func loadPostsBeforeSelectedPostFromSearch(post: Post)
    func updateChannelTitle()
}

final class ChatViewController: SLKTextViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //UserInterface
    override var tableView: UITableView { return super.tableView! }
    internal let attachmentsView = PostAttachmentsView()
    fileprivate var startHeadDialogueLabel = EmptyDialogueLabel()
    fileprivate var startTextDialogueLabel = EmptyDialogueLabel()
    fileprivate let startButton = UIButton()
    fileprivate var refreshControl: UIRefreshControl?
    fileprivate var topActivityIndicatorView: UIActivityIndicatorView?
    fileprivate var bottomActivityIndicatorView: UIActivityIndicatorView?
    fileprivate var scrollButton: UIButton?
    //Modules
    var documentInteractionController: UIDocumentInteractionController?
    fileprivate var filesAttachmentsModule: AttachmentsModule!
    fileprivate var filesPickingController: FilesPickingController!
    fileprivate lazy var builder: FeedCellBuilder = FeedCellBuilder(tableView: self.tableView)
    var resultsObserver: FeedNotificationsObserver! = nil
    //Common
    var channel : Channel!
    
    fileprivate var selectedPost: Post! = nil
    fileprivate var selectedIndexPath: IndexPath! = nil
    fileprivate var selectedAction: String = Constants.PostActionType.SendNew
    var emojiResult: [String]?
    
    var usersInChannelResult: Array<User> = []
    var usersOutOfChannelResult: Array<User> = []
    var commandsResult: [String] = []
    var usersInChannel: Array<User> = []
    var usersOutOfChannel: Array<User> = []
    //REVIEW: enum for sections
    var autoCompletionSectionIndexes = [0, 1, 2]
    var numberOfSection = 3
    
    var hasNextPage: Bool = true
    var hasNewestPage: Bool = false
    var isLoadingInProgress: Bool = false
    var isNeededAutocompletionRequest: Bool = false
    var isNeededInitialLoader: Bool = false
    fileprivate var keyboardIsActive: Bool = false
    
    fileprivate let navigationTitleView = ConversationTitleView(frame: CGRect(x: 15, y: 0, width: UIScreen.screenWidth() * 0.75 - 20, height: 44))
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChannelObserver.sharedObserver.delegate = self
        initialSetup()
    }

    override func viewDidDisappear(_ animated: Bool) {
        saveSentPostForChannel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentTeamPredicate = NSPredicate(format: "team == %@", DataManager.sharedInstance.currentTeam!)
        let realm = RealmUtils.realmForCurrentThread()
        guard realm.objects(Channel.self).filter(currentTeamPredicate).count > 0 else {
            //REVIEW: localize
            self.handleErrorWith(message: "Error when choosing team.\nPlease rechoose team")
            self.textView.isEditable = false
            return
        }
        addSLKKeyboardObservers()
        
        if self.isNeededInitialLoader {
            hideLoaderView()
            //showLoaderView(topOffset: -20.0, bottomOffset: 45.0)
            self.showFullscreenLoaderView()
            self.isNeededInitialLoader = false
        }
        
        self.textView.resignFirstResponder()
        addBaseObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replaceStatusBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIStatusBar.shared().reset()
        removeSLKKeyboardObservers()
        removeDocumentInteractionObservers()
        
        self.resignFirstResponder()
    }
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .grouped
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var center = self.scrollButton?.center
        center?.y = (self.typingIndicatorView?.frame.origin.y)! - 50
        self.scrollButton?.center = center!
        self.scrollButton?.isHidden = self.keyboardIsActive || self.tableView.contentOffset.y <= UIScreen.screenHeight()
    }
    
    override func didCommitTextEditing(_ sender: Any) {
        self.sendPostAction()
        self.hideSelectedStateFromCell()
        super.didCancelTextEditing(sender)
        super.didCommitTextEditing(sender)
    }
    
    override func didCancelTextEditing(_ sender: Any) {
        self.hideSelectedStateFromCell()
        self.configureSendAction(Constants.PostActionType.SendNew)
        super.didCancelTextEditing(sender)
    }
}


//MARK: ChatViewControllerInterface
extension ChatViewController: ChatViewControllerInterface {
    func loadPostsBeforeSelectedPostFromSearch(post: Post) {
        RealmUtils.clearChannelWith(channelId: post.channelId!, exept: post)
        self.hasNewestPage = true
        ChannelObserver.sharedObserver.selectedChannel = post.channel
        loadPostsBeforePost(post: post, needScroll: true)
    }
    
    func updateChannelTitle() {
        self.navigationTitleView.configureWithChannel(channel: self.channel)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
    }
}

fileprivate protocol UnsentPostConfigure {
    func saveSentPostForChannel()
    func configureWithSentPost()
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
    func setupBottomActivityIndicator()
    func setupModules()
    //func loadUsersFromTeam()
}

fileprivate protocol Private {
    func showTopActivityIndicator()
    func hideTopActivityIndicator()
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
    func proceedToChannelSettings(channel: Channel)
}

private protocol Request {
    func loadChannelUsers()
    func loadFirstPageOfData(isInitial: Bool)
//func loadNextPageOfData()
    func sendPost()
}

fileprivate protocol NotificationObserver: class {
    func addBaseObservers()
    func addChannelObservers()
    func addSLKKeyboardObservers()
    func removeSLKKeyboardObservers()
    func removeActionsObservers()
    func removeDocumentInteractionObservers()
}


//MARK: Setup
extension ChatViewController: Setup {
    fileprivate func initialSetup() {
        setupInputBar()
        setupScrollButton()
        setupTableView()
        setupRefreshControl()
        setupPostAttachmentsView()
        setupTopActivityIndicator()
        setupBottomActivityIndicator()
        setupLongCellSelection()
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
        self.tableView.register(FeedCommonTableViewCell.self, forCellReuseIdentifier: FeedCommonTableViewCell.reuseIdentifier, cacheSize: 15)
        self.tableView.register(FeedAttachmentsTableViewCell.self, forCellReuseIdentifier: FeedAttachmentsTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.register(FeedFollowUpTableViewCell.self, forCellReuseIdentifier: FeedFollowUpTableViewCell.reuseIdentifier, cacheSize: 18)
        self.tableView.register(FeedTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
        setupTableViewForAutocompletion()
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
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(titleTapAction))
        
        self.navigationItem.titleView = navigationTitleView
        if self.channel != nil {
            navigationTitleView.configureWithChannel(channel: self.channel)
        }
        
       
//        self.navigationItem.titleView?.addGestureRecognizer(tapGestureRecognizer)
        
        
        
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
        self.textInputbar.barTintColor = ColorBucket.whiteColor
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
    
    fileprivate func setupBottomActivityIndicator() {
        self.bottomActivityIndicatorView  = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.bottomActivityIndicatorView!.transform = self.tableView.transform;
    }
    
    fileprivate func setupLongCellSelection() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    fileprivate func setupScrollButton() {
        self.scrollButton = UIButton.init(type: UIButtonType.system)
        self.scrollButton?.frame = CGRect(x: UIScreen.screenWidth() - 60, y: UIScreen.screenHeight() - 100, width: 50, height: 50)
        self.scrollButton?.setBackgroundImage(UIImage(named:"chat_scroll_icon")!, for: UIControlState.normal)
        self.scrollButton?.layer.cornerRadius = (self.scrollButton?.frame.size.width)! / 2
        self.scrollButton?.addTarget(self, action: #selector(scrollToBottom), for: .touchUpInside)
        self.view.addSubview(self.scrollButton!)
        self.view.bringSubview(toFront: self.scrollButton!)
        self.scrollButton?.isHidden = true
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
    
    func showBottomActivityIndicator() {
        let activityIndicatorHeight = self.topActivityIndicatorView!.bounds.height
        let y = self.tableView.bounds.height - activityIndicatorHeight * 2
        let tableHeaderView = UIView(frame:CGRect(x: 0, y: y, width: self.tableView.bounds.width, height: activityIndicatorHeight * 2))
        self.topActivityIndicatorView!.center = CGPoint(x: tableHeaderView.center.x, y: tableHeaderView.center.y - activityIndicatorHeight / 5)
        tableHeaderView.addSubview(self.bottomActivityIndicatorView!)
        self.tableView.tableHeaderView = tableHeaderView;
        self.bottomActivityIndicatorView!.startAnimating()
    }
    
    func attachmentSelection() {
        self.filesPickingController.pick()
    }
    
    func hideTopActivityIndicator() {
        self.topActivityIndicatorView!.stopAnimating()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func hideBottomActivityIndicator() {
        self.bottomActivityIndicatorView!.stopAnimating()
        self.tableView.tableHeaderView = UIView(frame: CGRect.zero)
    }
    
    func clearTextView() {
        self.textView.text = nil
    }
    
    func configureSendAction(_ action: String) {
        self.selectedAction = action
    }
    
    func showActionSheetControllerForPost(_ post: Post) {
        
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.selectedPost = post
        
        let replyAction = UIAlertAction(title: "Reply", style: .default) { action -> Void in
            self.configureSendAction(Constants.PostActionType.SendReply)
            self.textInputbar.editorTitle.text = "Reply message"
            self.textInputbar.beginTextEditing()
            self.presentKeyboard(true)
        }
        actionSheetController.addAction(replyAction)
        
        let copyAction = UIAlertAction(title: "Copy".localized, style: .default) { action -> Void in
            UIPasteboard.general.string = post.message
            AlertManager.sharedManager.showTextCopyMessage()
            self.hideSelectedStateFromCell()
        }
        actionSheetController.addAction(copyAction)
        
        let permalinkAction = UIAlertAction(title: "Permalink".localized, style: .default) { action -> Void in
            UIPasteboard.general.string = post.permalink()
            AlertManager.sharedManager.showLinkCopyMessage()
            self.hideSelectedStateFromCell()
        }
        actionSheetController.addAction(permalinkAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { action -> Void in
            self.selectedPost = nil
            self.hideSelectedStateFromCell()
        }
        actionSheetController.addAction(cancelAction)
        
        if (post.author.identifier == Preferences.sharedInstance.currentUserId) {
            let editAction = UIAlertAction(title: "Edit", style: .default) { action -> Void in
                self.configureSendAction(Constants.PostActionType.SendUpdate)
                self.textView.text = self.selectedPost.message
                self.textInputbar.editorTitle.text = "Edit message"
                self.textInputbar.editorRightButton.titleLabel?.text = "Save"
                (self.tableView.cellForRow(at: self.selectedIndexPath) as! FeedBaseTableViewCell).configureForSelectedState(action: self.selectedAction)
                self.textInputbar.beginTextEditing()
                self.presentKeyboard(true)
            }
            actionSheetController.addAction(editAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action -> Void in
                self.selectedAction = Constants.PostActionType.DeleteOwn
                self.deletePost()
                self.hideSelectedStateFromCell()
            }
            actionSheetController.addAction(deleteAction)
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

//MARK: UnsentPostConfigure
extension ChatViewController: UnsentPostConfigure {
    func saveSentPostForChannel() {
        if self.channel != nil {
            guard !self.channel.isInvalidated else { return }
            
            let realm = RealmUtils.realmForCurrentThread()
            try! realm.write {
                self.channel.unsentPost = self.textView.text
            }
        }
    }
    func configureWithSentPost() {
        self.textView.text = self.channel.unsentPost
    }
}

//MARK: Action
extension ChatViewController: Action {
    @IBAction func leftMenuButtonAction(_ sender: AnyObject) {
        // tempGallery()
        let state = (self.menuContainerViewController.menuState == MFSideMenuStateLeftMenuOpen) ? MFSideMenuStateClosed : MFSideMenuStateLeftMenuOpen
        self.menuContainerViewController.setMenuState(state, completion: nil)
        self.dismissKeyboard(true)
    }
    
    @IBAction func rigthMenuButtonAction(_ sender: AnyObject) {
        let state = (self.menuContainerViewController.menuState == MFSideMenuStateRightMenuOpen) ? MFSideMenuStateClosed : MFSideMenuStateRightMenuOpen
        self.menuContainerViewController.setMenuState(state, completion: nil)
    }
    
    @IBAction func searchButtonAction(_ sender: AnyObject) {
        proceedToSearchChat()
    }
    
    func titleTapAction() {
        guard Api.sharedInstance.isNetworkReachable() else { self.handleErrorWith(message: "No Internet connectivity detected"); return }
        
        if (self.channel.privateType == Constants.ChannelType.DirectTypeChannel) {
            proceedToProfileFor(user: self.channel.interlocuterFromPrivateChannel())
        } else {
            proceedToChannelSettings(channel: self.channel)
        }
    }
    
    func sendPostAction() {
        guard self.filesAttachmentsModule.fileUploadingInProgress else { self.handleWarningWith(message: "Please, wait until download finished"); return }
        
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
        scrollToBottom(animated: true)
    }
    
    
    func refreshControlValueChanged() {
        if self.channel.identifier!.characters.count > 4 {
            self.loadFirstPageOfData(isInitial: false)
        }
        self.refreshControl?.endRefreshing()
    }
    
    func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard (self.selectedIndexPath == nil) else { return }
        guard let indexPath = self.tableView.indexPathForRow(at: gestureRecognizer.location(in: self.tableView)) else { return }
        let cell = (tableView.cellForRow(at: indexPath) as! FeedBaseTableViewCell)
            cell.configureForSelectedState(action: self.selectedAction)
        
            
        let post = resultsObserver?.postForIndexPath(indexPath)
        self.selectedIndexPath = indexPath
        showActionSheetControllerForPost(post!)
    }
    
    func resendAction(_ post:Post) {
        PostUtils.sharedInstance.resend(post: post) { _ in }
    }
    
    func deleteAction(_ post:Post) {
        PostUtils.sharedInstance.delete(post: post) {
            _ in
            //TEMP RELOAD
            self.tableView.reloadData()
        }
    }
    
    func didTapImageAction(notification: NSNotification) {
        let postLocalId = notification.userInfo?["postLocalId"] as! String
        let fileId = notification.userInfo?["fileId"] as! String
        openPreviewWith(postLocalId: postLocalId, fileId: fileId)
    }
    

    func scrollToBottom(animated: Bool = false) {
        if filesAttachmentsModule.isPresented {
            self.tableView.setContentOffset(CGPoint.init(x: 0.0, y: -80.0), animated: animated)
        } else {
            self.tableView.setContentOffset(CGPoint.zero, animated: animated)
        }
        self.scrollButton?.isHidden = true
    }
    
    func scrollToBottomWithoutReloading() {
        let datasource = self.tableView.dataSource
        self.tableView.dataSource = nil
        self.scrollToBottom()
        self.tableView.dataSource = datasource
    }
    
    func scrollButtonUp(keyboardHeight: CGFloat) {
        if filesAttachmentsModule.isPresented {
            self.scrollButton?.frame.origin.y = UIScreen.screenHeight() - 170 - keyboardHeight - self.textView.frame.height
        } else {
            self.scrollButton?.frame.origin.y = UIScreen.screenHeight() - 100 - keyboardHeight
        }
    }
    
    func scrollButtonDown(keyboardHeight: CGFloat) {
        if filesAttachmentsModule.isPresented {
            DispatchQueue.main.async {
                self.scrollButton?.frame.origin.y = self.textInputbar.isEditing ? UIScreen.screenHeight() - 200 - self.textView.frame.height : UIScreen.screenHeight() - 170 - self.textView.frame.height
            }
        } else {
            self.scrollButton?.frame.origin.y = UIScreen.screenHeight() - 100
        }
    }
}


//MARK: Navigation
extension ChatViewController: Navigation {
    func proceedToSearchChat() {
        guard (self.channel.identifier!.characters.count > 4) else { return }

        let currentTeamPredicate = NSPredicate(format: "team == %@", DataManager.sharedInstance.currentTeam!)
        let realm = RealmUtils.realmForCurrentThread()
        guard realm.objects(Channel.self).filter(currentTeamPredicate).count > 0 else {
            self.handleErrorWith(message: "Error when choosing team.\nPlease rechoose team")
            return
        }
        
        let identifier = String(describing: SearchChatViewController.self)
        let searchChat = self.storyboard?.instantiateViewController(withIdentifier: identifier) as! SearchChatViewController
        searchChat.configureWithChannel(channel: self.channel)
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        self.present(searchChat, animated: true, completion: nil)
    }
    
    func proceedToProfileFor(user: User) {
        guard (self.channel.identifier!.characters.count > 4) else { return }
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateInitialViewController()
        (profile as! ProfileViewController).configureFor(user: user)
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(profile!, animated:true)
    }
    
    func proceedToChannelSettings(channel: Channel) {
        
        guard (self.channel.identifier!.characters.count > 4) else { return }

        self.dismissKeyboard(true)
        
        let currentTeamPredicate = NSPredicate(format: "team == %@", DataManager.sharedInstance.currentTeam!)
        let realm = RealmUtils.realmForCurrentThread()
        guard realm.objects(Channel.self).filter(currentTeamPredicate).count > 0 else {
            self.handleErrorWith(message: "Error when choosing team.\nPlease rechoose team")
            return
        }
        
                    
        let channelSettingsStoryboard = UIStoryboard(name: "ChannelSettings", bundle:nil)
        let channelSettingsNavigationController = channelSettingsStoryboard.instantiateViewController(withIdentifier: "ChannelSettingsViewController") as! UINavigationController
        let channelSettingsViewController = channelSettingsNavigationController.topViewController as! ChannelSettingsViewController
        channelSettingsViewController.channel = try! Realm().objects(Channel.self).filter("identifier = %@", channel.identifier!).first!

        self.navigationController?.present(channelSettingsNavigationController, animated: true, completion: { _ in
        })
    }
}


//MARK: Requests
extension ChatViewController: Request {
    func loadChannelUsers() {
        self.isLoadingInProgress = true
        showLoaderView(topOffset: 64.0, bottomOffset: 45.0)
        Api.sharedInstance.loadUsersListFrom(channel: ChannelObserver.sharedObserver.selectedChannel!, completion:{ (error) in
            guard error == nil else {
                self.handleErrorWith(message: error!.message)
                if ChannelObserver.sharedObserver.selectedChannel!.lastPost() != nil {
                    self.resultsObserver = FeedNotificationsObserver(tableView: self.tableView, channel: ChannelObserver.sharedObserver.selectedChannel!)
                } else {
                    self.tableView.reloadData()
                }
                return
            }
            
            self.loadFirstPageOfData(isInitial: true)
        })
    }
    
    func loadFirstPageOfData(isInitial: Bool) {
        self.isLoadingInProgress = true
        
        let currentTeamPredicate = NSPredicate(format: "team == %@", DataManager.sharedInstance.currentTeam!)
        let realm = RealmUtils.realmForCurrentThread()
        guard realm.objects(Channel.self).filter(currentTeamPredicate).count > 0 else {
            self.handleErrorWith(message: "Error when choosing team.\nPlease rechoose team")
            return
        }
        
        if isInitial {  self.showLoaderView(topOffset: 64.0, bottomOffset: 45.0) }
        Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
            
            if isInitial {
                self.resultsObserver = FeedNotificationsObserver(tableView: self.tableView, channel: self.channel!)
            }
            if error == nil && self.resultsObserver == nil {
                self.resultsObserver = FeedNotificationsObserver(tableView: self.tableView, channel: self.channel!)
            }
            self.hideLoaderView()
            self.isLoadingInProgress = false
            self.hasNextPage = true
            self.hasNewestPage = false
            self.dismissKeyboard(true)
            
            Api.sharedInstance.updateLastViewDateForChannel(self.channel, completion: {_ in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
            })
        })
    }
    
    func loadPostsBeforePost(post: Post, needScroll: Bool? = false) {
        guard !self.isLoadingInProgress else { return }
        
        self.isLoadingInProgress = true
        showTopActivityIndicator()
        Api.sharedInstance.loadPostsBeforePost(post: post) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            self.isLoadingInProgress = false
            if isLastPage {
                self.hideTopActivityIndicator()
            }
            if needScroll! {
                let indexPath = self.resultsObserver.indexPathForPost(post)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                (self.tableView.cellForRow(at: indexPath) as! FeedBaseTableViewCell).highlightBackground()
            }
        }
    }
    
    func loadPostsAfterPost(post: Post, shortSize: Bool? = false) {
        guard !self.isLoadingInProgress else { return }
        
        self.isLoadingInProgress = true
        showBottomActivityIndicator()
        Api.sharedInstance.loadPostsAfterPost(post: post) { (isLastPage, error) in
            self.hasNewestPage = !isLastPage
            self.isLoadingInProgress = false
            
            self.hideBottomActivityIndicator()
        }
    }
    
    func sendPost() {
        PostUtils.sharedInstance.sendPost(channel: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            if (error != nil) {
                var message = (error?.message!)!
                if error?.code == -1011{
                    switch self.channel.privateType! {
                    case Constants.ChannelType.PrivateTypeChannel:
                        message = "You are not in this group at server"
                    case Constants.ChannelType.PublicTypeChannel:
                        message = "You are not in this channel at server"
                    case Constants.ChannelType.DirectTypeChannel:
                        message = "Direct with this user is not active at server"
                    default:
                        break
                    }
                }
                //REVIEW: hardcode
                if error?.code == -1009 {
                    self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .none)
                }
                
                self.handleErrorWith(message: message)
            }
            self.hideTopActivityIndicator()
        }
        self.clearTextView()
        self.hideSelectedStateFromCell()
    }
    
    func sendPostReply() {
        guard (self.selectedPost != nil) else { return }
        guard self.selectedPost.identifier != nil else { return }
        
        PostUtils.sharedInstance.reply(post: self.selectedPost, channel: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            if error != nil {
                self.handleErrorWith(message: (error?.message!)!)
            }
            self.hideTopActivityIndicator()
            self.hideSelectedStateFromCell()
        }
        self.selectedAction = Constants.PostActionType.SendNew
        self.clearTextView()
    }
    
    func updatePost() {
        guard self.selectedPost != nil else { return }
        
        guard self.selectedPost.identifier != nil else { return }
        
        PostUtils.sharedInstance.update(post: self.selectedPost, message: self.textView.text, attachments: nil) {_ in self.selectedPost = nil }
        self.configureSendAction(Constants.PostActionType.SendUpdate)
        self.selectedAction = Constants.PostActionType.SendNew
        self.clearTextView()
        self.hideSelectedStateFromCell()
    }
    
    func deletePost() {
        guard self.selectedPost != nil else { return }
        
        guard self.selectedPost.identifier != nil else {
            let dayPrimaryKey = selectedPost.day?.key
            PostUtils.sharedInstance.deleteLocalPost(postId: selectedPost.localIdentifier!, dayId: dayPrimaryKey!)
            self.selectedAction = Constants.PostActionType.SendNew
            self.selectedPost = nil
            self.hideSelectedStateFromCell()
            //TEMP reload for delete
            //self.tableView.reloadData()
            
            return
        }
        
        let postIdentifier = self.selectedPost.identifier!
        PostUtils.sharedInstance.delete(post: self.selectedPost) { (error) in
            defer {
                self.selectedAction = Constants.PostActionType.SendNew
                self.selectedPost = nil
                self.hideSelectedStateFromCell()
            }
            
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: error!.message)
                return
            }

            let realm = RealmUtils.realmForCurrentThread()
            try! realm.write {
                let comments = realm.objects(Post.self).filter("parentId == %@", postIdentifier)
                if comments.count > 0  {
                    realm.delete(comments)
                }
            }
        }
    }
}


//MARK: NotificationObserver
extension ChatViewController: NotificationObserver {
    func addBaseObservers() {
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(presentDocumentInteractionController),
                           name: NSNotification.Name(rawValue: Constants.NotificationsNames.DocumentInteractionNotification), object: nil)
        center.addObserver(self, selector: #selector(didTapImageAction),
                           name: NSNotification.Name(rawValue: Constants.NotificationsNames.FileImageDidTapNotification), object: nil)
        center.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.SLKKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.SLKKeyboardWillHide, object: nil)
    }
    
    func addChannelObservers() {
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(handleChannelNotification),
                           name: NSNotification.Name(ActionsNotification.notificationNameForChannelIdentifier(channel?.identifier)),
                           object: nil)
        center.addObserver(self, selector: #selector(handleLogoutNotification),
                           name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserLogoutNotificationName),
                           object: nil)
        center.addObserver(self, selector: #selector(reloadTitle),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification),
                                               object: nil)
        center.addObserver(self, selector: #selector(refreshControlValueChanged),
                           name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadChatNotification),
                           object: nil)
    }
    
    func addSLKKeyboardObservers() {
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(self.handleKeyboardWillHideeNotification),
                           name: NSNotification.Name.SLKKeyboardWillHide, object: nil)
        center.addObserver(self, selector: #selector(self.handleKeyboardWillShowNotification),
                           name: NSNotification.Name.SLKKeyboardWillShow, object: nil)
    }
    
    func removeSLKKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.SLKKeyboardWillHide, object: nil)
    }
    
    func removeActionsObservers() {
        let center = NotificationCenter.default
        
        guard !channel.isInvalidated else { return }
        
        center.removeObserver(self, name: NSNotification.Name(ActionsNotification.notificationNameForChannelIdentifier(channel?.identifier)),
                              object: nil)
    }
    
    func removeDocumentInteractionObservers() {
        let center = NotificationCenter.default
        
        center.removeObserver(self, name: NSNotification.Name(Constants.NotificationsNames.DocumentInteractionNotification),
                              object: nil)
    }
}


//MARK: UITableViewDataSource
extension ChatViewController {
    
    //NewAutocomplite
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard self.resultsObserver != nil else { return 0 }
        guard tableView == self.tableView else { return numberOfSection }
        
        let isntDialogEmpty = (Int(self.channel.messagesCount!)! > 0 || self.resultsObserver.numberOfSections() > 0)
        self.startTextDialogueLabel.isHidden = isntDialogEmpty
        self.startHeadDialogueLabel.isHidden = isntDialogEmpty
        self.startButton.isHidden = isntDialogEmpty
        
        return self.resultsObserver.numberOfSections()
    }
    
    //NewAutocomplite
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView == self.tableView else {
            guard self.emojiResult == nil else {
                return  (self.emojiResult?.count)!
            }
            switch section {
            case autoCompletionSectionIndexes[0]:
                return commandsResult.count
            case autoCompletionSectionIndexes[1]:
                return usersInChannelResult.count
            case autoCompletionSectionIndexes[2]:
                return usersOutOfChannelResult.count
            default:
                break
            }
            return 0
        }
        return self.resultsObserver?.numberOfRows(section) ?? 0
    }
    
    //NewAutocomplite
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.tableView) {
            let post = resultsObserver?.postForIndexPath(indexPath)
            if (indexPath == self.tableView.lastIndexPath()) && self.hasNextPage {
                loadPostsBeforePost(post: self.resultsObserver.lastPost())
            }

            if indexPath == IndexPath(row: 0, section: 0) && self.hasNewestPage {
                loadPostsAfterPost(post: post!)
            }
            
            let errorHandler = { (post:Post) in
                self.errorAction(post)
            }
        
            let cell = self.builder.cellForPost(post!, prevPost: nil, errorHandler: errorHandler)
            if let commonCell = cell as? FeedCommonTableViewCell {
                commonCell.avatarTapHandler = {
                    guard post?.author.identifier != "SystemUserIdentifier" else { return }
                    self.proceedToProfileFor(user: post!.author)
                }
            }
            if self.selectedIndexPath != nil {
                if indexPath == self.selectedIndexPath {
                    (cell as? FeedBaseTableViewCell)?.configureForSelectedState(action: self.selectedAction)
                }
            }
            
            return cell
        } else {
            return (emojiResult != nil) ? autoCompletionEmojiCellForRowAtIndexPath(indexPath) : autoCompletionMembersCellForRowAtIndexPath(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard tableView != self.tableView else { return nil }
        switch section {
        case autoCompletionSectionIndexes[0]:
            return "Special Mentions"
        case autoCompletionSectionIndexes[1]:
            return "Channel Members"
        case autoCompletionSectionIndexes[2]:
            return "Not in Channel"
        default:
            break
        }
        return nil
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
        if (tableView == self.autoCompletionView) {return 25}
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard tableView == self.tableView else { return 40 }
        
        let post = resultsObserver?.postForIndexPath(indexPath)
        return self.builder.heightForPost(post!, prevPost: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.autoCompletionView) { didSelectAutocompleteRowAt(indexPath: indexPath) }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition = self.tableView.contentOffset.y
        if actualPosition > UIScreen.screenHeight() { self.scrollButton?.isHidden = false || self.keyboardIsActive}
        if actualPosition < 50 { self.scrollButton?.isHidden = true }
    }
    
    func keyboardWillShow(_ notification:NSNotification) {
        keyboardIsActive = true
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.installContentInsents()
        self.scrollToSelectedCell(keyboardHeight: keyboardHeight)
        self.scrollButtonUp(keyboardHeight: keyboardHeight)
    }
    
    func keyboardWillHide(_ notification:NSNotification) {
        keyboardIsActive = false
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.installContentInsents()
        self.scrollButtonDown(keyboardHeight: keyboardHeight)
    }
}


//MARK: AttachmentsModuleDelegate
extension ChatViewController: AttachmentsModuleDelegate {
    func uploading(inProgress: Bool, countItems: Int) {
        DispatchQueue.main.async { [unowned self] in
            guard countItems > 0 else { self.rightButton.isEnabled = (self.textView.text.characters.count > 0); return }
            self.rightButton.isEnabled = inProgress
        }
    }
    
    func removedFromUploading(identifier: String) {
        let items = self.filesPickingController.attachmentItems.filter { return ($0.identifier == identifier) }
        let idx = self.filesPickingController.attachmentItems.index(of: items.first!)
        guard items.count > 0 else { return }
//        self.filesPickingController.attachmentItems.removeObject(items.first!)
//        PostUtils.sharedInstance.removeAttachmentAtIdex(identifier)
    }
}


//MARK: ChannelObserverDelegate
extension ChatViewController: ChannelObserverDelegate {
    func didSelectChannelWithIdentifier(_ identifier: String!) -> Void {
//        UIStatusBar.shared().reset()
        
        //old channel
        //unsubscribing from realm and channelActions
        self.resultsObserver?.unsubscribeNotifications()
        self.resultsObserver = nil
        self.startTextDialogueLabel.isHidden = true
        self.startHeadDialogueLabel.isHidden = true
        self.startButton.isHidden = true
        self.selectedIndexPath = nil
        self.keyboardIsActive = false
        
        self.scrollToBottomWithoutReloading()
        
        if self.channel != nil {
            //remove action observer from old channel after relogin
            saveSentPostForChannel()
            removeActionsObservers()
        }
        
        self.typingIndicatorView?.dismissIndicator()
        
        //new channel
        guard identifier != nil else { return }
        self.channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: identifier)
        
        navigationTitleView.configureWithChannel(channel: channel)
        
        self.textView.resignFirstResponder()
        
        guard !self.hasNewestPage else { return }
        
        self.loadChannelUsers()
        
        //NEEDREFACTORING
        startHeadDialogueLabel = EmptyDialogueLabel(channel: self.channel, type: 0)
        startTextDialogueLabel = EmptyDialogueLabel(channel: self.channel, type: 1)
        
        self.startTextDialogueLabel.removeFromSuperview()
        self.startHeadDialogueLabel.removeFromSuperview()
        self.startButton.removeFromSuperview()
        
        self.startHeadDialogueLabel.backgroundColor = self.tableView.backgroundColor
        self.view.insertSubview(self.startHeadDialogueLabel, aboveSubview: self.tableView)
        
        self.startTextDialogueLabel.backgroundColor = self.tableView.backgroundColor
        self.view.insertSubview(self.startTextDialogueLabel, aboveSubview: self.tableView)
        
        self.startButton.frame = CGRect(x       : 0,
                                        y       : 0,
                                        width   : UIScreen.main.bounds.size.width * 0.9,
                                        height  : 30)
        self.startButton.center = CGPoint(x: UIScreen.screenWidth() / 2,
                                          y: UIScreen.screenHeight() / 1.5)
        
        if (channel.privateType == "P") {
            self.startButton.setTitle("+ Invite others to this private group",for: .normal)
        } else {
            self.startButton.setTitle("+ Invite others to this channel",for: .normal)
        }
        
        self.startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
        self.startButton.setTitleColor(UIColor.kg_blueColor(), for: .normal)
        self.startButton.contentHorizontalAlignment = .left
        if (channel.privateType != "D") {
            self.view.insertSubview(self.startButton, aboveSubview: self.tableView)
        }
        
        installContentInsents()
        //ENDREFACTORING
        
        //update with UnsentPost
        self.configureSendAction(Constants.PostActionType.SendNew)
        self.textInputbar.endTextEdition()
        configureWithSentPost()
        addChannelObservers()
        
        guard let _ = filesAttachmentsModule else {return}
        //self.filesPickingController.reset()
      //  self.filesAttachmentsModule.reset()
      //  PostUtils.sharedInstance.clearUploadedAttachments()
        
        if filesAttachmentsModule.cache.hasCachedItemsForChannel(channel) {
            let files = filesAttachmentsModule.cache.cachedFilesForChannel(channel)
            PostUtils.sharedInstance.updateCached(files: files!)
            filesAttachmentsModule.presentWithCachedItems()
        } else {
            attachmentsView.hideAnimated()
        }
    }
    
    func startButtonAction(sender: UIButton!) {
        guard Api.sharedInstance.isNetworkReachable() else { self.handleErrorWith(message: "No Internet connectivity detected"); return }
        self.showLoaderView(topOffset: 64.0, bottomOffset: 45.0)
        Api.sharedInstance.loadUsersAreNotIn(channel: self.channel, completion: { (error, users) in
            guard (error==nil) else { self.hideLoaderView()
                AlertManager.sharedManager.showErrorWithMessage(message: error!.message)
                return
            }
            
            let channelSettingsStoryboard = UIStoryboard(name: "ChannelSettings", bundle:nil)
            let addMembersViewController = channelSettingsStoryboard.instantiateViewController(withIdentifier: "AddMembersViewController") as! AddMembersViewController
            addMembersViewController.channel = self.channel
            addMembersViewController.users = users!
            
            
            self.navigationController?.pushViewController(addMembersViewController, animated: true)
            self.hideLoaderView()
        })
    }
    
    func installContentInsents() {
        DispatchQueue.main.async {
            
            //Change TableView contentInsents if atachmentView is active
            if (self.attachmentsView.isShown) {
                var oldInset = self.tableView.contentInset
                //oldInset.bottom = PostAttachmentsView.attachmentsViewHeight
                oldInset.top = PostAttachmentsView.attachmentsViewHeight
                self.tableView.contentInset = oldInset
                self.tableView.scrollIndicatorInsets = oldInset
                self.scrollButtonDown(keyboardHeight: 0.0)
            }
        }
    }
}
//MARK: Handlers
extension ChatViewController {
    func handleChannelNotification(_ notification: Notification) {
        if let actionNotification = notification.object as? ActionsNotification {
            let user = User.self.objectById(actionNotification.userIdentifier)
            switch (actionNotification.event!) {
            case .Typing:
                if (actionNotification.userIdentifier != Preferences.sharedInstance.currentUserId) {
                    typingIndicatorView?.insertUsername(user?.username)
                }
            default:
                typingIndicatorView?.removeUsername(user?.username)
            }
        }
    }
    
    func handleLogoutNotification() {
        self.channel = nil
        self.resultsObserver = nil
        ChannelObserver.sharedObserver.delegate = nil
    }
    
    func reloadTitle() {
        guard let channel = self.channel, !channel.isInvalidated else { return }

        navigationTitleView.configureWithChannel(channel: channel)
    }
    
    func errorAction(_ post: Post) {
        let controller = UIAlertController(title: "Your message was not sent", message: "Tap resend to send this message again", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Resend", style: .default, handler: { [unowned self](action:UIAlertAction) in
            self.resendAction(post)
        }))
        
        controller.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action:UIAlertAction) in
            self.deleteAction(post)
        }))
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true) {}
    }
    
    func reloadChat(notification: NSNotification) {
        guard notification.userInfo?["postLocalId"] != nil else { return }
        
        let postLocalId = notification.userInfo?["postLocalId"] as! String
        let post = RealmUtils.realmForCurrentThread().object(ofType: Post.self, forPrimaryKey: postLocalId)
        
        guard post != nil else { return }
        guard !(post?.isInvalidated)! else { return }
        guard self.resultsObserver != nil else { return }
        guard self.channel.identifier == post?.channel.identifier else { return }
        let indexPath = self.resultsObserver.indexPathForPost(post!)
        
        guard (self.tableView.indexPathsForVisibleRows?.contains(indexPath))! else { return }
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
}


//MARK: UITextViewDelegate
extension ChatViewController {
    func handleKeyboardWillShowNotification() {
    }
    
    func handleKeyboardWillHideeNotification() {
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.rightButton.isEnabled =  self.textView.text != "" || self.filesPickingController.attachmentItems.count > 0
        }
        
        SocketManager.sharedInstance.sendNotificationAboutAction(.Typing, channel: channel!)
    }
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        rightButton.isEnabled =  textView.text != "" || filesPickingController.attachmentItems.count > 0
        guard Api.sharedInstance.isNetworkReachable() else {
            isNeededAutocompletionRequest = false
            return true
        }
        guard !textView.text.contains("@") && text=="@" else {
            isNeededAutocompletionRequest = false
            return true
        }
        isNeededAutocompletionRequest = true
        return true
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
    func scrollButton(attachmentsModule: AttachmentsModule) -> UIButton {
        return self.scrollButton!
    }
    func postAttachmentsView(attachmentsModule: AttachmentsModule) -> PostAttachmentsView {
        return self.attachmentsView
    }
    func channel(attachmentsModule: AttachmentsModule) -> Channel {
        return self.channel
    }
}

//MARK: loader override
extension ChatViewController {
    override func showLoaderView(topOffset: CGFloat, bottomOffset: CGFloat) {
        
        //stopActions
        self.leftButton.isEnabled = false
        self.textView.isEditable = false
        self.rightButton.isEnabled = false
        
        super.showLoaderView(topOffset: topOffset, bottomOffset: bottomOffset)
    }
    
    override func hideLoaderView(){
        super.hideLoaderView()
        
        //startActions
        self.leftButton.isEnabled = true
        self.textView.isEditable = true
        self.rightButton.isEnabled = self.textView.text != "" || self.filesPickingController.attachmentItems.count > 0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(titleTapAction))
        self.navigationItem.titleView?.addGestureRecognizer(tapGestureRecognizer)
    }
}

//MARK: hide selected state from selected cell
extension ChatViewController {
    func hideSelectedStateFromCell() {
        guard (self.selectedIndexPath != nil) else { return }
        if let cell = self.tableView.cellForRow(at: self.selectedIndexPath) {
            (cell as! FeedBaseTableViewCell).configureForNoSelectedState()
        }
        self.selectedIndexPath = nil
    }
    
    func scrollToSelectedCell(keyboardHeight: CGFloat) {
        if (self.selectedIndexPath != nil) {
            self.tableView.scrollToRow(at: self.selectedIndexPath, at: .top, animated: true)
            if self.tableView.rectForRow(at: self.selectedIndexPath).height > (self.tableView.frame.height - keyboardHeight) {
                self.tableView.contentOffset.y = self.tableView.contentOffset.y + self.tableView.rectForRow(at: self.selectedIndexPath).height - (self.tableView.frame.height - (UIScreen.screenHeight() - keyboardHeight))
            }
        }
    }
}
