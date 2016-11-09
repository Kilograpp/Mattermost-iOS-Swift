//
//  CreateChannelViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 09.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

protocol CreateChannelViewControllerConfiguration: class {
    func configure(privateType: String)
}

class CreateChannelViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var nameTextField: KGTextField!
    @IBOutlet weak var headerTextField: KGTextField!
    @IBOutlet weak var porpuseTextField: KGTextField!
    
    fileprivate var createButton: UIBarButtonItem!
    fileprivate var privateType: String! = ""
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: Configuration
extension CreateChannelViewController: CreateChannelViewControllerConfiguration {
    func configure(privateType: String) {
        self.privateType = privateType
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func setupNameTextField()
    func setupHeaderTextField()
    func setupPorpuseTextField()
}

fileprivate protocol Action: class {
    func backAction()
    func createAction()
}

fileprivate protocol Navigation: class {
    func returnToChannel()
}

fileprivate protocol Request: class {

}


//MARK: Setup
extension CreateChannelViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupNameTextField()
    }
    
    func setupNavigationBar() {
        self.title = "New Channel"
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.createButton = UIBarButtonItem.init(title: "Create", style: .done, target: self, action: #selector(createAction))
        self.createButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.createButton
    }
    
    func setupNameTextField() {
     //   self.na
    }
    
    func setupHeaderTextField() {
    
    }
    
    func setupPorpuseTextField() {
    
    }
}


//MARK: Action
extension CreateChannelViewController: Action {
    func backAction() {
        self.returnToChannel()
    }
    
    func createAction() {
     //   saveResults()
    }
}


//MARK: Navigation
extension CreateChannelViewController: Navigation {
    func returnToChannel() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension CreateChannelViewController: Request {

}
