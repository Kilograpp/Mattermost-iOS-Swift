//
//  PasswordRecoveryViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 06.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class PasswordRecoveryViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: KGTextField!
    @IBOutlet weak var recoveryButton: UIButton!
    @IBOutlet weak var promtLabel: UILabel!
    
    fileprivate var saveButton: UIBarButtonItem!
    
    let titleName =  NSLocalizedString("Password Recovery", comment: "")
    let email = NSLocalizedString("Email", comment: "")
    let subtitleName = NSLocalizedString("Enter the email address associated with your team.", comment: "")
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func setupEmailTextField()
    func setupPromtLabel()
    func setupRecoveryButton()
}

fileprivate protocol Action: class {
    func backAction()
    func saveAction()
    func recoveryAction()
}

fileprivate protocol Navigation: class {
    func returnToLogin()
}

fileprivate protocol Request: class {
    func recovery()
}


//MARK: Setup
extension PasswordRecoveryViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupEmailTextField()
        setupPromtLabel()
        setupRecoveryButton()
    }
    
    func setupNavigationBar() {
        guard let navigationController = self.navigationController else { return }
        
        navigationController.navigationBar.titleTextAttributes = nil
        navigationController.navigationBar.tintColor = nil
        navigationController.navigationBar.barStyle = .default
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.backgroundColor = nil
        navigationController.navigationBar.shadowImage = nil
        navigationController.navigationBar.setBackgroundImage(nil, for: .default)
        
        self.title = self.titleName
        self.setNeedsStatusBarAppearanceUpdate()
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func setupEmailTextField() {
        self.emailTextField.delegate = self;
        self.emailTextField.textColor = ColorBucket.blackColor
        self.emailTextField.font = FontBucket.loginTextFieldFont
        self.emailTextField.placeholder = self.email
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.autocorrectionType = .no
    }
    
    fileprivate func setupPromtLabel() {
        self.promtLabel.font = FontBucket.subtitleServerUrlFont
        self.promtLabel.textColor = ColorBucket.grayColor
        self.promtLabel.text = self.subtitleName
    }
    
    func setupRecoveryButton() {
        self.recoveryButton.setTitle(self.titleName, for: UIControlState())
        self.recoveryButton.isEnabled = false
    }
}


//MARK: Action
extension PasswordRecoveryViewController: Action {
    func backAction() {
        returnToLogin()
    }
    
    func saveAction() {
    
    }
    
    @IBAction func recoveryAction() {
        recovery()
    }
}


//MARK: Navigation
extension PasswordRecoveryViewController: Navigation {
    func returnToLogin() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension PasswordRecoveryViewController: Request {
    func recovery() {
        let email = self.emailTextField.text
        Api.sharedInstance.passwordResetFor(email: email!) { (error) in
            guard (error == nil) else {
                let message = (error?.code == -1011) ? "Incorrect email!" : (error?.message)!
                AlertManager.sharedManager.showErrorWithMessage(message: message)
                return
            }
            
            self.recoveryButton.isEnabled = false
            AlertManager.sharedManager.showSuccesWithMessage(message: "Password reset instructions were sent to your email")
        }
    }
}


//MARK: UITextFieldDelegate
extension PasswordRecoveryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        recoveryAction()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString: NSString = textField.text! as NSString
        guard newString.length <= 30 else { return false }
        textField.text = newString.replacingCharacters(in: range, with: string)
        self.recoveryButton.isEnabled = (textField.text?.characters.count)! > 0
        
        return false
    }
}
