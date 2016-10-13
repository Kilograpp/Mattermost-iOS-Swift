//
//  AlertView.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 10.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


class AlertView: UIView {
    
    let messageLabel = UILabel()
    var message: String?
    var presentingViewController: UIViewController!
    
    init(type:AlertType, message:String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        setupMessage(message: message)
        setupFrame()
        setupDuration()
        setupMessageLabel()
        setupBackgroud(for: type)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private protocol Setup {
    func setupMessage(message:String)
    func setupFrame()
    func setupDuration()
    func setupBackgroud(for type:AlertType)
    func setupMessageLabel()
}

extension AlertView: Setup {
    func setupFrame() {
        self.frame = CGRect(x: 0, y: -(self.heightWithMessage()), width: UIScreen.screenWidth(), height: self.heightWithMessage())
    }
    
    func setupDuration() {
        
    }
    
    func setupMessage(message:String) {
        self.message = message
    }
    
    func setupMessageLabel() {
        self.messageLabel.font = UIFont.boldSystemFont(ofSize: 13)
        self.messageLabel.textColor = UIColor.white
        self.messageLabel.frame = CGRect(x: 5, y: 5, width: self.bounds.width - 5, height: self.bounds.height - 5)
        self.messageLabel.text = message
        self.addSubview(messageLabel)
        //TODO: constraints
    }
    
    func setupBackgroud(for type:AlertType) {
        var backgroundColor = UIColor.brown
        switch (type) {
        case .success:
            backgroundColor = ColorBucket.successAlertColor
        case .error:
            backgroundColor = ColorBucket.errorAlertColor
        case .warning:
            backgroundColor = ColorBucket.warningAlertColor
            
        default:
            break
        }
        self.backgroundColor = backgroundColor
    }
    
}


extension AlertView {
    //TODO: Сделать вычисление высоты месседжа
    func heightWithMessage() -> CGFloat {
        return 60
    }
    
    func addToSuperview() {
//        self.presentingViewController.view.addSubview(self)
        self.presentingViewController.navigationController?.view.addSubview(self)
    }
    
    func hideAlertView(animated: Bool) {
        UIView.animate(withDuration: 0.3, delay: 3, options: .curveEaseOut, animations: {
            var frameNew = self.frame;
            frameNew.origin.y = frameNew.origin.y - self.heightWithMessage();
            self.frame = frameNew;
            }) { (finished) in
                self.removeFromSuperview()
        }
        
    }
    
    func showAlertView(animated: Bool) {
        self.addToSuperview()
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn, animations: {
            var frameNew = self.frame;
            frameNew.origin.y = frameNew.origin.y + self.heightWithMessage();
            self.frame = frameNew;
        }) { (finished) in
            self.hideAlertView(animated: animated)
        }
    }
    
    //TODO: добавить действие по тапу
}
