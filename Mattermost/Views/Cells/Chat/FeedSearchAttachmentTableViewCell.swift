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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let x = Constants.UI.MessagePaddingSize
        let y = self.messageLabel.frame.maxY + 8
        let width = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        let height = self.tableView.contentSize.height
        
        self.tableView.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}


extension FeedSearchAttachmentTableViewCell {
    override func configureWithPost(_ post: Post) {
        super.configureWithPost(post)
        self.attachments = self.post.files
        self.tableView.reloadData()
    }
    
    override class func heightWithPost(_ post: Post) -> CGFloat {
        let messageHeight = CGFloat(post.attributedMessageHeight) + 44 + 8
        
        let tableHeight = post.files.reduce(0) {
            (total, file) in
            total + (file.isImage ? (UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings)*0.56 - 5 : 56)
        }
        
        return messageHeight + tableHeight
    }
}


private protocol FeedSearchAttachmentTableViewCellSetup {
    func setupTableView()
}


//MARK: FeedSearchAttachmentTableViewCellSetup
extension FeedSearchAttachmentTableViewCell: FeedSearchAttachmentTableViewCellSetup {
    func setupTableView() {
        self.tableView.scrollsToTop = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        self.tableView.isScrollEnabled = false
        self.tableView.isUserInteractionEnabled = false
        
        self.tableView.register(AttachmentImageCell.self, forCellReuseIdentifier: AttachmentImageCell.reuseIdentifier, cacheSize: 7)
        self.tableView.register(AttachmentFileCell.self, forCellReuseIdentifier: AttachmentFileCell.reuseIdentifier, cacheSize: 7)
        self.addSubview(self.tableView)
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
 
