//
//  KGTextField.swift
//  Mattermost
//
//  Created by Tatiana on 05/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import SkyFloatingLabelTextField

class KGTextField: SkyFloatingLabelTextField, UITextFieldDelegate {
    internal let underLineView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupPlaceholder()
    }
    
    
    //MARK - Setup
    
    func setupPlaceholder() {
        self.lineColor = ColorBucket.lightGrayColor
        self.selectedLineColor = ColorBucket.blueColor
        self.selectedTitleColor = ColorBucket.grayColor
        self.titleColor = ColorBucket.lightGrayColor
        self.lineHeight = 1
        self.selectedLineHeight = 1
        
        
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.underLineView.backgroundColor = ColorBucket.lightGrayColor
        //self.addSubview(self.underLineView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.underLineView.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)
    }
    
    
    //MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.underLineView.backgroundColor = ColorBucket.blueColor
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.underLineView.backgroundColor = ColorBucket.lightGrayColor
    }
}