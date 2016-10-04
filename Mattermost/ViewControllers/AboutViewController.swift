//
//  AboutViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 29.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class AboutViewController: UIViewController {

//MARK: - Properties
    
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var mattermostTextView: UITextView?
    @IBOutlet weak var kilograppTextView: UITextView?
    
    var iconsResizeAnimationTimer: Timer?
    
    
//MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.iconsResizeAnimationTimer != nil) {
            self.iconsResizeAnimationTimer?.invalidate()
            self.iconsResizeAnimationTimer = nil
        }
    }
}


//MARK: - Setup

extension AboutViewController {
    func initialSetup() {
        setupTitle()
        setupLinks()
    }
    
    func setupTitle() {
        self.title = "About Mattermost"
    }
    
    func setupLinks() {
        let mattermostString = NSMutableAttributedString(string: "Join the Mattermost community at mattermost.org" )
        let kilograppString = NSMutableAttributedString(string: "This application was developed by Kilograpp Team")
        
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


//MARK: -Icon animation

extension AboutViewController {
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
