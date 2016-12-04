//
//  FeedSearchAttachmentTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 04.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import WebImage
import RealmSwift

private protocol Setup {
    func setupTableView()
}

private protocol Private {
        static func tableViewHeightWithPost(post: Post) -> CGFloat
}

class FeedSearchAttachmentTableViewCell: FeedSearchTableViewCell {

//MARK: Properties
    fileprivate let tableView = UITableView()
    fileprivate var attachments : List<File>!

//MARK: LifeCycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
          setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


//MARK: Setup

 extension FeedSearchAttachmentTableViewCell: Setup {
    func setupTableView() {
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
 }
 
 extension FeedSearchAttachmentTableViewCell {
    override func configureWithPost(_ post: Post) {
        super.configureWithPost(post)
        self.attachments = self.post.files
        self.tableView.reloadData()
    }
 
    override class func heightWithPost(_ post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 44 + 8 + FeedSearchAttachmentTableViewCell.tableViewHeightWithPost(post: post)
    }
 }
 
 
 //MARK: UITableViewDataSource
 
 extension FeedSearchAttachmentTableViewCell: UITableViewDataSource {
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.attachments != nil ? 1 : 0
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attachments.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.attachments[indexPath.row].isImage {
            return self.tableView.dequeueReusableCell(withIdentifier: AttachmentImageCell.reuseIdentifier) as! AttachmentImageCell
        } else {
            return self.tableView.dequeueReusableCell(withIdentifier: AttachmentFileCell.reuseIdentifier) as! AttachmentFileCell
        }
    }
 
 }
 
 
 //MARK: UITableViewDelegate
 
 extension FeedSearchAttachmentTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.attachments[indexPath.row].isImage {
            let imageWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
            let imageHeight = imageWidth * 0.56 - 10
            return imageHeight
        } else {
            return 56
        }
    }
 
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! Attachable).configureWithFile(self.attachments[indexPath.row])
    }
 }
 
 extension FeedSearchAttachmentTableViewCell: Private {
    fileprivate class func tableViewHeightWithPost(post: Post) -> CGFloat {
        let height = post.files.reduce(0) {
            (total, file) in
            total + (file.isImage ? (UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings)*0.56 - 5 : 56)
        }
        return height
    }
 }
 
 
 //MARK: LifeCycle
 
 extension FeedSearchAttachmentTableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.frame = CGRect(x: 53, y: self.messageLabel.frame.maxY + 8,
                                      width: UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize,
                                      height: self.tableView.contentSize.height)
 }
 
 override func prepareForReuse() {
    super.prepareForReuse()
    }
 }
