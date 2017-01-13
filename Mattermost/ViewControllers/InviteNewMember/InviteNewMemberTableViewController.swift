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
    
//MARK: LifeCycle
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


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupTableView()
}

fileprivate protocol Action {
    func backAction()
    func inviteAction()
    func addAnoterAction(_ sender: AnyObject)
}

fileprivate protocol Navigation {
    func returtToNSettings()
}

fileprivate protocol InviteNewMemberTableViewControllerRequest {
    func invite()
}


//MARK: Setup
extension InviteNewMemberTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupTableView()
//        setupSwipeRight()
    }
    
    func setupNavigationBar() {
        self.title = "Invite New Member"
        
        let inviteButton = UIBarButtonItem(title: "Invite", style: .done, target: self, action: #selector(inviteAction))
        self.navigationItem.rightBarButtonItem = inviteButton
    }
    
    func setupTableView() {
        self.tableView.register(InviteNewMemberTableViewCell.self, forCellReuseIdentifier: InviteNewMemberTableViewCell.reuseIdentifier)
    }
    
    func setupSwipeRight() {
//        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(backAction))
//        swipeRight.direction = .right
//        view.addGestureRecognizer(swipeRight)
    }
}


//MARK: Action
extension InviteNewMemberTableViewController: Action {
    func backAction() {
       returtToNSettings()
    }
    
    func inviteAction() {
        invite()
    }
    
    @IBAction func addAnoterAction(_ sender: AnyObject) {
        addMember()
    }
    
    func deleteMemberAction(_ sender: AnyObject) {
        deleteMemberAt(index: sender.tag)
    }
}


//MARK: Navigation
extension InviteNewMemberTableViewController: Navigation {
    func returtToNSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func proceedToSuccessInviteNewMember() {
        let successInviteNewMember = self.storyboard?.instantiateViewController(withIdentifier: "SuccessInviteNewMemberTableViewController") as! SuccessInviteNewMembreViewController
        successInviteNewMember.configureWithInvitesCount(invitesCount: self.memberTuplesArray.count)
        self.navigationController?.pushViewController(successInviteNewMember, animated: true)
    }
}


//MARK: Request
extension InviteNewMemberTableViewController: InviteNewMemberTableViewControllerRequest {
    func invite() {
        var invites: [Dictionary<String, String>] = []
        for memberTouple in self.memberTuplesArray {
            guard (memberTouple.email.characters.count > 0) else {
                AlertManager.sharedManager.showWarningWithMessage(message: "One or more empty emails!")
                return
            }
            invites.append(["email" : memberTouple.email, "firstName" : memberTouple.firstName, "lastName" : memberTouple.lastName!])
        }
        Api.sharedInstance.sendInvites(invites) { (error) in
            guard (error == nil) else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!);
                return
            }
            self.proceedToSuccessInviteNewMember()
        }
    }
}


//MARK: Support
extension InviteNewMemberTableViewController {
    func addMember() {
        self.memberTuplesArray.append((email: "", firstName: "", lastName: ""))
        self.tableView.beginUpdates()
        let section = self.memberTuplesArray.count - 1
        self.tableView.insertSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        self.tableView.insertRows(at: [IndexPath(row: 0, section: section), IndexPath(row: 1, section: section), IndexPath(row: 2, section: section)], with: .automatic)
        //self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
      self.tableView.reloadData()
        self.tableView.endUpdates()
    //    self.tableView.reloadData()
    }
    
    func deleteMemberAt(index: Int) {
        self.memberTuplesArray.remove(at: index)
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [IndexPath(row: 0, section: index), IndexPath(row: 1, section: index), IndexPath(row: 2, section: index)], with: .automatic)
        self.tableView.deleteSections(NSIndexSet(index: index) as IndexSet, with: .automatic)
        
        /*if index < self.memberTuplesArray.count {
            let range = NSMakeRange(index + 1, self.memberTuplesArray.count - index)
            self.tableView.reloadSections(NSIndexSet(indexesIn: range) as IndexSet, with: .none)
        }
       
        if (index != 0) && (self.memberTuplesArray.count == 1) {
            self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
        }*/
       self.tableView.reloadData()
        self.tableView.endUpdates()
     //   self.tableView.reloadData()
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
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Member #" + String(section + 1)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = UIScreen.main.bounds.size.width
        let heigth = 60
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: Int(width), height: heigth))
        
        let y = (section == 0) ? 25 : 5
        let headerLabel = UILabel(frame: CGRect(x: 15, y: y, width: 200, height: 20))
        headerLabel.backgroundColor = UIColor.clear
        headerLabel.font = FontBucket.postDateFont
        headerLabel.textColor = ColorBucket.sectionTitleColor
        headerLabel.text = "MEMBER #" + String(section + 1)
        headerLabel.textAlignment = .left
        headerView.addSubview(headerLabel)
        
        guard self.memberTuplesArray.count > 1 else { return headerView }
        
        let deleteButton = UIButton(frame: CGRect(x: Int(width - 65), y: y, width: 50, height: 20))
        deleteButton.setTitleColor(ColorBucket.errorAlertColor, for: .normal)
        deleteButton.titleLabel?.font = FontBucket.postDateFont
        deleteButton.titleLabel?.textAlignment = .right
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.tag = section
        deleteButton.addTarget(self, action: #selector(deleteMemberAction(_:)), for: .touchUpInside)
        
        
        headerView.insertSubview(deleteButton, at: 0)
        
        return headerView
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



