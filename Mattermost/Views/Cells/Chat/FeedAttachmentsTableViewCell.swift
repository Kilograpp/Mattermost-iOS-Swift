//
//  FeedAttachmentsTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import WebImage
import RealmSwift

final class FeedAttachmentsTableViewCell: FeedCommonTableViewCell {

    fileprivate let tableView = UITableView()
    fileprivate var attachments : List<File>!
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: Setup
    
    func setupTableView() -> Void {
        self.tableView.scrollsToTop = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        self.tableView.isScrollEnabled = false
        
        self.tableView.register(AttachmentImageCell.self, forCellReuseIdentifier: AttachmentImageCell.reuseIdentifier, cacheSize: 7)
        self.tableView.register(AttachmentFileCell.self, forCellReuseIdentifier: AttachmentFileCell.reuseIdentifier, cacheSize: 7)
        self.addSubview(self.tableView)
    }
    
    
    //MARK: Lifecycle
    
    override func layoutSubviews() {
        self.tableView.frame = CGRect(x: 53,
                                          y: self.messageLabel.frame.maxY + 8,
                                          width: UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize,
                                          height: self.tableView.contentSize.height)
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    //MARK: Private
    
    fileprivate class func tableViewHeightWithPost(_ post: Post) -> CGFloat {
        let height = post.files.reduce(0) {
            (total, file) in
            total + (file.isImage ? (UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings)*0.56 - 5 : 56)
        }
        return height
    }

}

extension FeedAttachmentsTableViewCell {
    override func configureWithPost(_ post: Post) {
        super.configureWithPost(post)
        self.attachments = self.post.files
        self.tableView.reloadData()
    }
    
    override class func heightWithPost(_ post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 44 + 8 + FeedAttachmentsTableViewCell.tableViewHeightWithPost(post)
    }
}

extension FeedAttachmentsTableViewCell : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.attachments != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attachments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //FIXME: CodeReview: Убрать инит
        let file = self.attachments[indexPath.row]
        if file.isImage {
            return self.tableView.dequeueReusableCell(withIdentifier: AttachmentImageCell.reuseIdentifier) as! AttachmentImageCell
        } else {
            return self.tableView.dequeueReusableCell(withIdentifier: AttachmentFileCell.reuseIdentifier) as! AttachmentFileCell
        }
    }
    
}


extension FeedAttachmentsTableViewCell : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let file = self.attachments[indexPath.row]
        
        if file.isImage {
            let imageWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
            let imageHeight = imageWidth * 0.56 - 5
            return imageHeight
        } else {
            return 56
        }
        

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let file = self.attachments[indexPath.row]
        (cell as! Attachable).configureWithFile(file)
    }
}

