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


protocol ChatViewControllerInterface: class {
    func configureWith(postFound: Post)
    func configureWithPost(post: Post)
    func changeChannelForPostFromSearch()
}

final class ChatViewController: SLKTextViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//MARK: Properties
    //UserInterface
    override var tableView: UITableView { return super.tableView! }
    fileprivate let completePost: CompactPostView = CompactPostView.compactPostView(ActionType.Edit)
    internal let attachmentsView = PostAttachmentsView()
    fileprivate var startHeadDialogueLabel = EmptyDialogueLabel()
    fileprivate var startTextDialogueLabel = EmptyDialogueLabel()
    fileprivate let startButton = UIButton.init()
    var refreshControl: UIRefreshControl?
    var topActivityIndicatorView: UIActivityIndicatorView?
    var scrollButton: UIButton?
    //Modules
    var documentInteractionController: UIDocumentInteractionController?
    fileprivate var filesAttachmentsModule: AttachmentsModule!
    fileprivate var filesPickingController: FilesPickingController!
    fileprivate lazy var builder: FeedCellBuilder = FeedCellBuilder(tableView: self.tableView)
    fileprivate var resultsObserver: FeedNotificationsObserver! = nil
    //Common
    var channel : Channel!
    
    fileprivate var selectedPost: Post! = nil
    fileprivate var selectedAction: String = Constants.PostActionType.SendNew
    var emojiResult: [String]?
    
    //var membersResult: Array<User> = [] //USELESS FIELD COUSE 3.6
    var usersInChannelResult: Array<User> = []
    var usersOutOfChannelResult: Array<User> = []
    var commandsResult: [String] = []
    //var usersInTeam: Array<User> = [] //USELESS FIELD COUSE 3.6
    var usersInChannel: Array<User> = []
    var usersOutOfChannel: Array<User> = []
    var autoCompletionSectionIndexes = [0, 1, 2]
    var numberOfSection = 3
    
    var hasNextPage: Bool = true
    var postFromSearch: Post! = nil
    var isLoadingInProgress: Bool = false
    var isNeededAutocompletionRequest: Bool = false
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChannelObserver.sharedObserver.delegate = self
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.navigationController?.isNavigationBarHidden = false
//        setupInputViewButtons()
        addSLKKeyboardObservers()
        replaceStatusBar()
        
        if self.postFromSearch != nil {
            changeChannelForPostFromSearch()
        }
        
        self.textView.resignFirstResponder()
        addBaseObservers()
//        self.tableView.reloadData()
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
}


//MARK: ChatViewControllerInterface
extension ChatViewController: ChatViewControllerInterface {
    func configureWith(postFound: Post) {
        ChannelObserver.sharedObserver.selectedChannel = postFound.channel
        
        loadPostsAfterPost(post: postFound)
        loadPostsBeforePost(post: postFound)
    }
    
    func configureWithPost(post: Post) {
        self.postFromSearch = post
        (self.menuContainerViewController.leftMenuViewController as! LeftMenuViewController).updateSelectionFor(post.channel)
    }
    
