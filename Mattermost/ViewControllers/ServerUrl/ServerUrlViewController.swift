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
    func viewWillAppear(animated: Bool)
    func viewDidAppear(animated: Bool)
}

final class ServerUrlViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textField: KGTextField!
    @IBOutlet weak var promtLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    let titleName = "Mattermost"
    let promt = "e.g. https://matttermost.example.com"
    let subtitleName = "All your team communication in one place, searchable and accessable anywhere."
    let placeholder = "Your team URL"
    let buttonText = "Next step"
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    func configureLabels() {
        self.titleLabel.text = titleName
        self.promtLabel.text = promt
        self.subtitleLabel.text = subtitleName
    }
    @IBAction func nextButtonAction(sender: AnyObject) {
        Preferences.sharedInstance.serverUrl = self.textField.text
        Api.sharedInstance.checkURL(with: { ( error) in
            if (error != nil) {
                print(error?.message)
                let alert = UIAlertView.init(title: "Error", message: nil, delegate: self, cancelButtonTitle: "Cancel")
                alert.show()
            } else {
                self.performSegueWithIdentifier("showLogin", sender: nil)
            }
        })
    }
    func textFieldAction() {
        if self.textField.text == "" {
            self.nextButton.enabled = false
        } else {
            self.nextButton.enabled = true
        }
    }
}


extension ServerUrlViewController:Lifecycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTitleLabel()
        self.setupSubtitleLabel()
        self.setupPromtLabel()
        self.setupNextButton()
        self.setupTextField()
        self.configureLabels()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.textField.becomeFirstResponder()
    }
    
}

extension ServerUrlViewController:Setup {
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        self.navigationController?.navigationBar.tintColor = ColorBucket.blackColor
        self.navigationController?.navigationBar.barStyle = .Default
        self.setNeedsStatusBarAppearanceUpdate()
        self.title = ""
    }
    
    private func setupTitleLabel() {
        self.titleLabel.font = FontBucket.titleServerUrlFont
        self.titleLabel.textColor = ColorBucket.blackColor
    }

    private func setupSubtitleLabel() {
        self.subtitleLabel.font = FontBucket.subtitleServerUrlFont
        self.subtitleLabel.textColor = ColorBucket.serverUrlSubtitleColor
    }
    
    private func setupPromtLabel() {
        self.promtLabel.font = FontBucket.subtitleServerUrlFont
        self.promtLabel.textColor = ColorBucket.grayColor
    }
    
    private func setupNextButton() {
        self.nextButton.layer.cornerRadius = 2
        self.nextButton.setTitle(buttonText, forState: .Normal)
        self.nextButton.titleLabel?.font = FontBucket.loginButtonFont
        self.nextButton.enabled = false
    }
    
    private func setupTextField() {
        self.textField.delegate = self
        self.textField.textColor = ColorBucket.blackColor
        self.textField.font = FontBucket.loginTextFieldFont
        self.textField.placeholder = placeholder
        self.textField.autocorrectionType = .No
        self.textField.addTarget(self, action: #selector(ServerUrlViewController.textFieldAction), forControlEvents: .EditingChanged)
    }
}