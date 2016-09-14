//
//  SearchChatTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 13.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

struct Geometry {
    static let AvatarDimension: CGFloat = 40.0
    static let StandartPadding: CGFloat = 8.0
    static let SmallPadding: CGFloat    = 5.0
    static let LoadingViewSize: CGFloat = 22.0
    static let ErrorViewSize: CGFloat   = 34.0
}

private protocol Setup {

}

private protocol Private {

}

private protocol Configuration {

}

private protocol Action {

}

public protocol Public {

}

class SearchChatTableViewCell: UITableViewCell {

//MARK: Properties
    private let channelLabel: UILabel = UILabel()
    private let avatarImageView: UIImageView = UIImageView()
    private let nameLabel: UILabel = UILabel()
    private let dateLabel: UILabel = UILabel()
    private let messageLabel: UILabel = UILabel() // ActiveLabel in original
    private let detailIconImageView: UIImageView = UIImageView()
    private let loadingView: UIView = UIView() // DGActivityIndicatorView in original
    private let messageOperation: NSBlockOperation
    
    private let dateString: String
    
    
//MARK: Life cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        
    }
}


//MARK: Setup

extension SearchChatTableViewCell: Setup {
    func initialSetup() {
        
    }
    
    func setupBackground() {
        self.selectionStyle = .None
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func setupChannelLabel() {
        configureLabel(self.channelLabel, font: UIFont.kg_semibold13Font(), color: UIColor.kg_lightBlackColor())
        self.addSubview(self.channelLabel)
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.frame = CGRectMake(8, 8, 40, 40)
        self.avatarImageView.backgroundColor = UIColor.whiteColor()
        self.avatarImageView.contentMode = .ScaleAspectFill
        self.avatarImageView.userInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfileAction)))
        self.addSubview(self.avatarImageView)
    }
    
    func setupNameLabel() {
        configureLabel(self.nameLabel, font: UIFont.kg_semibold15Font(), color: UIColor.kg_lightBlackColor())
        self.nameLabel.userInteractionEnabled = true
        self.nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfileAction)))
        self.addSubview(self.nameLabel)
    }
    
    func setupDateLabel() {
        configureLabel(self.dateLabel, font: UIFont.kg_regular13Font(), color: UIColor.kg_lightGrayTextColor())
        self.addSubview(self.dateLabel)
    }
    
    func setupMessageLabel() {
        
    }
    
    func setupDetailIconImageView() {
        
    }
    
    func setupLoadingView() {
        
    }
    
    func setupErrorView() {
        
    }
}


//MARK: Configuration

extension SearchChatTableViewCell: Configuration {
    func configureLabel(label: UILabel, font: UIFont, color: UIColor) {
        label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        label.numberOfLines = 1
        label.backgroundColor = UIColor.whiteColor()
        label.font = font
        label.textColor = color
    }
    
    func configureCellState() {
        
    }
    
    func configureBasicLabels() {
        
    }
    
    func configureMessageOperation() {
        
    }
    
    func configureAvatarImage() {
        
    }
}


//MARK: Action

extension SearchChatTableViewCell: Action {
    func showProfileAction() {
        
    }
}


//MARK: Public

extension SearchChatTableViewCell: Public {
    func configureWithPost(post: Post) {
        
    }
    
    func heighWithPost(post: Post) -> CGFloat {
        return 0.0
    }

    func errorAction() {
        
    }
}
