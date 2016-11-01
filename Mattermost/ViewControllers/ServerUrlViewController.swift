//
//  ServerUrlViewController.swift
//  Mattermost
//
//  Created by Tatiana on 05/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
//import KGTextField

private protocol Setup {
    func setupTitleLabel()
    func setupSubtitleLabel()
    func setupPromtLabel()
    func setupNextButton()
    func setupTextField()
    func setupNavigationBar()
}

private protocol Lifecycle {
    func viewDidLoad()
    func viewWillAppear(_ animated: Bool)
    func viewDidAppear(_ animated: Bool)
}

private protocol Actions {
    func nextButtonAction(_ sender: AnyObject)
    func textFieldAction()
}
final class ServerUrlViewController: UIViewController, UITextFieldDelegate {
    
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
                    let alert = UIAlertView.init(title: NSLocalizedString("Error", comment: ""), message: nil, delegate: self,
                        cancelButtonTitle: NSLocalizedString("Cancel", comment: ""))
                    alert.show()
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
                            let alert = UIAlertView.init(title: NSLocalizedString("Error", comment: ""), message: nil, delegate: self,
                                cancelButtonTitle: NSLocalizedString("Cancel", comment: ""))
                            alert.show()
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


//MARK: - Actions 

extension ServerUrlViewController:Actions {
    @IBAction func nextButtonAction(_ sender: AnyObject) {
        Preferences.sharedInstance.serverUrl = self.textField.text
//FIXME: вызов методов не должен быть через self
        self.validateServerUrl()
    }
    
    func textFieldAction() {
        if self.textField.text == "" {
            self.nextButton.isEnabled = false
        } else {
            self.nextButton.isEnabled = true
        }
    }
}

//MARK: - Lifecycle

extension ServerUrlViewController:Lifecycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
//FIXME: вызов методов не должен быть через self
        self.setupTitleLabel()
        self.setupSubtitleLabel()
        self.setupPromtLabel()
        self.setupNextButton()
        self.setupTextField()
        self.configureLabels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//FIXME: вызов методов не должен быть через self
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = self.textField.becomeFirstResponder()
    }
    
}


//MARK: - Setup

extension ServerUrlViewController:Setup {
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
