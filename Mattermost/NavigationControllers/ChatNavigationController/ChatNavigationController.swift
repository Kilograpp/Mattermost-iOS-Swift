//
//  ChatNavigationController.swift
//  Mattermost
//
//  Created by Mariya on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

fileprivate protocol Configuration: class {
    func configureTitleViewWithCannel(_ channel: Channel, loadingInProgress: Bool)
}


class ChatNavigationController: UINavigationController, UINavigationControllerDelegate {

//MARK: Properties
    var titleLabel : UILabel!
    var titleView : UIView!
    var actitvityIndicatorView : UIView?
    var chatNavigationDelegate : ChatNavigationDelegate?

//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = UIStatusBarStyle.default
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}


extension ChatNavigationController: Configuration {
    func configureTitleViewWithCannel(_ channel: Channel, loadingInProgress: Bool) {
        self.titleLabel.text = channel.displayName
        self.titleLabel.sizeToFit()
        self.titleView.layoutSubviews()
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func setupTitleLabel()
    func setupTitleView()
    func setupGestureRecognizer()
}

fileprivate protocol Action: class {
    func tapOnTitleAction()
}


//MARK: Setup
extension ChatNavigationController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupTitleView()
        setupTitleLabel()
        setupGestureRecognizer()
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
}


//MARK: Action
extension ChatNavigationController: Action {
    func tapOnTitleAction() {
        self.chatNavigationDelegate?.didSelectTitle()
    }
}


//MARK: ChatNavigationDelegate
protocol ChatNavigationDelegate {
    func didSelectTitle()
}
