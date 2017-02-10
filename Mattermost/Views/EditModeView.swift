//
//  CompactPostView.swift
//  Mattermost
//
//  Created by Desubro on 10.02.17.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import QuartzCore

//let SeparatorSize = CGSize(width: 2, height: 38)

private protocol Interface: class {
    func requeredSize() -> CGSize
}


class EditModeView: UILabel {
    
    //MARK: LifeCycle
    class func editModeView() -> EditModeView {
        let editModeView = EditModeView()
        editModeView.initialSetup()
        
        return editModeView
    }
}


//MARK: Interface
extension EditModeView: Interface {
    
    func requeredSize() -> CGSize {
        var width = UIScreen.screenWidth()
        return CGSize(width: width, height: 20.0)
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupBackground()
}


//MARK: Setup
extension EditModeView: Setup {
    func initialSetup() {
        setupBackground()
        self.frame = CGRect(x: Constants.UI.LongPaddingSize, y: Constants.UI.ShortPaddingSize-15.0, width: SeparatorSize.width, height: 15.0)
        self.text = "Editing"
        self.textColor = .white
    }
    
    func setupBackground() {
        self.backgroundColor = UIColor.kg_blueColor()
    }
}
