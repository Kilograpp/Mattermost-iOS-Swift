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

class FeedAttachmentsTableViewCell: FeedCommonTableViewCell {
    var tableView : UITableView = UITableView()
    var attachments : List<File>?
    
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
        self.addSubview(self.tableView)
    }
    
    
    //MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        self.tableView.frame = CGRectMake(53, CGRectGetMaxY(self.messageLabel.frame) + 8, UIScreen.screenWidth() - 61, self.tableView.contentSize.height)
        for file in (self.post?.files)! {
            <#code#>
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.tableView?.delegate = nil
//        self.tableView?.dataSource = nil
    }
    
    
    //MARK: Private
    
    private class func tableViewHeightWithPost(post: Post) -> CGFloat {
        return FeedAttachmentsTableViewCell.tableViewHeightWithFiles(Array(post.files))
    }

}

private protocol Private {
    static func tableViewHeightWithFiles(files: Array<File>) -> CGFloat
}

extension FeedAttachmentsTableViewCell {
    override func configureWithPost(post: Post) {
        super.configureWithPost(post)
        self.attachments = self.post?.files
        self.tableView.reloadData()
    }
    
    override class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 44 + 8 + FeedAttachmentsTableViewCell.tableViewHeightWithPost(post)
    }
}

extension FeedAttachmentsTableViewCell : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.post?.files.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "attachments")
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.redColor()
        } else {
            cell.backgroundColor = UIColor.blueColor()
        }
        
        
        return cell
    }
}


extension FeedAttachmentsTableViewCell : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //FIXME: add real one
        return 40
    }
}


//MARK: - Private

extension FeedAttachmentsTableViewCell {
    private static func tableViewHeightWithFiles(files: Array<File>) -> CGFloat {
        let height = CGFloat(40 * files.count)
        
        return height
    }
}


