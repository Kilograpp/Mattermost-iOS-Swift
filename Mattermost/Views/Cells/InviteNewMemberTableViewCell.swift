//
//  InviteNewMemberTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 27.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

protocol InviteNewMemberTableViewCellConfiguration {
    func configureWithIcon(_ icon: UIImage, placeholder: String, text: String)
}

class InviteNewMemberTableViewCell: UITableViewCell, Reusable {

//MARK: Properties
    
    fileprivate let iconImageView = UIImageView()
    let textField = UITextField()
   
    
//MARK: LifeCycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        let width = UIScreen.screenWidth() - self.iconImageView.frame.maxX - 30
        self.textField.frame = CGRect(x: (self.iconImageView.frame.maxX + 15), y: 7, width: width, height: 30)
        super.layoutSubviews()
    }
}


extension InviteNewMemberTableViewCell: InviteNewMemberTableViewCellConfiguration {
    func configureWithIcon(_ icon: UIImage, placeholder: String, text: String) {
        self.iconImageView.image = icon
        self.textField.placeholder = placeholder
        self.textField.text = text
    }
}


private protocol InviteNewMemberTableViewCellSetup {
    func initialSetup()
    func setupIconImageView()
    func setupTextField()
}


//MARK: InviteNewMemberTableViewCellSetup

extension InviteNewMemberTableViewCell: InviteNewMemberTableViewCellSetup {
    func initialSetup() {
        setupIconImageView()
        setupTextField()
    }
    
    func setupIconImageView() {
        self.iconImageView.frame = CGRect(x: 15, y: 10, width: 24, height: 24)
        self.addSubview(self.iconImageView)
    }
    
    func setupTextField() {
        let width = UIScreen.screenWidth() - self.iconImageView.frame.maxX - 30
        self.textField.frame = CGRect(x: (self.iconImageView.frame.maxX + 15), y: 7, width: width, height: 30)
        self.textField.textColor = ColorBucket.blackColor
        self.textField.font = FontBucket.messageFont
        self.textField.borderStyle = .none
        self.addSubview(self.textField)
    }
}
