//
//  ChatNavigationController.swift
//  Mattermost
//
//  Created by Mariya on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class ChatNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    var titleLabel : UILabel!
    var titleView : UIView!
    var actitvityIndicatorView : UIView?
    var chatNavigationDelegate : ChatNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTitleView()
        setupTitleLabel()
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIStatusBarStyle.Default
    }
    
    func setupNavigationBar()  {
        self.navigationBar.translucent = false
        self.navigationBar.barTintColor = ColorBucket.whiteColor
  
    }
    
    func setupTitleLabel() {
        self.titleLabel = UILabel(frame: (CGRectMake(0, 11, CGRectGetWidth(titleView.bounds) - 30, 22)))
        self.titleLabel.numberOfLines = 1
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.textColor = ColorBucket.blackColor
        titleLabel.lineBreakMode = .ByClipping
        self.titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        self.titleView.addSubview(self.titleLabel!)
    }
    
    //todo NavigationBarTitleView
    func setupTitleView() {
        //self.titleView = KGNavigationBarTitleView
        self.titleView = UIView(frame: CGRectMake(0, 0, UIScreen.screenWidth()*0.6, 44))
        self.navigationBar.topItem?.titleView = self.titleView
        titleView.clipsToBounds = true
    }
    
    
    
    func setupGestureRecognizer() {
        self.titleLabel.userInteractionEnabled = true
        self.titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapOnTitleAction)))
    }
    
    func tapOnTitleAction() {
        self.chatNavigationDelegate?.didSelectTitle()
    }
    
    func configureTitleViewWithCannel(channel: Channel, loadingInProgress: Bool) {
       // temp
        self.titleLabel.text = channel.displayName
        titleLabel.sizeToFit()
        titleView.layoutSubviews()
    }
    
 //UINavigationControllerDelegate
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}

//MARK: - ChatNavigationDelegate
protocol ChatNavigationDelegate {
    func didSelectTitle()
}
