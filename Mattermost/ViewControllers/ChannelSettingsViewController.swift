//
//  ChannelSettingsViewController.swift
//  Mattermost
//
//  Created by Владислав on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class ChannelSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib1 = UINib(nibName: "HeaderChannelSettingsCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "headerChannelSettingsCell")
        let nib2 = UINib(nibName: "InformationChannelSettingsCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "informationChannelSettingsCell")
        let nib3 = UINib(nibName: "MemberChannelSettingsCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "memberChannelSettingsCell")
        let nib4 = UINib(nibName: "AddMembersChannelSettingsCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "addMembersChannelSettingsCell")
        let nib5 = UINib(nibName: "LabelChannelSettingsCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "labelChannelSettingsCell")
        
        setupNavigationBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 2){
            return "9999"+" members"
        }
        return ""
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section){
        case 0:
            return 1
        case 1:
            return 4
        case 2:
            return 7
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section{
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "headerChannelSettingsCell") as! HeaderChannelSettingsCell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "informationChannelSettingsCell") as! InformationChannelSettingsCell
        case 2:
            if (indexPath.row==0){
                cell = tableView.dequeueReusableCell(withIdentifier: "addMembersChannelSettingsCell") as! AddMembersChannelSettingsCell
            } else if (indexPath.row==7-1) {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "labelChannelSettingsCell") as! LabelChannelSettingsCell
                cell1.cellText.text = "See all members"
                cell = cell1
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "memberChannelSettingsCell") as! MemberChannelSettingsCell
                if (indexPath.row==5){
                    cell.separatorInset = UIEdgeInsets.zero
                    break
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
            }
        case 3:
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "labelChannelSettingsCell") as! LabelChannelSettingsCell
            cell2.cellText.text = "Leave Channel"
            cell = cell2
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section){
        case 0:
            return 91
        case 1:
            return 50
        case 2:
            return 50
        case 3:
            return 56
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (section){
        case 0:
            return 1.0
        case 1:
            return 30
        case 2:
            return 60
        case 3:
            return 30
        default:
            return 0
        }
    }
    
    func setupNavigationBar() {
        self.title = "Channel Info".localized
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: nil), animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMembersAdditing"{
            /*if let indexPath = countryTableView.indexPathForSelectedRow{
             let destinationController = segue.destination as! CitiesViewController
             let countryName = (countryTableView.cellForRow(at: indexPath) as! CountyTableViewCell).countryName.text!
             destinationController.cityList = WorkWithRealm.getAllCities(countryName: countryName)
             destinationController.countryName = countryName
             }*/
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath==IndexPath(row: 0, section: 2)){
            performSegue(withIdentifier: "showMembersAdditing", sender: nil)
        }
        if (indexPath==IndexPath(row: 6, section: 2)){
            performSegue(withIdentifier: "showAllMembers", sender: nil)
        }
    }
}
