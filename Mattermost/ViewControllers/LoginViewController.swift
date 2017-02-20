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
    @IBOutlet weak var headerView: UIView!
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
        
        if !UserStatusManager.sharedInstance.isSignedIn() {
            _ = self.loginTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        _ = self.loginTextField.resignFirstResponder()
        _ = self.passwordTextField.resignFirstResponder()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        passwordTextField.resignFirstResponder()
        loginTextField.resignFirstResponder()
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
    func recoveryPassword(_ sender: AnyObject)
}

fileprivate protocol Navigation {
    func proceedToTeams()
    func proceedToChat()
}

fileprivate protocol Request {
    func login()
    func loadTeams()
//    func loadChannels()
//    func loadCompleteUsersList()
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
        self.recoveryButton.tintColor = UIColor.kg_lightGrayTextColor()
        self.recoveryButton.setTitleColor(UIColor.kg_lightGrayTextColor(), for:UIControlState())
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
    @IBAction func recoveryPassword(_ sender: AnyObject) {
        proceedToPasswordRecovery()
    }
}


//MARK: Navigation
extension LoginViewController: Navigation {
    func proceedToTeams() {
        let teamViewController = self.storyboard?.instantiateViewController(withIdentifier: "TeamViewController")
        self.navigationController?.pushViewController(teamViewController!, animated: true)
    }
    
    func proceedToPasswordRecovery() {
        let passwordRecoveryController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordRecoveryViewController") as! PasswordRecoveryViewController
        self.navigationController?.pushViewController(passwordRecoveryController, animated: true)
    }
    
    func proceedToChat() {
        RouterUtils.loadInitialScreen()
    }
}


//MARK: Request
extension LoginViewController: Request {
    func login() {
        let topOffset = self.headerView.frame.height
        showLoaderView(topOffset: topOffset, bottomOffset: 0.0)
        passwordTextField.endEditing(false)
        loginTextField.endEditing(false)
        Api.sharedInstance.login(self.loginTextField.text!, password: self.passwordTextField.text!) { (error) in
            guard (error == nil) else {
                var message = (error?.code == -1011) ? "Incorrect email or password!" : (error?.message)!
                if error?.code == 401 { message = "Login failed because of invalid password" }
                
                AlertManager.sharedManager.showErrorWithMessage(message: message)
                self.hideLoaderView()
                self.recoveryButton.tintColor = UIColor.red
                self.recoveryButton.setTitleColor(UIColor.red, for:UIControlState())
                return
            }
            
            if self.loginTextField.isEditing { _ = self.loginTextField.resignFirstResponder() }
            if self.passwordTextField.isEditing { _ = self.passwordTextField.resignFirstResponder() }
            //self.recoveryButton.tintColor = UIColor.kg_lightGrayTextColor()
            self.loadTeams()
        }
    }
    
    func loadTeams() {
        Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
            guard (error == nil) else { self.hideLoaderView(); return }
            
            if userShouldSelectTeam {
                self.hideLoaderView()
                self.proceedToTeams()
            }
            else {
               // self.loadChannels()
                self.loadTeamChannels()
            }
        })
    }
    
    func loadTeamChannels() {
        Api.sharedInstance.loadChannels { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            self.loadPreferedDirectChannelsInterlocuters()
        }
    }
    
    func loadPreferedDirectChannelsInterlocuters() {
        let preferences = Preference.preferedUsersList()
        var usersIds = Array<String>()
        preferences.forEach{ usersIds.append($0.name!) }
        
        Api.sharedInstance.loadUsersListBy(ids: usersIds) { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            self.loadTeamMembers()
        }
    }
    
    func loadTeamMembers() {
        let predicate = NSPredicate(format: "identifier != %@ AND identifier != %@", Preferences.sharedInstance.currentUserId!,
                                    Constants.Realm.SystemUserIdentifier)
        let users = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate)
        var ids = Array<String>()
        users.forEach{ ids.append($0.identifier) }
        
        Api.sharedInstance.loadTeamMembersListBy(ids: ids) { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            Api.sharedInstance.getChannelMembers { (error) in
                guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
                DispatchQueue.main.async {
                    self.hideLoaderView()
                    self.proceedToChat()
                }
            }
        }
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
