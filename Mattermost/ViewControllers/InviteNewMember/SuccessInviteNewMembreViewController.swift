//
//  SuccessInviteNewMembreViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 28.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Configuration: class {
    func configureWithInvitesCount(invitesCount: Int)
}


final class SuccessInviteNewMembreViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var invitesCountLabel: UILabel?
    
    fileprivate var intitesCount: Int = 0

//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
}


//MARK: Configuration
extension SuccessInviteNewMembreViewController: Configuration {
    func configureWithInvitesCount(invitesCount: Int) {
        self.intitesCount = invitesCount
    }
}


private protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupInvitesCountLabel()
}

private protocol Action {
    func initialSetup()
    func setupNavigationBar()
    func setupInvitesCountLabel()
}

private protocol Navigation {
    func returtToInviteNewMember()
    func returnToChat()
}


//MARK: Setup
extension SuccessInviteNewMembreViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupInvitesCountLabel()
        setupSwipeRight()
        self.menuContainerViewController.panMode = .init(0)
    }
    
    func setupNavigationBar() {
        self.title = "Invite New Member"
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneAction))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func setupInvitesCountLabel() {
        var text = "You have successfully invited " + String(self.intitesCount) + " new user"
        text += (self.intitesCount > 1) ? "s." : "."
        self.invitesCountLabel?.text = text
    }
    
    func setupSwipeRight() {
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(backAction))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
}


//MARK: Action
extension SuccessInviteNewMembreViewController: Action {
    func backAction() {
        returtToInviteNewMember()
    }
    
    func doneAction() {
        returnToChat()
    }
}


//MARK: Navigation
extension SuccessInviteNewMembreViewController: Navigation {
    func returtToInviteNewMember() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func returnToChat() {
        var viewControllers = self.navigationController?.viewControllers
        viewControllers?.removeLast()
        viewControllers?.removeLast()
        
        self.navigationController?.setViewControllers(viewControllers!, animated: true)
    }
}
