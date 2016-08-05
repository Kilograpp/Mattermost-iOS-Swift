//
//  LoginViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: KGTextField!
    @IBOutlet weak var loginTextField: KGTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recoveryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTitleLabel()
        self.setupLoginButton()
        self.setupLoginTextField()
        self.setupPasswordTextField()
        self.setupRecoveryButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loginTextField.becomeFirstResponder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //MARK - setup
    
    func setupNavigationBar() {
        let titleAttribute = [NSForegroundColorAttributeName: UIColor.whiteColor(),
                              NSFontAttributeName: FontBucket.normalTitleFont]
        
        self.navigationController?.navigationBar.titleTextAttributes = titleAttribute
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.title = "Sign In"
        self.navigationController?.view.bringSubviewToFront(self.titleLabel)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setupTitleLabel() {
        self.titleLabel.font = FontBucket.titleLoginFont
        self.titleLabel.textColor = ColorBucket.whiteColor
    }
    
    func setupLoginButton() {
        self.loginButton.layer.cornerRadius = 2
        self.loginButton.setTitle("Sign In", forState: UIControlState.Normal)
        self.loginButton.titleLabel?.font = FontBucket.loginButtonFont
        self.loginButton.enabled = false
    }
    
    func setupLoginTextField() {
        self.loginTextField.delegate = self;
        self.loginTextField.textColor = ColorBucket.blackColor
        self.loginTextField.font = FontBucket.loginTextFieldFont
        self.loginTextField.placeholder = "Email";
        self.loginTextField.keyboardType = UIKeyboardType.EmailAddress
        self.loginTextField.autocorrectionType = UITextAutocorrectionType.No
    }
    
    func setupPasswordTextField() {
        self.passwordTextField.delegate = self;
        self.passwordTextField.textColor = ColorBucket.blackColor
        self.passwordTextField.font = FontBucket.loginTextFieldFont
        self.passwordTextField.placeholder = "Password";
        self.passwordTextField.autocorrectionType = UITextAutocorrectionType.No
        self.passwordTextField.secureTextEntry = true
    }
    
    func setupRecoveryButton() {
        self.recoveryButton.layer.cornerRadius = 2
        self.recoveryButton.backgroundColor = ColorBucket.whiteColor
        self.recoveryButton.setTitle("Forgot password?", forState:UIControlState.Normal)
        self.recoveryButton.tintColor = UIColor.redColor()
        self.recoveryButton.setTitleColor(UIColor.redColor(), forState:UIControlState.Normal)
        self.recoveryButton.titleLabel?.font = FontBucket.forgotPasswordButtonFont
    }
    
    
    //MARK - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.isEqual(self.loginTextField)) {
            self.passwordTextField.becomeFirstResponder()
        } else if (textField.isEqual(self.passwordTextField)) {
            self.loginAction(self)
        }
        return true
    }
    
    
    //MARK - action
    
    @IBAction func loginAction(sender: AnyObject) {
        // Preferences.sharedInstance.serverUrl = Preferences.sharedInstance.predefinedServerUrl()
//        Api.sharedInstance.login(Preferences.sharedInstance.predefinedLogin()!, password: Preferences.sharedInstance.predefinedPassword()!) { (error) in
//            Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
//                Api.sharedInstance.loadChannels(with: { (error) in
//                    Api.sharedInstance.loadCompleteUsersList({ (error) in
//                        RouterUtils.loadInitialScreen(true)
//                    })
//                    
//                    
//                })
//            })
//        }
        Preferences.sharedInstance.serverUrl = "https://mattermost.kilograpp.com"
        Api.sharedInstance.login(self.loginTextField.text!, password: self.passwordTextField.text!) { (error) in if (error != nil){
            print("Error!")
        } else {
            Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
                Api.sharedInstance.loadChannels(with: { (error) in
                    Api.sharedInstance.loadCompleteUsersList({ (error) in
                        RouterUtils.loadInitialScreen(true)
                    })
                    
                    
                })
            })
            }
        }
    }
    
    @IBAction func changeLogin(sender: AnyObject) {
        if loginTextField.text != "" && passwordTextField.text != "" {
            self.loginButton.enabled = true
        } else {
            self.loginButton.enabled = false
        }
    }
    @IBAction func changePassword(sender: AnyObject) {
        if loginTextField.text != "" && passwordTextField.text != "" {
            self.loginButton.enabled = true
        } else {
            self.loginButton.enabled = false
        }
    }
}
