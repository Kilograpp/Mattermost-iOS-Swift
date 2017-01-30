//
//  GitLabViewController.swift
//  Mattermost
//
//  Created by Art on 24/01/2017.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import UIKit
import SafariServices

class GitLabViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: Preferences.sharedInstance.serverUrl!)!
        webView.loadRequest(URLRequest(url: url))
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        dismiss(animated: true) { }
    }
}

extension GitLabViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if UserStatusManager.sharedInstance.isSignedIn() {
            dismiss(animated: true) { }
        }
    }
}
