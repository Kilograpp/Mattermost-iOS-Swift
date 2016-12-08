//
//  SearchChatViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 12.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import RealmSwift

struct SearchStage {
    static let SearchNotStarted: Int       = 0
    static let SearchRequstInProgress: Int = 1
    static let SearchResultsDisplay: Int   = 2
    static let SearchNoResults: Int        = 3
}


protocol SearchChatViewControllerConfiguration: class {
    func configureWithChannel(channel: Channel)
}


class SearchChatViewController: UIViewController {
    
//MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var loadingEmozziView: UIView!
    @IBOutlet weak var autocompleteTableView: UITableView!
    
    fileprivate var searchingInProcessView: SearchingInProcessView?
    fileprivate lazy var builder: SearchCellBuilder = SearchCellBuilder(tableView: self.tableView)
    fileprivate var channel: Channel?
    
    fileprivate var posts: Array<Post>! = Array()
    fileprivate var dates: Array<NSDate>! = Array()
    fileprivate var searchRequestResults: Results<SearchRequest>? = nil
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureForSearchStage(SearchStage.SearchNotStarted)
        self.menuContainerViewController.panMode = .init(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = UIScreen.screenWidth() - 75
        self.searchTextField.superview?.frame = CGRect(x: 8, y: 20, width: width, height: 44)
    }
}


