//
//  EmojiTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 07.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol EmojiTableViewCellSetup {

}


class EmojiTableViewCell: UITableViewCell, Reusable {

//MARK: Properties
    internal let thumbnailImageView: UIImageView = UIImageView()
    private let nameLabel: UILabel = UILabel()
    
    fileprivate var indexPath: IndexPath = IndexPath()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func configureWith(name: String!, indexPath: IndexPath!) {
        self.indexPath = indexPath
        self.nameLabel.text = name
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
    }
    
    override func layoutSubviews() {
        //postStatusView.frame = CGRect(x: UIScreen.screenWidth() - Constants.UI.PostStatusViewSize, y: (frame.height - Constants.UI.PostStatusViewSize)/2, width: Constants.UI.PostStatusViewSize, height: Constants.UI.PostStatusViewSize)
        
        //self.align()
        //self.alignSubviews()
    }
}

extension EmojiTableViewCell: EmojiTableViewCellSetup {
    fileprivate func setup() {
        //self.setupBasics()
        //self.setupMessageLabel()
        //setupPostStatusView()
    }
}
