//
//  KGTextField.swift
//  Mattermost
//
//  Created by Tatiana on 05/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import SkyFloatingLabelTextField

// FIXME: CodeReview:  делегат? файнал
final class KGTextField: SkyFloatingLabelTextField, UITextFieldDelegate {
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
}