    func changeChannelForPostFromSearch() {
        ChannelObserver.sharedObserver.selectedChannel = self.postFromSearch.channel
    }
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
    func loadNextPageOfData()
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
        setupLongCellSelection()
        setupCompactPost()
        //loadUsersFromTeam()
        setupModules()
    }
    
    fileprivate func setupModules() {
        self.filesAttachmentsModule = AttachmentsModule(delegate: self, dataSource: self)
        self.filesPickingController = FilesPickingController(dataSource: self)
    }
    
    /*func loadUsersFromTeam() {
        Api.sharedInstance.loadUsersFromCurrentTeam(completion: { (error, usersArray) in
            guard error == nil else { return }
            self.usersInTeam = usersArray!
        })
    }*/
    
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
    
    fileprivate func setupLongCellSelection() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
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
    
    fileprivate func setupScrollButton() {
        self.scrollButton = UIButton.init(type: UIButtonType.system)
        self.scrollButton?.frame = CGRect(x: UIScreen.screenWidth() - 60, y: UIScreen.screenHeight() - 100, width: 50, height: 50)
        self.scrollButton?.setBackgroundImage(UIImage(named:"chat_scroll_icon")!, for: UIControlState.normal)
        self.scrollButton?.layer.cornerRadius = (self.scrollButton?.frame.size.width)! / 2
        self.scrollButton?.addTarget(self, action: #selector(scrollToBottom), for: .touchUpInside)
        self.view.addSubview(self.scrollButton!)
        self.view.bringSubview(toFront: self.scrollButton!)
        self.scrollButton?.isHidden = true;
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
        
        let copyAction = UIAlertAction(title: "Copy", style: .default) { action -> Void in
            UIPasteboard.general.string = post.message
        }
        actionSheetController.addAction(copyAction)
        
        let permalinkAction = UIAlertAction(title: "Permalink", style: .default) { action -> Void in
            UIPasteboard.general.string = post.permalink()
        }
        actionSheetController.addAction(permalinkAction)
        
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
        guard self.filesAttachmentsModule.fileUploadingInProgress else { self.handleWarningWith(message: "Please, wait until download finishes"); return }
        
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
        self.refreshControl?.endRefreshing()
    }
    
    func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let indexPath = self.tableView.indexPathForRow(at: gestureRecognizer.location(in: self.tableView)) else { return }
        let post = resultsObserver?.postForIndexPath(indexPath)
        showActionSheetControllerForPost(post!)
    }
    
    func resendAction(_ post:Post) {
        PostUtils.sharedInstance.resend(post: post) { _ in }
    }
    
    func didTapImageAction(notification: NSNotification) {
        let postLocalId = notification.userInfo?["postLocalId"] as! String
        let fileId = notification.userInfo?["fileId"] as! String
        openPreviewWith(postLocalId: postLocalId, fileId: fileId)
    }
    
    func scrollToBottom() {
        self.tableView.setContentOffset(CGPoint(x:0, y:0), animated: true)
        self.scrollButton?.isHidden = true
    }
    
    func scrollBottomUp(keyboardHeight: CGFloat) {
        self.scrollButton?.frame.origin.y = UIScreen.screenHeight() - 100 - keyboardHeight;
    }
    
    func scrollBottomDown(keyboardHeight: CGFloat) {
        self.scrollButton?.frame.origin.y = UIScreen.screenHeight() - 100
    }
}


//MARK: Navigation
extension ChatViewController: Navigation {
    func proceedToSearchChat() {        
        let identifier = String(describing: SearchChatViewController.self)
        let searchChat = self.storyboard?.instantiateViewController(withIdentifier: identifier) as! SearchChatViewController
        searchChat.configureWithChannel(channel: self.channel)
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(searchChat, animated: false, completion: nil)
    }
    
    func proceedToProfileFor(user: User) {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateInitialViewController()
        (profile as! ProfileViewController).configureFor(user: user)
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(profile!, animated:true)
    }
    
