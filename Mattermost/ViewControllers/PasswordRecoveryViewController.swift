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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        emailTextField.resignFirstResponder()
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func setupEmailTextField()
    func setupPromtLabel()
    func setupRecoveryButton()
    func setupGestureRecognizers()
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
//        setupNavigationBar()
        setupEmailTextField()
        setupPromtLabel()
        setupRecoveryButton()
        setupGestureRecognizers()
    }
    
    func setupNavigationBar() {
        guard let navigationController = self.navigationController else { return }
        
        navigationController.navigationBar.titleTextAttributes = nil
        navigationController.navigationBar.tintColor = UIColor.black
        navigationController.navigationBar.barStyle = .default
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.backgroundColor = UIColor.clear
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.title = self.titleName
        self.setNeedsStatusBarAppearanceUpdate()
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
    
    func setupGestureRecognizers() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(backAction))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
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
        self.emailTextField.endEditing(false)
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
                //Message with rus localization on wrong email.. (code = 500) https://youtrack.kilograpp.com/issue/MM-1339
                let message = (error?.code == -1011) || (error?.code == 500) ? "Incorrect email!" : (error?.message)!
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
