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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = UIStatusBarStyle.default
    }
    
    func setupNavigationBar()  {
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = ColorBucket.whiteColor
  
    }
    
    func setupTitleLabel() {
        self.titleLabel = UILabel(frame: (CGRect(x: 0, y: 11, width: titleView.bounds.width - 30, height: 22)))
        self.titleLabel.numberOfLines = 1
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.textColor = ColorBucket.blackColor
        titleLabel.lineBreakMode = .byClipping
        self.titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        self.titleView.addSubview(self.titleLabel!)
    }
    
    //todo NavigationBarTitleView
    func setupTitleView() {
        //self.titleView = KGNavigationBarTitleView
        self.titleView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth()*0.6, height: 44))
        self.navigationBar.topItem?.titleView = self.titleView
        titleView.clipsToBounds = true
    }
    
    
    
    func setupGestureRecognizer() {
        self.titleLabel.isUserInteractionEnabled = true
        self.titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapOnTitleAction)))
    }
    
    func tapOnTitleAction() {
        self.chatNavigationDelegate?.didSelectTitle()
    }
    
    func configureTitleViewWithCannel(_ channel: Channel, loadingInProgress: Bool) {
       // temp
        self.titleLabel.text = channel.displayName
        titleLabel.sizeToFit()
        titleView.layoutSubviews()
    }
    
 //UINavigationControllerDelegate
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
}

//MARK: - ChatNavigationDelegate
protocol ChatNavigationDelegate {
    func didSelectTitle()
}
