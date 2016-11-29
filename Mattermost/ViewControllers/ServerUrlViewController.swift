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
    @IBOutlet weak var nextButton: UIButton!
    
    let titleName = NSLocalizedString("Mattermost", comment: "")
    let promt = NSLocalizedString("e.g. https://mattermost.example.com", comment: "")
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    fileprivate func configureLabels() {
        self.titleLabel.text = titleName
        self.promtLabel.text = promt
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
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
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
                            AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
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
}


private protocol Setup {
    func initialSetup()
    func setupTitleLabel()
    func setupSubtitleLabel()
    func setupPromtLabel()
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
        Preferences.sharedInstance.serverUrl = self.textField.text
        validateServerUrl()
    }
    
    func textFieldAction() {
        self.nextButton.isEnabled = (self.textField.text != "")
    }
}
