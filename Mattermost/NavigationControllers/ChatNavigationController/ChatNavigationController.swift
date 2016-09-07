//
//  ChatNavigationController.swift
//  Mattermost
//
//  Created by Mariya on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
//import ChatNavigationBarTitleView

protocol ChatNavigationControllerDelegate {
    func didSelectTitleView() -> Void
}

class ChatNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    var titleLabel : UILabel?
    var titleView : ChatNavigationBarTitleView?
    var actitvityIndicatorView :UIView?
    
    var chatNavControllerDelegate : ChatNavigationControllerDelegate? {
        didSet {
            //self.chatNavControllerDelegate?.didSelectTitleView()
        }
    }
    
    public init() {
        super.init(coder: NSCoder.init())!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTitleLabel()
        setupTitleView()
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIStatusBarStyle.Default
    }
    
    
    
    internal func configureTitleViewWithCannel(channel: Channel, loadingInProgress: Bool) {
       self.titleView?.configureWithChannel(channel, loadingInProgress: loadingInProgress)
        
    }
    
    func showMembers() {
        self.chatNavControllerDelegate?.didSelectTitleView()
    }
    

    
 //UINavigationControllerDelegate
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

}

private protocol Setup {
    func setupNavigationBar()
    func setupTitleLabel()
    func setupTitleView()
    func setupGestureRecognizer()
}

extension ChatNavigationController : Setup {
    func setupNavigationBar()  {
        self.navigationBar.translucent = false
        self.navigationBar.barTintColor = ColorBucket.whiteColor
        
    }
    
    func setupTitleLabel() {
        self.titleLabel = UILabel(frame: (CGRectMake(0, 4, UIScreen.screenWidth()*0.6, 22)))
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        self.titleLabel?.textColor = ColorBucket.blackColor
    }
    
    func setupTitleView() {
        //self.titleView = KGNavigationBarTitleView
        self.titleView = ChatNavigationBarTitleView.init()
        self.titleView?.frame = CGRectMake(0, 0, CGRectGetHeight(UIScreen .mainScreen().bounds) * 0.6, 44)
        self.navigationBar.topItem?.titleView = self.titleView
    }
    
    func setupGestureRecognizer() {
        self.titleView?.titleLabel?.userInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMembers))
        self.titleView?.titleLabel?.addGestureRecognizer(tapGestureRecognizer)
    }
}