//MARK: Configuration
extension SearchChatViewController: SearchChatViewControllerConfiguration {
    func configureWithChannel(channel: Channel) {
        self.channel = channel
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupTableView()
    func setupSearchView()
    func setupSearchIconTextField()
    func setupAutocompleteTableView()
}

fileprivate protocol Action {
    func cancelBarButtonAction(_ sender: AnyObject)
}

fileprivate protocol Navigation {
    func returnToChat()
    func proceedToChatWithPost(post: Post)
}

fileprivate protocol Requests {
    func searchWithTerms(terms: String)
}

fileprivate protocol Private {
    func configureForSearchStage(_ searchStage: Int)
    func postsForDate(date: NSDate) -> [Post]
}


//MARK: Setup
extension SearchChatViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupTableView()
        setupSearchView()
        setupSearchIconTextField()
        setupAutocompleteTableView()
    }
    
    func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.register(FeedSearchTableViewCell.self, forCellReuseIdentifier: FeedSearchTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.register(FeedSearchAttachmentTableViewCell.self, forCellReuseIdentifier: FeedSearchAttachmentTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.register(FeedTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
    }
    
    func setupSearchView() {
        self.searchingInProcessView = SearchingInProcessView.monkeyChatSearchView()
        self.searchingInProcessView?.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(self.searchingInProcessView!)
        
        self.searchingInProcessView?.frame = CGRect(x: 0, y: 64, width: UIScreen.screenWidth(), height: UIScreen.screenHeight())
        self.searchingInProcessView!.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    func setupSearchIconTextField() {
        let leftImageView = UIImageView()
        leftImageView.image = UIImage(named: "common_search_icon")
        
        let leftView = UIView()
        leftView.addSubview(leftImageView)
        
        leftView.frame = CGRect(x: 0, y: 0, width: 16, height: 20)
        leftImageView.frame = CGRect(x: 6, y: 2, width: 13, height: 14)
        searchTextField.leftViewMode = UITextFieldViewMode.always
        searchTextField.leftView = leftView
    }
    
    func setupAutocompleteTableView() {
    }
}


//MARK: Action
extension SearchChatViewController {
    @IBAction func cancelBarButtonAction(_ sender: AnyObject) {
        returnToChat()
    }
}


//MARK: Navigation
extension SearchChatViewController {
    func returnToChat() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromTop
        
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    func proceedToChatWithPost(post: Post) {
        let viewControllers: Array = (self.navigationController?.viewControllers)!
        let chat: ChatViewController = viewControllers[viewControllers.count - 2] as! ChatViewController
        
        //post.computeMissingFields()
        RealmUtils.save(post)
        chat.configureWithPost(post: post)
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: FetchedResultsController
extension SearchChatViewController {
    func prepareSearchResults() {
        let terms = self.searchTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if ((terms as NSString).length > 0) {
            configureForSearchStage(SearchStage.SearchRequstInProgress)
            searchWithTerms(terms: terms)
        }
        else {
            Api.sharedInstance.cancelSearchRequestFor(channel: self.channel!)
            configureForSearchStage(SearchStage.SearchNotStarted)
        }
    }
}


//MARK: Requests
extension SearchChatViewController: Requests {
    func searchWithTerms(terms: String) {
        PostUtils.sharedInstance.search(terms: terms, channel: self.channel!) { (posts, error) in
            if (error == nil) {
                self.posts = posts?.reversed()
                self.dates.removeAll()
                if (self.posts.count == 0) {
                    self.configureForSearchStage(SearchStage.SearchNoResults)
                }
                else {
                    for post in self.posts {
                        let day = post.day!
                        let index = (self.dates as NSArray).index(of: day.date!)
                        if (index == NSNotFound) {
                            self.dates.append(day.date! as NSDate)
                        }
                    }
                    
                    DispatchQueue.main.async{
                        self.configureForSearchStage(SearchStage.SearchResultsDisplay)
                        self.tableView.reloadData()
                    }
                }
            }
            else {
                if (error?.code != -999) {
                    AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                }
            }
        }
    }
}


//MARK: Private
extension SearchChatViewController: Private {
    func configureForSearchStage(_ searchStage: Int) {
        self.infoView.isHidden = (searchStage != SearchStage.SearchNotStarted)
        self.loadingEmozziView.isHidden = (searchStage != SearchStage.SearchRequstInProgress)
        self.tableView.isHidden = (searchStage != SearchStage.SearchResultsDisplay)
        self.noResultView.isHidden = (searchStage != SearchStage.SearchNoResults)
        
        if (self.loadingEmozziView.isHidden) {
            self.searchingInProcessView?.hide()
        }
        else {
            self.searchingInProcessView?.show()
        }
    }
    
    func postsForDate(date: NSDate) -> [Post] {
        let predicate = NSPredicate(format: "day.date == %@", argumentArray: [date])
        let filteredPosts = self.posts.filter{ predicate.evaluate(with: $0) }
        
        return filteredPosts
    }
    
    func prepareSearchRequestResults() {
        let realm = RealmUtils.realmForCurrentThread()
        self.searchRequestResults = realm.objects(SearchRequest.self).filter(NSPredicate(format: "text BEGINSWITH[c] %@", self.searchTextField.text!))
        self.autocompleteTableView.reloadData()
    }
}


//MARK: UITableViewDataSource

extension SearchChatViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard tableView != self.autocompleteTableView else { return 1 }
        return (self.dates.count != 0) ? self.dates.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView != self.autocompleteTableView else { return 0 }
        return (section < self.dates.count) ? postsForDate(date: self.dates[section]).count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView != self.autocompleteTableView else { return UITableViewCell() }
        
        let post = postsForDate(date: self.dates[indexPath.section])[indexPath.row]
        let cell = self.builder.cellForPost(post: post, searchingText: self.searchTextField.text!)
        (cell as! FeedSearchTableViewCell).disclosureTapHandler = {
            self.proceedToChatWithPost(post: post)
        }
        
        return cell
    }
}


//MARK: UITableViewDelegate
extension SearchChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableView != self.autocompleteTableView else { return nil }
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: FeedTableViewSectionHeader.reuseIdentifier()) as? FeedTableViewSectionHeader
        let titleString = (section < self.dates.count) ? (self.dates[section] as Date).feedSectionDateFormat() : StringUtils.emptyString()
        view!.configureWithTitle(titleString)
        view!.transform = tableView.transform
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard tableView != self.autocompleteTableView else { return 0 }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard tableView != self.autocompleteTableView else { return 0 }
        return FeedTableViewSectionHeader.height()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard tableView != self.autocompleteTableView else { return 25 }
        let post = postsForDate(date: self.dates[indexPath.section])[indexPath.row]
        return self.builder.heightForPost(post: post)
    }
}


//MARK: UITextFieldDelegate

extension SearchChatViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.configureForSearchStage(0)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString: NSString = textField.text! as NSString
        textField.text = newString.replacingCharacters(in: range, with: string)
        prepareSearchResults()
        prepareSearchRequestResults()
        
        return false
    }
}
