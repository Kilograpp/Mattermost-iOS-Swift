//
//  ChatNavigationController.swift
//  Mattermost
//
//  Created by Mariya on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class ChatNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    var titleLabel : UILabel?
    var titleView : UIView?
    var actitvityIndicatorView : UIView?
    
    
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
        self.titleView = UIView(frame: CGRectMake(0, 0, UIScreen.screenWidth()*0.6, 44))
        self.navigationBar.topItem?.titleView = self.titleView
    }
    
    func setupGestureRecognizer() {
        
    }
    
    func configureTitleViewWithCannel(channel: Channel, loadingInProgress: Bool) {
       
    }
    
 //UINavigationControllerDelegate
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

}
