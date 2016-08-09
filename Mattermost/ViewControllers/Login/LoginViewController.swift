//
//  LoginViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

// FIXME: CodeReview: Разнести протоколы на extension

private protocol Lifecylce {
    func viewDidLoad()
    func viewWillAppear(animated: Bool)
    func viewDidAppear(animated: Bool)
}

private protocol Setup {
    func setupNavigationBar()
    func setupTitleLabel()
    func setupLoginButton()
    func setupLoginTextField()
    func setupPasswordTextField()
    func setupRecoveryButton()
}

private protocol TextFieldDelegate {
    func changeLogin(sender: AnyObject)
    func changePassword(sender: AnyObject)
}

final class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: KGTextField!
    @IBOutlet weak var loginTextField: KGTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recoveryButton: UIButton!
    
    let titleName =  NSLocalizedString("Sign In", comment: "")
    let email = NSLocalizedString("Email", comment: "")
    let password = NSLocalizedString("Password", comment: "")
    let forgotPassword = NSLocalizedString("Forgot password?", comment: "")
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private func configure() {
        guard let login = Preferences.sharedInstance.predefinedLogin() else {
            return
        }
        self.loginTextField.text = login
        guard let password = Preferences.sharedInstance.predefinedPassword() else {
            return
        }
        self.passwordTextField.text = password
        if self.loginTextField.text != "" && self.passwordTextField.text != "" {
            self.loginButton.enabled = true
        }
    }
    
    
    //MARK - action
    
    @IBAction func loginAction(sender: AnyObject) {
        Api.sharedInstance.login(self.loginTextField.text!, password: self.passwordTextField.text!) {
            (error) in
            // FIXME: CodeReview: гуард
            if (error != nil){
                print("Error!")
        } else {
            Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
                Api.sharedInstance.loadChannels(with: { (error) in
                    Api.sharedInstance.loadCompleteUsersList({ (error) in
                        RouterUtils.loadInitialScreen()
                    })
                    
                    
                })
            })
            }
        }
    }
    
}


//MARK: - UITextFieldDelegate

extension LoginViewController: TextFieldDelegate {
    @IBAction func changeLogin(sender: AnyObject) {
        
        // FIXME: CodeReview: Guard
        if loginTextField.text != "" && passwordTextField.text != "" {
            self.loginButton.enabled = true
        } else {
            self.loginButton.enabled = false
        }
    }
    @IBAction func changePassword(sender: AnyObject) {
        
        // FIXME: CodeReview: guard
        if loginTextField.text != "" && passwordTextField.text != "" {
            self.loginButton.enabled = true
        } else {
            self.loginButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(self.loginTextField) {
            self.passwordTextField.becomeFirstResponder()
        }
        if textField .isEqual(self.passwordTextField) {
            self.loginAction(self)
        }
        return true
    }
}

// MARK: - Lifecycle

extension LoginViewController: Lifecylce {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTitleLabel()
        self.setupLoginButton()
        self.setupLoginTextField()
        self.setupPasswordTextField()
        self.setupRecoveryButton()
        self.configure()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loginTextField.becomeFirstResponder()
    }
}


// MARK: - Setup

extension LoginViewController: Setup {
    private func setupNavigationBar() {
        let titleAttribute = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: FontBucket.normalTitleFont
        ]
        
        guard let navigationController = self.navigationController else {
            return
        }
        navigationController.navigationBar.titleTextAttributes = titleAttribute
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.navigationBar.barStyle = .Black
        navigationController.navigationBar.translucent = true
        navigationController.navigationBar.backgroundColor = UIColor.clearColor()
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.title = self.titleName
        self.navigationController?.view.bringSubviewToFront(self.titleLabel)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupTitleLabel() {
        self.titleLabel.font = FontBucket.titleLoginFont
        self.titleLabel.textColor = ColorBucket.whiteColor
        self.titleLabel.text = Preferences.sharedInstance.siteName
    }
    
    private func setupLoginButton() {
        self.loginButton.layer.cornerRadius = 2
        self.loginButton.setTitle(self.titleName, forState: .Normal)
        self.loginButton.titleLabel?.font = FontBucket.loginButtonFont
        self.loginButton.enabled = false
    }
    
    private func setupLoginTextField() {
        self.loginTextField.delegate = self;
        self.loginTextField.textColor = ColorBucket.blackColor
        self.loginTextField.font = FontBucket.loginTextFieldFont
        self.loginTextField.placeholder = self.email
        self.loginTextField.keyboardType = .EmailAddress
        self.loginTextField.autocorrectionType = .No
    }
    
    private func setupPasswordTextField() {
        self.passwordTextField.delegate = self;
        self.passwordTextField.textColor = ColorBucket.blackColor
        self.passwordTextField.font = FontBucket.loginTextFieldFont
        self.passwordTextField.placeholder = self.password
        self.passwordTextField.autocorrectionType = .No
        self.passwordTextField.secureTextEntry = true
    }
    
    private func setupRecoveryButton() {
        self.recoveryButton.layer.cornerRadius = 2
        self.recoveryButton.backgroundColor = ColorBucket.whiteColor
        self.recoveryButton.setTitle(self.forgotPassword, forState:.Normal)
        self.recoveryButton.tintColor = UIColor.redColor()
        self.recoveryButton.setTitleColor(UIColor.redColor(), forState:.Normal)
        self.recoveryButton.titleLabel?.font = FontBucket.forgotPasswordButtonFont
    }

}
