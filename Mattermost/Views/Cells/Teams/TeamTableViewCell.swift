//
//  TeamTableViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import WebImage

private protocol Configuration {
    func configureWithTeam(_ team:Team)
}

final class TeamTableViewCell : UITableViewCell, Reusable {

//MARK: Properties
    fileprivate let letterContainerView = UIView()
    fileprivate let letterLabel = UILabel()
    fileprivate let nameLabel = UILabel()
    fileprivate let arrowImageView = UIImageView()
    fileprivate let separatorView = UIView()
    
//MARK: LifeCycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.letterContainerView.frame = CGRect(x: Constants.UI.StandardPaddingSize, y: Constants.UI.LongPaddingSize, width: 40, height: 40)
        
        let width = UIScreen.screenWidth() - self.letterContainerView.frame.maxX - 3 * Constants.UI.StandardPaddingSize - Constants.UI.DoublePaddingSize
        self.nameLabel.frame = CGRect(x: self.letterContainerView.frame.maxX + Constants.UI.StandardPaddingSize,
                                      y: Constants.UI.DoublePaddingSize,
                                      width: width,
                                      height: Constants.UI.DoublePaddingSize)
        
        self.arrowImageView.frame = CGRect(x: self.nameLabel.frame.maxX + Constants.UI.DoublePaddingSize,
                                           y: Constants.UI.DoublePaddingSize,
                                           width: Constants.UI.MiddlePaddingSize,
                                           height: Constants.UI.MiddlePaddingSize + Constants.UI.ShortPaddingSize)
        
        self.separatorView.frame = CGRect(x: 16, y: 59, width: UIScreen.screenWidth() - 16, height: 1)
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.nameLabel.text = nil
        self.letterLabel.text = nil
    }
}


//MARK: Configuration
extension TeamTableViewCell: Configuration {
    func configureWithTeam(_ team: Team) {
        self.letterLabel.text = team.displayName![0]
        let backgroundLayer = self.letterLabel.superview?.layer.sublayers?[0] as! CAGradientLayer
        backgroundLayer.updateLayer(backgroundLayer)
        self.nameLabel.text = team.displayName
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupLetterContainerView()
    func setupLetterLabel()
    func setupNameLabel()
    func setupArrowImageView()
    func setupSeparatorView()
}


//MARK: Setup
extension TeamTableViewCell: Setup {
    func initialSetup() {
        self.selectionStyle = .none
        setupLetterContainerView()
        setupLetterLabel()
        setupNameLabel()
        setupArrowImageView()
        setupSeparatorView()
    }
    
    func setupLetterContainerView() {
        self.letterContainerView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.letterContainerView.layer.cornerRadius = Constants.UI.DoublePaddingSize
        self.letterContainerView.layer.masksToBounds = true
        self.addSubview(self.letterContainerView)
    }
    
    func setupLetterLabel() {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        self.letterLabel.frame = frame
        self.letterLabel.backgroundColor = UIColor.clear
        self.letterLabel.font = FontBucket.letterChannelFont
        self.letterLabel.textColor = ColorBucket.whiteColor
        self.letterLabel.textAlignment = .center
        
        let backgroundView = UIView(frame: frame)
        let layer = CAGradientLayer.blueGradientForAvatarImageView()
        layer.frame = CGRect(x:0, y:0, width:40, height: 40)
        backgroundView.layer.insertSublayer(layer, at: 0)
        backgroundView.addSubview(self.letterLabel)
        
        self.letterContainerView.addSubview(backgroundView)
    }
    
    func setupNameLabel() {
        self.nameLabel.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.nameLabel.backgroundColor = ColorBucket.whiteColor
        self.nameLabel.textColor = ColorBucket.blackColor
        self.nameLabel.font = FontBucket.postAuthorNameFont
        self.addSubview(self.nameLabel)
    }
    
    func setupArrowImageView() {
        self.arrowImageView.image = UIImage(named: "team_arrow_icon")
        self.arrowImageView.frame = CGRect(x: 0, y: 0, width: 8, height: 13)
        self.arrowImageView.backgroundColor = ColorBucket.whiteColor
        self.addSubview(self.arrowImageView)
    }
    
    func setupSeparatorView() {
        self.separatorView.backgroundColor = ColorBucket.separatorViewBackgroundColor
        self.addSubview(self.separatorView)
    }
}
