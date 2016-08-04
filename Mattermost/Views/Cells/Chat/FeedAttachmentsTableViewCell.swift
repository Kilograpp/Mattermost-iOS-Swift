//
//  FeedAttachmentsTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import ActiveLabel
import WebImage
import RealmSwift

//FIXME: CodeReview: Final
class FeedAttachmentsTableViewCell: FeedCommonTableViewCell {
    //FIXME: CodeReview: Константной
    //FIXME: CodeReview: Приват
    var tableView = UITableView()
    //FIXME: CodeReview: Может быть такое, что ячейка без attachment рабоотает? Если нет, то implicity unwrap
    var attachments : List<File>!
    
    
    
    //MARK: Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: Setup
    
    func setupTableView() -> Void {
        self.tableView = UITableView.init()
        self.tableView.scrollsToTop = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.tableView.bounces = false
        self.tableView.scrollEnabled = false
        
        self.tableView.registerClass(AttachmentImageCell.self, forCellReuseIdentifier: AttachmentImageCell.reuseIdentifier(), cacheSize: 7)
        self.addSubview(self.tableView)
    }
    
    
    //MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.tableView.frame = CGRectMake(53,
                                          CGRectGetMaxY(self.messageLabel.frame) + 8,
                                          UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings,
                                          self.tableView.contentSize.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    //MARK: Private
    
    private class func tableViewHeightWithPost(post: Post) -> CGFloat {
        let height =  post.files.reduce(0) {
            (total, file) in total + (UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings)*0.56 - 5
        }
        return height
    }

}

extension FeedAttachmentsTableViewCell {
    override func configureWithPost(post: Post) {
        super.configureWithPost(post)
        self.attachments = self.post.files
        self.tableView.reloadData()
    }
    
    override class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 44 + 8 + FeedAttachmentsTableViewCell.tableViewHeightWithPost(post)
    }
}

extension FeedAttachmentsTableViewCell : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attachments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //FIXME: CodeReview: Убрать инит
        let file = self.attachments[indexPath.row]
        if file.isImage {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(AttachmentImageCell.reuseIdentifier()) as! AttachmentImageCell
            cell.configureWithFile(file)
            return cell
        }
        
        return UITableViewCell()
    }
}


extension FeedAttachmentsTableViewCell : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let imageWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
        let imageHeight = imageWidth * 0.56 - 5
        return imageHeight
    }
}

