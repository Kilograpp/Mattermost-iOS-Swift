//
//  LoginViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


final class LoginViewController: UIViewController, UITextFieldDelegate {

//MARK: Properties
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: KGTextField!
    @IBOutlet weak var loginTextField: KGTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recoveryButton: UIButton!
    
    let titleName =  NSLocalizedString("Sign In", comment: "")
    let email = NSLocalizedString("Email", comment: "")
    let password = NSLocalizedString("Password", comment: "")
    let forgotPassword = NSLocalizedString("Forgot password?", comment: "")
    

//MARK: Configuration
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func configure() {
        guard let login = Preferences.sharedInstance.predefinedLogin() else { return }
        self.loginTextField.text = login
        
        guard let password = Preferences.sharedInstance.predefinedPassword() else { return }
        self.passwordTextField.text = password
        
        if ((self.loginTextField.text != "") && (self.passwordTextField.text != "")) {
            self.loginButton.isEnabled = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


private protocol LoginViewControllerLifeCylce {
    func viewDidLoad()
    func viewWillAppear(_ animated: Bool)
    func viewDidAppear(_ animated: Bool)
}

private protocol LoginViewControllerSetup {
    func initialSetup()
    func setupNavigationBar()
    func setupTitleLabel()
    func setupLoginButton()
    func setupLoginTextField()
    func setupPasswordTextField()
    func setupRecoveryButton()
    func setupNotificationObserver()
}

private protocol LoginViewControllerAction {
    func loginAction(_ sender: AnyObject)
    func changeLogin(_ sender: AnyObject)
    func changePassword(_ sender: AnyObject)
}

private protocol LoginViewControllerNavigation {
    func proceedToTeams()
}

private protocol LoginViewControllerRequest {
    func login()
    func loadTeams()
    func loadChannels()
    func loadCompleteUsersList()
}


//MARK: LoginViewControllerLifeCylce

extension LoginViewController: LoginViewControllerLifeCylce {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = self.loginTextField.becomeFirstResponder()
    }
}


//MARK: LoginViewControllerSetup

extension LoginViewController: LoginViewControllerSetup {
    func initialSetup() {
        setupTitleLabel()
        setupLoginButton()
        setupLoginTextField()
        setupPasswordTextField()
        setupRecoveryButton()
        setupNotificationObserver()
        configure()
    }
    
    fileprivate func setupNavigationBar() {
        let titleAttribute = [ NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: FontBucket.normalTitleFont ]
        guard let navigationController = self.navigationController else { return }
        
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
    
    fileprivate func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadChannels),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserTeamSelectNotification),
                                               object: nil)
    }
}


//MARK: LoginViewControllerAction

extension LoginViewController: LoginViewControllerAction {
    @IBAction func loginAction(_ sender: AnyObject) {
        login()
    }
    
    @IBAction func changeLogin(_ sender: AnyObject) {
        self.loginButton.isEnabled = ((loginTextField.text != "") && (passwordTextField.text != ""))
    }
    @IBAction func changePassword(_ sender: AnyObject) {
        self.loginButton.isEnabled = ((loginTextField.text != "") && (passwordTextField.text != ""))
    }
}


//MARK: LoginViewControllerNavigation

extension LoginViewController: LoginViewControllerNavigation {
    func proceedToTeams() {
        let teamViewController = self.storyboard?.instantiateViewController(withIdentifier: "TeamViewController")
        let loginNavigationController = LoginNavigationController(rootViewController: teamViewController!)
        self.present(loginNavigationController, animated: true, completion: nil)
    }
}


//MARK: LoginViewControllerRequest

extension LoginViewController: LoginViewControllerRequest {
    func login() {
        Api.sharedInstance.login(self.loginTextField.text!, password: self.passwordTextField.text!) { (error) in
            guard (error == nil) else {
                let message = (error?.code == -1011) ? "Incorrect email or password!" : (error?.message)!
                AlertManager.sharedManager.showErrorWithMessage(message: message, viewController: self)
                return
            }
            
            self.loadTeams()
        }
    }
    
    func loadTeams() {
        Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
            guard (error == nil) else { return }
            
            if userShouldSelectTeam {
                self.proceedToTeams()
            }
            else {
                self.loadChannels()
            }
        })
    }
    
    func loadChannels() {
        Api.sharedInstance.loadChannels(with: { (error) in
            guard (error == nil) else { return }
            
            self.loadCompleteUsersList()
        })
    }
    
    func loadCompleteUsersList() {
        Api.sharedInstance.loadCompleteUsersList({ (error) in
            guard (error == nil) else { return }
            
            RouterUtils.loadInitialScreen()
        })
    }
}


//MARK: - UITextFieldDelegate

extension LoginViewController {
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

