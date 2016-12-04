//
//  LoginViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


final class LoginViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: KGTextField!
    @IBOutlet weak var loginTextField: KGTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recoveryButton: UIButton!
    @IBOutlet weak var loaderView: UIView!
    
    let titleName =  NSLocalizedString("Sign In", comment: "")
    let email = NSLocalizedString("Email", comment: "")
    let password = NSLocalizedString("Password", comment: "")
    let forgotPassword = NSLocalizedString("Forgot password?", comment: "")
    
//MARK: LifeCycle
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupTitleLabel()
    func setupLoginButton()
    func setupLoginTextField()
    func setupPasswordTextField()
    func setupRecoveryButton()
    func setupNotificationObserver()
    func setupTextFieldsContent()
}

fileprivate protocol Action {
    func loginAction(_ sender: AnyObject)
    func changeLogin(_ sender: AnyObject)
    func changePassword(_ sender: AnyObject)
}

fileprivate protocol Navigation {
    func proceedToTeams()
}

fileprivate protocol Request {
    func login()
    func loadTeams()
    func loadChannels()
    func loadCompleteUsersList()
}


//MARK: Setup
extension LoginViewController: Setup {
    func initialSetup() {
        setupTitleLabel()
        setupLoginButton()
        setupLoginTextField()
        setupPasswordTextField()
        setupRecoveryButton()
        setupNotificationObserver()
        setupTextFieldsContent()
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
        NotificationCenter.default.addObserver(self, selector: #selector(/*loadChannels*/proceedToChat),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserTeamSelectNotification),
                                               object: nil)
    }
    
    fileprivate func setupTextFieldsContent() {
        guard let login = Preferences.sharedInstance.predefinedLogin() else { return }
        self.loginTextField.text = login
        
        guard let password = Preferences.sharedInstance.predefinedPassword() else { return }
        self.passwordTextField.text = password
        
        if ((self.loginTextField.text != "") && (self.passwordTextField.text != "")) {
            self.loginButton.isEnabled = true
        }
    }
}


//MARK: Action
extension LoginViewController: Action {
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


//MARK: Navigation
extension LoginViewController: Navigation {
    func proceedToTeams() {
        let teamViewController = self.storyboard?.instantiateViewController(withIdentifier: "TeamViewController")
        let loginNavigationController = LoginNavigationController(rootViewController: teamViewController!)
        self.present(loginNavigationController, animated: true, completion: nil)
    }
}


//MARK: Request
extension LoginViewController: Request {
    func login() {
        Api.sharedInstance.login(self.loginTextField.text!, password: self.passwordTextField.text!) { (error) in
            guard (error == nil) else {
                let message = (error?.code == -1011) ? "Incorrect email or password!" : (error?.message)!
                AlertManager.sharedManager.showErrorWithMessage(message: message)
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
       // showLoaderView()
        Api.sharedInstance.loadChannels(with: { (error) in
            guard (error == nil) else { return }
            
            self.loadCompleteUsersList()
        })
    }
    
    func loadCompleteUsersList() {
        Api.sharedInstance.loadCompleteUsersList({ (error) in
            guard (error == nil) else { return }
            
            RouterUtils.loadInitialScreen()
           // self.hideLoaderView()
        })
    }
    
    func proceedToChat() {
        RouterUtils.loadInitialScreen()
    }
}


//MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
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


//MARK: LoaderView
extension LoginViewController {
    func showLoaderView() {
        (self.loaderView.subviews.first as! UIActivityIndicatorView).startAnimating()
        self.loaderView.isHidden = false
    }
    
    func hideLoaderView() {
        (self.loaderView.subviews.first as! UIActivityIndicatorView).startAnimating()
        self.loaderView.isHidden = false
    }
}
