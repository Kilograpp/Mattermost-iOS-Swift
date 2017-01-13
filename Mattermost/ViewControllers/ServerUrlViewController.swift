//
//  ServerUrlViewController.swift
//  Mattermost
//
//  Created by Tatiana on 05/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class ServerUrlViewController: UIViewController, UITextFieldDelegate {

//MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textField: KGTextField!
    @IBOutlet weak var promtLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    let titleName = NSLocalizedString("Mattermost", comment: "")
    let promt = NSLocalizedString("e.g. https://mattermost.example.com", comment: "")
    let error = NSLocalizedString("Url isn't valid", comment: "")
    let subtitleName = NSLocalizedString("All your team communication in one place, searchable and accessable anywhere.", comment: "")
    let placeholder = NSLocalizedString("Your team URL", comment: "")
    let buttonText = NSLocalizedString("Next step", comment: "")

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
        
        _ = self.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _ = self.textField.resignFirstResponder()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    fileprivate func configureLabels() {
        self.titleLabel.text = titleName
        self.promtLabel.text = promt
        self.errorLabel.text = error
        self.subtitleLabel.text = subtitleName
        guard let server = Preferences.sharedInstance.predefinedServerUrl() else {
            return
        }
        self.textField.text = server
        self.nextButton.isEnabled = true
    }
    
    fileprivate func validateServerUrl() {
        let urlRegEx = "((http|https)://){1}((.)*)"
        let urlTest = NSPredicate.init(format: "SELF MATCHES[c] %@", urlRegEx)
        if urlTest.evaluate(with: Preferences.sharedInstance.serverUrl) {
            Api.sharedInstance.checkURL(with: { ( error) in
                if (error != nil) {
                    Api.sharedInstance.checkURL(with: { (error) in
                        self.handleErrorWith(message: Constants.ErrorMessages.message[1])
                    })
                } else {
                    self.performSegue(withIdentifier: "showLogin", sender: nil)
                }
            })
        } else {
            let addres = Preferences.sharedInstance.serverUrl
            var urlAddress = String.init(format: "%@%@", "https://", addres!)
            Preferences.sharedInstance.serverUrl = urlAddress
            Api.sharedInstance.checkURL(with: { ( error) in
                if (error != nil) {
                    urlAddress = String.init(format: "%@%@", "http://", addres!)
                    Preferences.sharedInstance.serverUrl = urlAddress
                    Api.sharedInstance.checkURL(with: { ( error) in
                        if (error != nil) {
                            self.handleErrorWith(message: Constants.ErrorMessages.message[1])
                        } else {
                            self.performSegue(withIdentifier: "showLogin", sender: nil)
                        }
                    })
                } else {
                    self.performSegue(withIdentifier: "showLogin", sender: nil)
                }
            })
        }
    }
    
    fileprivate func validateServerUrlForTextFieldDelegate() {
        let urlRegEx = "((http|https)://)(([a-zA-Z0-9(\\-)])+\\.)([a-zA-Z0-9(\\-)])+((\\.)com)"
        let urlTest = NSPredicate.init(format: "SELF MATCHES[c] %@", urlRegEx)
        if urlTest.evaluate(with: Preferences.sharedInstance.serverUrl) {
            self.errorLabel.isHidden = true
            self.nextButton.isEnabled = true
        } else {
            let addres = Preferences.sharedInstance.serverUrl
            var urlAddress = String.init(format: "%@%@", "https://", addres!)
            Preferences.sharedInstance.serverUrl = urlAddress
            if urlTest.evaluate(with: Preferences.sharedInstance.serverUrl) {
                self.errorLabel.isHidden = true
                self.nextButton.isEnabled = true
            } else {
                self.errorLabel.isHidden = false
                self.nextButton.isEnabled = false
            }
        }
    }
}


private protocol Setup {
    func initialSetup()
    func setupTitleLabel()
    func setupSubtitleLabel()
    func setupPromtLabel()
    func setupErrorLabel()
    func setupNextButton()
    func setupTextField()
    func setupNavigationBar()
}

private protocol Actions {
    func nextButtonAction(_ sender: AnyObject)
    func textFieldAction()
}


//MARK: Setup
extension ServerUrlViewController:Setup {
    fileprivate func initialSetup() {
        setupTitleLabel()
        setupSubtitleLabel()
        setupPromtLabel()
        setupErrorLabel()
        setupNextButton()
        setupTextField()
        configureLabels()
    }
    
    fileprivate func setupNavigationBar() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        self.navigationController?.navigationBar.tintColor = ColorBucket.blackColor
        self.navigationController?.navigationBar.barStyle = .default
        self.setNeedsStatusBarAppearanceUpdate()
        self.title = ""
    }
    
    fileprivate func setupTitleLabel() {
        self.titleLabel.font = FontBucket.titleServerUrlFont
        self.titleLabel.textColor = ColorBucket.blackColor
    }
    
    fileprivate func setupSubtitleLabel() {
        self.subtitleLabel.font = FontBucket.subtitleServerUrlFont
        self.subtitleLabel.textColor = ColorBucket.serverUrlSubtitleColor
    }
    
    fileprivate func setupPromtLabel() {
        self.promtLabel.font = FontBucket.subtitleServerUrlFont
        self.promtLabel.textColor = ColorBucket.grayColor
    }
    
    fileprivate func setupErrorLabel() {
        self.errorLabel.isHidden = true
        self.errorLabel.font = FontBucket.subtitleServerUrlFont
        self.errorLabel.textColor = ColorBucket.errorAlertColor
    }
    
    fileprivate func setupNextButton() {
        self.nextButton.layer.cornerRadius = 2
        self.nextButton.setTitle(buttonText, for: UIControlState())
        self.nextButton.titleLabel?.font = FontBucket.loginButtonFont
        self.nextButton.isEnabled = false
    }
    
    fileprivate func setupTextField() {
        self.textField.delegate = self
        self.textField.textColor = ColorBucket.blackColor
        self.textField.font = FontBucket.loginTextFieldFont
        self.textField.placeholder = placeholder
        self.textField.autocorrectionType = .no
        self.textField.addTarget(self, action: #selector(ServerUrlViewController.textFieldAction), for: .editingChanged)
    }
}


//MARK: Actions
extension ServerUrlViewController: Actions {
    @IBAction func nextButtonAction(_ sender: AnyObject) {
        guard Api.sharedInstance.isNetworkReachable() else { self.handleErrorWith(message: "No Internet connectivity detected"); return }
        Preferences.sharedInstance.serverUrl = self.textField.text
        validateServerUrl()
    }
    
    func textFieldAction() {
        Preferences.sharedInstance.serverUrl = self.textField.text
        self.validateServerUrlForTextFieldDelegate()
    }
}