    func proceedToChannelSettings(channel: Channel) {
        self.dismissKeyboard(true)
        self.showLoaderView()
        Api.sharedInstance.getChannel(channel: self.channel, completion: { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            Api.sharedInstance.loadUsersListFrom(channel: channel, completion: { (error) in
                guard error == nil else {
                    let channelType = (channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "group" : "channel"
                    self.handleErrorWith(message: "You left this \(channelType)".localized)
                    return
                }
                
                let channelSettingsStoryboard = UIStoryboard(name: "ChannelSettings", bundle:nil)
                let channelSettings = channelSettingsStoryboard.instantiateViewController(withIdentifier: "ChannelSettingsViewController")
                ((channelSettings as! UINavigationController).viewControllers[0] as! ChannelSettingsViewController).channel = try! Realm().objects(Channel.self).filter("identifier = %@", channel.identifier!).first!
                self.navigationController?.present(channelSettings, animated: true, completion: { _ in
                    self.hideLoaderView()
                })
            })
        })
    }
}


//MARK: Requests
extension ChatViewController: Request {
    func loadChannelUsers() {
        self.isLoadingInProgress = true
        showLoaderView()
        
        Api.sharedInstance.loadUsersListFrom(channel: ChannelObserver.sharedObserver.selectedChannel!, completion:{ (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            
            self.loadFirstPageOfData(isInitial: true)
        })
    }
    
    func loadFirstPageOfData(isInitial: Bool) {
        self.isLoadingInProgress = true
        
        self.showLoaderView()
        Api.sharedInstance.loadFirstPage(self.channel!, completion: { (error) in
            self.hideLoaderView()
            self.isLoadingInProgress = false
            self.hasNextPage = true
            self.dismissKeyboard(true)
//            self.tableView.reloadData()
        
            
            
            Api.sharedInstance.updateLastViewDateForChannel(self.channel, completion: {_ in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
            })
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
        }
    }
    
    func loadPostsBeforePost(post: Post, shortSize: Bool? = false) {
        guard !self.isLoadingInProgress else { return }
        
        self.isLoadingInProgress = true
        showTopActivityIndicator()
        Api.sharedInstance.loadPostsBeforePost(post: post) { (isLastPage, error) in
            self.hasNextPage = !isLastPage
            //if !self.hasNextPage { self.postFromSearch = nil; return }
            
            self.isLoadingInProgress = false
            self.hideTopActivityIndicator()
            //self.resultsObserver.prepareResults()
          //  self.loadPostsAfterPost(post: post, shortSize: true)
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
            
            guard post.channel.identifier == self.channel.identifier else { return }
            
            //let indexPath =  self.resultsObserver.indexPathForPost(post)
            //self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            
        }
    }
    
    func sendPost() {
        PostUtils.sharedInstance.sendPost(channel: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            if (error != nil) {
                var message = (error?.message!)!
                if error?.code == -1011{
                    let channelType = (self.channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "group" : "channel"
                    message = "You left this " + channelType
                }
                if error?.code == -1009 {
                    self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .none)
                }
                
                self.handleErrorWith(message: message)
            }
            self.hideTopActivityIndicator()
        }
        self.clearTextView()
    }
    
    func sendPostReply() {
        guard (self.selectedPost != nil) else { return }
        guard self.selectedPost.identifier != nil else { return }
        
        PostUtils.sharedInstance.reply(post: self.selectedPost, channel: self.channel!, message: self.textView.text, attachments: nil) { (error) in
            if error != nil {
                self.handleErrorWith(message: (error?.message!)!)
            }
            self.selectedPost = nil
        }
        self.selectedAction = Constants.PostActionType.SendNew
        self.clearTextView()
        self.completePost.isHidden = true
    }
    
    func updatePost() {
        guard self.selectedPost != nil else { return }
        
        guard self.selectedPost.identifier != nil else { return }
        
        PostUtils.sharedInstance.update(post: self.selectedPost, message: self.textView.text, attachments: nil) {_ in self.selectedPost = nil }
        self.configureRightButtonWithTitle("Send", action: Constants.PostActionType.SendUpdate)
        self.selectedAction = Constants.PostActionType.SendNew
        self.clearTextView()
        self.completePost.isHidden = true
    }
    
    func deletePost() {
        guard self.selectedPost != nil else { return }
        
        guard self.selectedPost.identifier != nil else {
            self.selectedAction = Constants.PostActionType.SendNew
            RealmUtils.deleteObject(self.selectedPost)
            self.selectedPost = nil
            return
        }
        
        let postIdentifier = self.selectedPost.identifier!
        PostUtils.sharedInstance.delete(post: self.selectedPost) { (error) in
            self.selectedAction = Constants.PostActionType.SendNew
            
            let comments = RealmUtils.realmForCurrentThread().objects(Post.self).filter("parentId == %@", postIdentifier)
            guard comments.count > 0 else { return }
            
            RealmUtils.deletePostObjects(comments)
            
            RealmUtils.deleteObject(self.selectedPost)
            self.selectedPost = nil
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
//        center.addObserver(self, selector: #selector(reloadChat),
//                           name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadChatNotification), object: nil)
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
        
        let isntDialogEmpty = (self.resultsObserver.numberOfSections() > 0)
        self.startTextDialogueLabel.isHidden = isntDialogEmpty
        self.startHeadDialogueLabel.isHidden = isntDialogEmpty
        self.startButton.isHidden = isntDialogEmpty
        
        return self.resultsObserver?.numberOfSections() ?? 0
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
            if self.hasNextPage && self.tableView.offsetFromTop() < 200 {
            //    self.loadNextPageOfData()
                loadPostsBeforePost(post: self.resultsObserver.lastPost())
            }
            
            /*if (Int(self.channel.messagesCount!)! > self.resultsObserver.numberOfPosts()) &&
               (self.tableView.offsetFromTop() < 200) {
                loadPostsBeforePost(post: self.resultsObserver.lastPost())
            }*/
            
            let errorHandler = { (post:Post) in
                self.errorAction(post)
            }
        
            let cell = self.builder.cellForPost(post!, prevPost: nil, errorHandler: errorHandler)
            if (cell.isKind(of: FeedCommonTableViewCell.self)) {
                (cell as! FeedCommonTableViewCell).avatarTapHandler = {
                    guard (post?.author.identifier != "SystemUserIdentifier") else { return }
                    self.proceedToProfileFor(user: (post?.author)!)
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
        if actualPosition > UIScreen.screenHeight() { self.scrollButton?.isHidden = false }
        if actualPosition < 50 { self.scrollButton?.isHidden = true }
    }
    
    func keyboardWillShow(_ notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.scrollBottomUp(keyboardHeight: keyboardHeight)
    }
    
    func keyboardWillHide(_ notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.scrollBottomDown(keyboardHeight: keyboardHeight)
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
        self.filesPickingController.attachmentItems.removeObject(items.first!)
        PostUtils.sharedInstance.removeAttachmentAtIdex(idx!)
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
        self.startTextDialogueLabel.isHidden = true
        self.startHeadDialogueLabel.isHidden = true
        self.startButton.isHidden = true
        
        if self.channel != nil {
            //remove action observer from old channel after relogin
            removeActionsObservers()
        }
        
        self.typingIndicatorView?.dismissIndicator()
        
        //new channel
        guard identifier != nil else { return }
        self.channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: identifier)
        self.title = self.channel?.displayName
        
        if (self.navigationItem.titleView != nil) {
            (self.navigationItem.titleView as! UILabel).text = self.channel?.displayName
        }
        self.resultsObserver = FeedNotificationsObserver(tableView: self.tableView, channel: self.channel!)
        self.textView.resignFirstResponder()
        
        if (self.postFromSearch == nil) {
           // self.loadFirstPageOfData(isInitial: true)
            self.loadChannelUsers()
        } else {
            if self.postFromSearch.channel.identifier != identifier {
                self.postFromSearch = nil
                //self.loadFirstPageOfData(isInitial: true)
                self.loadChannelUsers()
            } else {
               // loadPostsBeforePost(post: self.postFromSearch, shortSize: true)
            }
        }
        
        //NEEDREFACTORING
        startHeadDialogueLabel = EmptyDialogueLabel.init(channel: self.channel, type: 0)
        startTextDialogueLabel = EmptyDialogueLabel.init(channel: self.channel, type: 1)
        
        self.startTextDialogueLabel.removeFromSuperview()
        self.startHeadDialogueLabel.removeFromSuperview()
        self.startButton.removeFromSuperview()
        
        self.startHeadDialogueLabel.backgroundColor = self.tableView.backgroundColor
        self.view.insertSubview(self.startHeadDialogueLabel, aboveSubview: self.tableView)
        
        self.startTextDialogueLabel.backgroundColor = self.tableView.backgroundColor
        self.view.insertSubview(self.startTextDialogueLabel, aboveSubview: self.tableView)
        
        self.startButton.frame = CGRect(x       : 0,
                                        y       : 0,
                                        width   : UIScreen.main.bounds.size.width*0.90,
                                        height  : 30)
        self.startButton.center = CGPoint(x: UIScreen.main.bounds.size.width / 2,
                                          y: UIScreen.main.bounds.size.height / 1.65)
        
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
        //ENDREFACTORING
        
        addChannelObservers()
    }
    
    func startButtonAction(sender: UIButton!) {
        self.showLoaderView()
        Api.sharedInstance.loadUsersAreNotIn(channel: self.channel, completion: { (error, users) in
            guard (error==nil) else { self.hideLoaderView(); return }
            
            let channelSettingsStoryboard = UIStoryboard(name: "ChannelSettings", bundle:nil)
            let addMembersViewController = channelSettingsStoryboard.instantiateViewController(withIdentifier: "AddMembersViewController") as! AddMembersViewController
            addMembersViewController.channel = self.channel
            addMembersViewController.users = users!
            
            
            self.navigationController?.pushViewController(addMembersViewController, animated: true)
            self.hideLoaderView()
        })
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
    
    func errorAction(_ post: Post) {
        let controller = UIAlertController(title: "Your message was not sent", message: "Tap resend to send this message again", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Resend", style: .default, handler: { (action:UIAlertAction) in
            self.resendAction(post)
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
        self.completePost.isHidden = true
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
    func postAttachmentsView(attachmentsModule: AttachmentsModule) -> PostAttachmentsView {
        return self.attachmentsView
    }
    func channel(attachmentsModule: AttachmentsModule) -> Channel {
        return self.channel
    }
}
