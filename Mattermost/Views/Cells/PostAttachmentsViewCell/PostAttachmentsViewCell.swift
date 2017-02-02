//
//  PostAttachmentsViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class PostAttachmentsViewBaseCell : UICollectionViewCell {
    static var identifier: String = String(describing: self)
    static let itemSize = CGSize(width: 70, height: 70)
    let removeButton = UIButton()
    let progressView = UIProgressView()
    var item: AssignedAttachmentViewItem?
    
    var removeTapHandler : ((_ image: AssignedAttachmentViewItem) -> Void)?
    var index: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRemoveButton()
        setupProgressView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRemoveButton() {
        self.addSubview(self.removeButton)
        self.removeButton.setBackgroundImage(UIImage(named: "attach_delete_icon"), for: UIControlState())
        
        self.removeButton.addTarget(self, action: #selector(removeButtonAction), for: .touchUpInside)
    }
    
    private func setupProgressView() {
        self.progressView.progress = 0
        self.addSubview(self.progressView)
    }
    
    func removeButtonAction() {
        guard let handler = removeTapHandler, let item = item else {return}
        
        handler(item)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maxX = bounds.maxX
        let dim = CGFloat(20)
        removeButton.frame = CGRect(x: maxX - dim, y: 0, width: dim, height: dim)
        progressView.frame = CGRect(x: 15, y: 57, width: 40, height: 2)
    }
    
    func configureWithItem(_ item: AssignedAttachmentViewItem) {
        self.progressView.isHidden = item.uploaded
        self.item = item
    }
    
    func updateProgressViewWithValue(_ value: Float) {
        self.progressView.progress = value
        self.progressView.isHidden = (value == 1)
    }
    
    override func prepareForReuse() {
        self.progressView.progress = 0
        self.progressView.isHidden = true
    }
}




class PostImageViewCell : PostAttachmentsViewBaseCell {
    let backgroundImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackgroundImage() {
        self.backgroundImageView.layer.cornerRadius = 6
        self.backgroundImageView.clipsToBounds = true
        self.backgroundImageView.contentMode = .scaleAspectFill
        insertSubview(backgroundImageView, belowSubview: removeButton)
    }
    
    override func configureWithItem(_ item: AssignedAttachmentViewItem) {
        super.configureWithItem(item)
        self.progressView.isHidden = item.uploaded
        self.item = item
        self.backgroundImageView.image = item.image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundImageView.frame = CGRect(x: 5, y: 5, width: PostAttachmentsViewBaseCell.itemSize.width - 10, height: PostAttachmentsViewBaseCell.itemSize.height - 10)
    }
}
