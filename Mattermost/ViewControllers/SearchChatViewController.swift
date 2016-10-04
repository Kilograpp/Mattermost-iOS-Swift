//
//  SearchChatViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 12.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

struct SearchStage {
    static let SearchNotStarted: Int       = 0
    static let SearchRequstInProgress: Int = 1
    static let SearchResultsDisplay: Int   = 2
    static let SearchNoResults: Int        = 3
}

private protocol LifeCycle {
    func viewDidLoad()
    func didReceiveMemoryWarning()
}

private protocol Private {
    func configureForSearchStage(_ searchStage: Int)
}

private protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupTableView()
    func setupSearchView()
}

private protocol Action {
    func cancelBarButtonAction(_ sender: AnyObject)
}

private protocol Navigation {
    func returnToChat()
}

class SearchChatViewController: UIViewController {
    
//MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var loadingEmozziView: UIView!
    
    var searchingInProcessView: SearchingInProcessView?
    var post: Post?


//MARK: Public
    
    func capConfigureWith(_ post: Post) {
        self.post = post
    }
}


//MARK: Life cycle

extension SearchChatViewController: LifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
}


//MARK: Setup

extension SearchChatViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupTableView()
        setupSearchView()
        
    }
    
    func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupTableView() {
        
    }
    
    func setupSearchView() {
        self.searchingInProcessView = SearchingInProcessView.monkeyChatSearchView()
        self.searchingInProcessView?.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(self.searchingInProcessView!)
        
        self.searchingInProcessView!.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        self.searchingInProcessView!.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
}


//MARK: Private

extension SearchChatViewController: Private {
    func configureForSearchStage(_ searchStage: Int) {
        self.infoView.isHidden = (searchStage != SearchStage.SearchNotStarted)
        self.tableView.isHidden = (searchStage != SearchStage.SearchResultsDisplay)
        self.noResultView.isHidden = (searchStage != SearchStage.SearchNoResults)
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
        self.navigationController?.popViewController(animated: false)
    }
}


//MARK: UITableViewDataSource

extension SearchChatViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.post != nil) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.post != nil) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}


//MARK: UITableViewDelegate

extension SearchChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}


//MARK: UITextFieldDelegate

extension SearchChatViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}
