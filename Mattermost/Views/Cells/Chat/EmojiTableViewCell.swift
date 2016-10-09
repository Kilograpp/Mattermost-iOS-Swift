//
//  EmojiTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 07.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import TSMarkdownParser

private protocol EmojiTableViewCellSetup {

}


class EmojiTableViewCell: UITableViewCell, Reusable {

//MARK: Properties
    fileprivate var thumbnailLabel = MessageLabel()
    fileprivate var nameLabel = UILabel()
    
    fileprivate var indexPath: IndexPath = IndexPath()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func configureWith(index: Int!) {
        let attributedString = TSMarkdownParser.sharedInstance.attributedString(fromMarkdown: Constants.EmojiArrays.apple[index])
        self.thumbnailLabel.textStorage = NSTextStorage(attributedString: attributedString)
        self.nameLabel.text = Constants.EmojiArrays.mattermost[index]
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
        self.thumbnailLabel.textStorage = nil
        self.nameLabel.text = nil
    }
    
    override func layoutSubviews() {
        self.thumbnailLabel.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        self.nameLabel.frame = CGRect(x: 50, y: 5, width: 60, height: 20)
        
        self.align()
        self.alignSubviews()
    }
}

extension EmojiTableViewCell: EmojiTableViewCellSetup {
    func setup() {
        setupThumbnailLabel()
        setupNameLabel()
        //self.setupBasics()
        //self.setupMessageLabel()
        //setupPostStatusView()
    }
    
    func setupThumbnailLabel() {
        self.addSubview(self.thumbnailLabel)
    }
    
    func setupNameLabel() {
        self.addSubview(self.nameLabel)
    }
}
