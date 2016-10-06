//
//  SearchingInProcessView.swift
//  Mattermost
//
//  Created by TaHyKu on 12.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
// FIXME: CodeReview: Приватные протоколы должны находиться внизу, после определения класса
// Иерархия следования: public protocol -> class -> private protocol -> extensions
private protocol Setup {
    func setupAnimationWithBaseName(_ baseName: String)
}

struct AnimationsBase {
    static let Monkey = "monkey"
}

class SearchingInProcessView: UIView {

//MARK: Properties
    
    @IBOutlet weak var animationImageView: UIImageView!
  
//MARK: Life cycle
    
    class func monkeyChatSearchView() -> SearchingInProcessView {

       let searchingInProcessView = Bundle.main.loadNibNamed("SearchingInProcessView", owner: nil, options: nil)?[0] as! SearchingInProcessView
        searchingInProcessView.setupAnimationWithBaseName(AnimationsBase.Monkey)
        
        return searchingInProcessView 
    }
}


//MARK: Setup

extension SearchingInProcessView: Setup {
    func setupAnimationWithBaseName(_ baseName: String) {
        self.animationImageView.image = UIImage.gifWithName(baseName)
        hide()
    }
}


//MARK: Public

extension SearchingInProcessView {
    func show() {
        self.animationImageView.startAnimating()
        self.isHidden = false
    }
    
    func hide() {
        self.animationImageView.stopAnimating()
        self.isHidden = true
    }
}
