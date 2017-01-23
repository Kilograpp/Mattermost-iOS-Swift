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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var loadingEmozziView: UIView!
    @IBOutlet weak var autocompleteTableView: UITableView!
    @IBOutlet weak var autocompleteTableViewFooter: UIView!
    
    fileprivate var searchingInProcessView: SearchingInProcessView?
    fileprivate lazy var builder: SearchCellBuilder = SearchCellBuilder(tableView: self.tableView)
    @IBOutlet weak var searchView: UIView!
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
        
        replaceStatusBar()
        configureForSearchStage(SearchStage.SearchNotStarted)
        prepareSearchRequestResults()
        self.autocompleteTableView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIStatusBar.shared().reset()
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
    func setupSearchBar()
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
        setupSearchBar()
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
        self.tableView.register(FeedTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: FeedTableViewSectionHeader.reuseIdentifier())
    }
    
    func setupSearchView() {
        self.searchingInProcessView = SearchingInProcessView.monkeyChatSearchView()
        self.searchingInProcessView?.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(self.searchingInProcessView!)
        
        self.searchingInProcessView?.frame = CGRect(x: 0, y: 64, width: UIScreen.screenWidth(), height: UIScreen.screenHeight())
        self.searchingInProcessView!.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    func setupSearchBar() {
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: ColorBucket.blueColor]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
        self.searchBar.becomeFirstResponder()
    }
    
    func setupAutocompleteTableView() {
        self.autocompleteTableView.isHidden = true
        let tapGestreRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeSearchHistoryAction))
        self.autocompleteTableViewFooter.addGestureRecognizer(tapGestreRecognizer)
    }
}


//MARK: Action
extension SearchChatViewController {
    @IBAction func cancelBarButtonAction(_ sender: AnyObject) {
        returnToChat()
    }
    
    func removeSearchHistoryAction() {
        self.autocompleteTableView.isHidden = true
        let realm = RealmUtils.realmForCurrentThread()
        try! realm.write {
            realm.delete(self.searchRequestResults!)
        }
        
        prepareSearchRequestResults()
    }
}


//MARK: Navigation
extension SearchChatViewController {
    func returnToChat() {
     /*   let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromTop
        
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        _ = self.navigationController?.popViewController(animated: false)*/
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false)
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
        let terms = self.searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
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
        addSearchRequestIfNeeded(terms: terms)
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
        let terms = self.searchBar.text!
        let realm = RealmUtils.realmForCurrentThread()
        self.searchRequestResults = realm.objects(SearchRequest.self).filter(NSPredicate(format: "text BEGINSWITH[c] %@", terms))
        self.autocompleteTableView.reloadData()
        
        let searchRequestsCount = (self.searchRequestResults?.count)!
        guard searchRequestsCount > 0 else {
            self.autocompleteTableView.isHidden = true
            return
        }
        
         self.autocompleteTableView.isHidden = (searchRequestsCount == 1) && (self.searchRequestResults?[0].text == terms)
    }
    
    func addSearchRequestIfNeeded(terms: String) {
        let predicate = NSPredicate(format: "text == %@", terms)
        guard RealmUtils.realmForCurrentThread().objects(SearchRequest.self).filter(predicate).count == 0 else { return }
        
        let searchRequest = SearchRequest()
        searchRequest.identifier = SearchRequest.generateNewId()
        searchRequest.text = terms
        
        RealmUtils.save(searchRequest)
        self.autocompleteTableView.isHidden = true
    }
}


//MARK: UITableViewDataSource
extension SearchChatViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard tableView != self.autocompleteTableView else { return 1 }
        return (self.dates.count != 0) ? self.dates.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView != self.autocompleteTableView else { return (self.searchRequestResults?.count)! }
        return (section < self.dates.count) ? postsForDate(date: self.dates[section]).count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView != self.autocompleteTableView else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutocompleteTableViewCell", for: indexPath)
            cell.textLabel?.font = FontBucket.loginTextFieldFont
            cell.textLabel?.textColor = ColorBucket.searchAutocompleteTextColor
            cell.textLabel?.text = self.searchRequestResults?[indexPath.row].text
            return cell
        }
        
        let post = postsForDate(date: self.dates[indexPath.section])[indexPath.row]
        let cell = self.builder.cellForPost(post: post, searchingText: self.searchBar.text!)
        (cell as! FeedSearchTableViewCell).disclosureTapHandler = {
            self.proceedToChatWithPost(post: post)
        }
        
        return cell
    }
}


//MARK: UITableViewDelegate
extension SearchChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == self.autocompleteTableView else { return }
        
        self.searchBar.text = self.searchRequestResults?[indexPath.row].text
        prepareSearchResults()
        self.autocompleteTableView.isHidden = true
    }
    
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
        guard tableView != self.autocompleteTableView else { return 44 }
        let post = postsForDate(date: self.dates[indexPath.section])[indexPath.row]
        return self.builder.heightForPost(post: post)
    }
}


//MARK: UISearchBarDelegate
extension SearchChatViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        returnToChat()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.autocompleteTableView.isHidden = (self.searchRequestResults?.count == 0)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.autocompleteTableView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newString: NSString = searchBar.text! as NSString
        searchBar.text = newString.replacingCharacters(in: range, with: text)
        
        prepareSearchRequestResults()
        if self.autocompleteTableView.isHidden {
            prepareSearchResults()
        }
        
        return false
    }
}
