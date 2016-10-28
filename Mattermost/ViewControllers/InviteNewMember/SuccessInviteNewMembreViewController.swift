//
//  SuccessInviteNewMembreViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 28.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class SuccessInviteNewMembreViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var invitesCountLabel: UILabel?
    
    fileprivate var intitesCount: Int = 0
    
    func configureWithInvitesCount(invitesCount: Int) {
        self.intitesCount = invitesCount
    }
    
}


private protocol SuccessInviteNewMembreViewControllerLifeCycle {
    func viewDidLoad()
}

private protocol SuccessInviteNewMembreViewControllerSetup {
    func initialSetup()
    func setupNavigationBar()
    func setupInvitesCountLabel()
}

private protocol SuccessInviteNewMembreViewControllerAction {
    func initialSetup()
    func setupNavigationBar()
    func setupInvitesCountLabel()
}

private protocol SuccessInviteNewMembreViewControllerNavigation {
    func returtToInviteNewMember()
    func returnToChat()
}


//MARK: SuccessInviteNewMembreViewControllerLifeCycle

extension SuccessInviteNewMembreViewController: SuccessInviteNewMembreViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
}

    
//MARK: SuccessInviteNewMembreViewControllerSetup

extension SuccessInviteNewMembreViewController: SuccessInviteNewMembreViewControllerSetup {
    func initialSetup() {
        setupNavigationBar()
        setupInvitesCountLabel()
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
}


//MARK: SuccessInviteNewMembreViewControllerAction

extension SuccessInviteNewMembreViewController: SuccessInviteNewMembreViewControllerAction {
    func backAction() {
        returtToInviteNewMember()
    }
    
    func doneAction() {
        returnToChat()
    }
}


//MARK: SuccessInviteNewMembreViewControllerNavigation

extension SuccessInviteNewMembreViewController: SuccessInviteNewMembreViewControllerNavigation {
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
