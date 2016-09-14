//
//  SearchingInProcessView.swift
//  Mattermost
//
//  Created by TaHyKu on 12.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Setup {
    func setupAnimationWithBaseName(baseName: String)
}

struct AnimationsBase {
    static let Monkey = "monkey"
}

class SearchingInProcessView: UIView {

    
//MARK: Properties
    
    @IBOutlet weak var animationImageView: UIImageView!
  
    
//MARK: Life cycle
    
    class func monkeyChatSearchView() -> SearchingInProcessView {
       let searchingInProcessView = NSBundle.mainBundle().loadNibNamed("SearchingInProcessView", owner: nil, options: nil)[0]
        searchingInProcessView.setupAnimationWithBaseName(AnimationsBase.Monkey)
        
        return searchingInProcessView as! SearchingInProcessView
    }
}


//MARK: Setup

extension SearchingInProcessView: Setup {
    func setupAnimationWithBaseName(baseName: String) {
        self.animationImageView.image = UIImage.gifWithName(baseName)
        hide()
    }
}


//MARK: Public

extension SearchingInProcessView {
    func show() {
        self.animationImageView.startAnimating()
        self.hidden = false
    }
    
    func hide() {
        self.animationImageView.stopAnimating()
        self.hidden = true
    }
}