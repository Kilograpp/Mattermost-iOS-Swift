//
//  AboutViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 29.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class AboutViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var mattermostTextView: UITextView?
    @IBOutlet weak var kilograppTextView: UITextView?
    
    var iconsResizeAnimationTimer: Timer?

//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setupTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        super.viewWillDisappear(animated)
        
        if (self.iconsResizeAnimationTimer != nil) {
            self.iconsResizeAnimationTimer?.invalidate()
            self.iconsResizeAnimationTimer = nil
        }
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupLinks()
    func setupTimer()
}

fileprivate protocol Action {
    func backAction()
}

fileprivate protocol Navigation {
    func returnToChat()
}

fileprivate protocol Helper {
    func iconResizeAnimation()
}


//MARK: Setup
extension AboutViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupLinks()
        self.menuContainerViewController.panMode = .init(0)
    }
    
    func setupNavigationBar() {
        self.title = "About Mattermost"
    }
    
    func setupLinks() {
        let mattermostString = NSMutableAttributedString(string: "Join the Mattermost community at " )
        let kilograppString = NSMutableAttributedString(string: "This application was developed by ")
        
        let mattermostLink = NSAttributedString(string: "mattermost.org", attributes: [NSLinkAttributeName : URL(string: "https://mattermost.org/")!])
        let kilograppLink = NSAttributedString(string: "Kilograpp Team", attributes: [NSLinkAttributeName : URL(string: "http://kilograpp.com/")!])
        
        mattermostString.append(mattermostLink)
        kilograppString.append(kilograppLink)
        
        self.mattermostTextView!.attributedText = mattermostString
        self.kilograppTextView!.attributedText = kilograppString
    }
    
    func setupTimer() {
        self.iconsResizeAnimationTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(iconResizeAnimation), userInfo: nil, repeats: true)
    }
}


//MARK: Action
extension AboutViewController: Action {
    func backAction() {
        returnToChat()
    }
}


//MARK: Navigation
extension AboutViewController: Navigation {
    func returnToChat() {
       _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Helper
extension AboutViewController: Helper {
    func iconResizeAnimation() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.15)
        UIView.setAnimationCurve(UIViewAnimationCurve.easeOut)
        self.iconImageView!.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        UIView.commitAnimations()
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.2)
        UIView.setAnimationCurve(UIViewAnimationCurve.easeOut)
        self.iconImageView!.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.commitAnimations()
    }
}
