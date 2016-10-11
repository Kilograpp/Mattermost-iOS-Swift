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
    func viewWillAppear(_ animated: Bool)
    func viewDidAppear(_ animated: Bool)
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
    func changeLogin(_ sender: AnyObject)
    func changePassword(_ sender: AnyObject)
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func configure() {
        guard let login = Preferences.sharedInstance.predefinedLogin() else {
            return
        }
        self.loginTextField.text = login
        guard let password = Preferences.sharedInstance.predefinedPassword() else {
            return
        }
        self.passwordTextField.text = password
        if self.loginTextField.text != "" && self.passwordTextField.text != "" {
            self.loginButton.isEnabled = true
        }
    }
    
    
    //MARK - action
    
    @IBAction func loginAction(_ sender: AnyObject) {
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
    @IBAction func changeLogin(_ sender: AnyObject) {
        
        // FIXME: CodeReview: Guard
        if loginTextField.text != "" && passwordTextField.text != "" {
            self.loginButton.isEnabled = true
        } else {
            self.loginButton.isEnabled = false
        }
    }
    @IBAction func changePassword(_ sender: AnyObject) {
        
        // FIXME: CodeReview: guard
        if loginTextField.text != "" && passwordTextField.text != "" {
            self.loginButton.isEnabled = true
        } else {
            self.loginButton.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.loginTextField) {
            _ = self.passwordTextField.becomeFirstResponder()
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
        
//FIXME: вызов методов не должен быть через self
        self.setupTitleLabel()
        self.setupLoginButton()
        self.setupLoginTextField()
        self.setupPasswordTextField()
        self.setupRecoveryButton()
        self.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//FIXME: вызов методов не должен быть через self        
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = self.loginTextField.becomeFirstResponder()
    }
}


// MARK: - Setup

extension LoginViewController: Setup {
    fileprivate func setupNavigationBar() {
        let titleAttribute = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: FontBucket.normalTitleFont
        ]
        
        guard let navigationController = self.navigationController else {
            return
        }
        navigationController.navigationBar.titleTextAttributes = titleAttribute
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.backgroundColor = UIColor.clear
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.title = self.titleName
        self.navigationController?.view.bringSubview(toFront: self.titleLabel)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    fileprivate func setupTitleLabel() {
        self.titleLabel.font = FontBucket.titleLoginFont
        self.titleLabel.textColor = ColorBucket.whiteColor
        self.titleLabel.text = Preferences.sharedInstance.siteName
    }
    
    fileprivate func setupLoginButton() {
        self.loginButton.layer.cornerRadius = 2
        self.loginButton.setTitle(self.titleName, for: UIControlState())
        self.loginButton.titleLabel?.font = FontBucket.loginButtonFont
        self.loginButton.isEnabled = false
    }
    
    fileprivate func setupLoginTextField() {
        self.loginTextField.delegate = self;
        self.loginTextField.textColor = ColorBucket.blackColor
        self.loginTextField.font = FontBucket.loginTextFieldFont
        self.loginTextField.placeholder = self.email
        self.loginTextField.keyboardType = .emailAddress
        self.loginTextField.autocorrectionType = .no
    }
    
    fileprivate func setupPasswordTextField() {
        self.passwordTextField.delegate = self;
        self.passwordTextField.textColor = ColorBucket.blackColor
        self.passwordTextField.font = FontBucket.loginTextFieldFont
        self.passwordTextField.placeholder = self.password
        self.passwordTextField.autocorrectionType = .no
        self.passwordTextField.isSecureTextEntry = true
    }
    
    fileprivate func setupRecoveryButton() {
        self.recoveryButton.layer.cornerRadius = 2
        self.recoveryButton.backgroundColor = ColorBucket.whiteColor
        self.recoveryButton.setTitle(self.forgotPassword, for:UIControlState())
        self.recoveryButton.tintColor = UIColor.red
        self.recoveryButton.setTitleColor(UIColor.red, for:UIControlState())
        self.recoveryButton.titleLabel?.font = FontBucket.forgotPasswordButtonFont
    }

}
