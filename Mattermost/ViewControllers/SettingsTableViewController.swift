//
//  SettingsViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

//MARK: - Properties
    
    @IBOutlet weak var imagesCompressSwitch: UISwitch?
    
    
//MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: - Setup

extension SettingsTableViewController {
    func initialSetup() {
        setupimagesCompressSwitch()
    }
    
    func setupimagesCompressSwitch() {
        self.imagesCompressSwitch?.setOn((Preferences.sharedInstance.shouldCompressImages?.boolValue)!, animated: false)
    }
}


//MARK: - Private

extension SettingsTableViewController {
    func toggleShouldCompressValue() {
        Preferences.sharedInstance.shouldCompressImages = NSNumber.init(bool: (self.imagesCompressSwitch?.on)!)
        Preferences.sharedInstance.save()
    }
}


//MARK: - Actions

extension SettingsTableViewController {
    func backAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shouldCompressValueChanged(sender: AnyObject) {
        toggleShouldCompressValue()
    }
}


//MARK: - UITableViewDelegate

extension SettingsTableViewController {
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel!.font = UIFont.kg_regular13Font()
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = UIFont.kg_regular13Font()
    }
}

