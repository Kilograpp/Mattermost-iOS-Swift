//
//  InviteNewMemberTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 27.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

typealias MemberTuple = (email: String, firstName: String, lastName: String?)

class InviteNewMemberTableViewController: UITableViewController {
    
//MARK: Properties
    var memberTuplesArray: [MemberTuple] = [(email: "", firstName: "", lastName: "")]
}


private protocol InviteNewMemberTableViewControllerLifeCycle {
    func viewDidLoad()
}


private protocol InviteNewMemberTableViewControllerSetup {
    func initialSetup()
    func setupNavigationBar()
    func setupTableView()
}

private protocol InviteNewMemberTableViewControllerAction {
    func backAction()
    func inviteAction()
    func addAnoterAction(_ sender: AnyObject)
}

private protocol InviteNewMemberTableViewControllerNavigation {
    func returtToNSettings()
}

private protocol InviteNewMemberTableViewControllerRequest {
    func invite()
}


//MARK: InviteNewMemberTableViewControllerLifeCycle

extension InviteNewMemberTableViewController: InviteNewMemberTableViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.menuContainerViewController.panMode = .init(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
}


//MARK: InviteNewMemberTableViewControllerSetup

extension InviteNewMemberTableViewController: InviteNewMemberTableViewControllerSetup {
    func initialSetup() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        self.title = "Invite New Member"
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        let inviteButton = UIBarButtonItem.init(title: "Invite", style: .done, target: self, action: #selector(inviteAction))
        self.navigationItem.rightBarButtonItem = inviteButton
    }
    
    func setupTableView() {
        self.tableView.register(InviteNewMemberTableViewCell.self, forCellReuseIdentifier: InviteNewMemberTableViewCell.reuseIdentifier)
    }
}


//MARK: InviteNewMemberTableViewControllerAction

extension InviteNewMemberTableViewController: InviteNewMemberTableViewControllerAction {
    func backAction() {
       returtToNSettings()
    }
    
    func inviteAction() {
        invite()
    }
    
    @IBAction func addAnoterAction(_ sender: AnyObject) {
        self.memberTuplesArray.append((email: "", firstName: "", lastName: ""))
        self.tableView.reloadData()
    }
}


//MARK: InviteNewMemberTableViewControllerNavigation

extension InviteNewMemberTableViewController: InviteNewMemberTableViewControllerNavigation {
    func returtToNSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func proceedToSuccessInviteNewMember() {
        let storyboard = UIStoryboard.init(name: "RightMenu", bundle: nil)
        let successInviteNewMember = storyboard.instantiateViewController(withIdentifier: "SuccessInviteNewMemberTableViewController") as! SuccessInviteNewMembreViewController
        successInviteNewMember.configureWithInvitesCount(invitesCount: self.memberTuplesArray.count)
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(successInviteNewMember, animated:true)
    }
}


//MARK: InviteNewMemberTableViewControllerRequest

extension InviteNewMemberTableViewController: InviteNewMemberTableViewControllerRequest {
    func invite() {
        var invites: [Dictionary<String, String>] = []
        for memberTouple in self.memberTuplesArray {
            guard (memberTouple.email.characters.count > 0) else {
                AlertManager.sharedManager.showWarningWithMessage(message: "One or more empty emails!"/*, viewController: self*/)
                return
            }
            
            invites.append(["email" : memberTouple.email, "firstName" : memberTouple.firstName, "lastName" : memberTouple.lastName!])
        }
        Api.sharedInstance.sendInvites(invites) { (error) in
            guard (error == nil) else {
                AlertManager.sharedManager.showWarningWithMessage(message: (error?.message)!/*, viewController: self*/);
                return
            }
            
             self.proceedToSuccessInviteNewMember()
        }
    }
}


//MARK: UITableViewDataSource

extension InviteNewMemberTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.memberTuplesArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = InviteNewMemberTableViewCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! InviteNewMemberTableViewCell
        cell.textField.tag = indexPath.section * 10 + indexPath.row
        cell.textField.delegate = self
        
        switch indexPath.row {
        case 0:
            cell.configureWithIcon(UIImage(named: "profile_email_icon")!,
                                   placeholder: "email@domain.com",
                                   text: self.memberTuplesArray[indexPath.section].email)
            cell.textField.keyboardType = .emailAddress
            cell.textField.autocapitalizationType = .none
        case 1:
            cell.configureWithIcon(UIImage(named: "profile_name_icon")!,
                                   placeholder: "First name",
                                   text: self.memberTuplesArray[indexPath.section].firstName)
        case 2:
            cell.configureWithIcon(UIImage(named: "profile_nick_icon")!,
                                   placeholder: "Last name",
                                   text: self.memberTuplesArray[indexPath.section].lastName!)
        default:
            break
        }
        
        return cell
    }
}


//MARK: UITableViewDelegate

extension InviteNewMemberTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Member #" + String(section + 1)
    }
}


//MARK: UITextFieldDelegate

extension InviteNewMemberTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        textField.text = newString
        
        let tupleIndex = textField.tag / 10
        let fieldIndex = textField.tag % 10
    
        switch fieldIndex {
        case 0:
            self.memberTuplesArray[tupleIndex].email = newString
        case 1:
            self.memberTuplesArray[tupleIndex].firstName = newString
        case 2:
            self.memberTuplesArray[tupleIndex].lastName = newString
        default:
            break
        }
        return false
    }
}



