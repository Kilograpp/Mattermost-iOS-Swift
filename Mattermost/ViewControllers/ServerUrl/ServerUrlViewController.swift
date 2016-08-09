//
//  ServerUrlViewController.swift
//  Mattermost
//
//  Created by Tatiana on 05/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
//import KGTextField

class ServerUrlViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textField: KGTextField!
    @IBOutlet weak var promtLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTitleLabel()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
       // self.loginTextField.becomeFirstResponder()
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
    
    }
