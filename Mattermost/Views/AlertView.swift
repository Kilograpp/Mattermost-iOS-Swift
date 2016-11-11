//
//  AlertView.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 10.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

protocol AlertViewInterface {
    func height() -> CGFloat
    func hideAlertView(animated: Bool)
    func showAlertView(animated: Bool)
}

class AlertView: UIView {

//MARK: Properties
    let iconImageView = UIImageView()
    let messageLabel = UILabel()
    var message: String?
    var presentingViewController: UIViewController!
    
//MARK: LifeCycle
    init(type: AlertType, message: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        initialSetup(type: type, message: message)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: Interface
extension AlertView: AlertViewInterface {
    func height() -> CGFloat {
        return CGFloat(46 + labelHeight())
    }
    
    func hideAlertView(animated: Bool) {
        UIView.animate(withDuration: 0.3, delay: 3, options: .curveEaseOut, animations: {
            var frameNew = self.frame
            frameNew.origin.y = frameNew.origin.y - self.height()
            self.frame = frameNew
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    func showAlertView(animated: Bool) {
        UIApplication.shared.keyWindow?.addSubview(self)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn, animations: {
            var frameNew = self.frame;
            frameNew.origin.y = frameNew.origin.y + self.height()//WithMessage();
            self.frame = frameNew;
        }) { (finished) in
            self.hideAlertView(animated: animated)
        }
    }
    
//TODO: Add action by tap
}


fileprivate protocol Setup {
    func initialSetup(type: AlertType, message: String)
    func setupMessage(message:String)
    func setupFrame()
    func setupDuration()
    func setupBackgroud(for type:AlertType)
    func setupMessageLabel()
}


//MARK: Setup
extension AlertView: Setup {
    func initialSetup(type: AlertType, message: String) {
        setupMessage(message: message)
        setupFrame()
        setupIcon(type: type)
        setupDuration()
        setupMessageLabel()
        setupBackgroud(for: type)
    }
    
    func setupFrame() {
        self.frame = CGRect(x: 0, y: -(height()), width: UIScreen.screenWidth(), height: height())
    }
    
    func setupDuration() {
        
    }
    
    func setupBackgroud(for type:AlertType) {
        switch type {
        case .success:
            self.backgroundColor = ColorBucket.successAlertColor
        case .error:
            self.backgroundColor = ColorBucket.errorAlertColor
        case .warning:
            self.backgroundColor = ColorBucket.warningAlertColor
        }
    }

    func setupIcon(type: AlertType) {
        let y = (height() - 24) / 2
        self.iconImageView.frame = CGRect(x: 16, y: y, width: 24, height: 24)
        
        switch type {
        case .success:
            self.iconImageView.image = UIImage(named: "alert_attation_icon")
        case .error:
            self.iconImageView.image = UIImage(named: "alert_error_icon")
        case .warning:
            self.iconImageView.image = UIImage(named: "alert_attation_icon")
        }
        self.addSubview(self.iconImageView)
    }

    func setupMessage(message:String) {
        self.message = message
    }
    
    func setupMessageLabel() {
        self.messageLabel.font = UIFont.boldSystemFont(ofSize: 13)
        self.messageLabel.textColor = UIColor.white
        self.messageLabel.numberOfLines = 0
        self.messageLabel.frame = CGRect(x: 52, y: 23, width: labelWidth(), height: labelHeight())
        self.messageLabel.text = message
        self.addSubview(messageLabel)
        //TODO: constraints
    }
    
    fileprivate func labelWidth() -> CGFloat {
        return UIScreen.screenWidth() - 68
    }
    
    fileprivate func labelHeight() -> CGFloat {
        let width = labelWidth()
        return CGFloat(StringUtils.heightOfString(self.message!, width: width, font: FontBucket.alertFont))
    }
}
