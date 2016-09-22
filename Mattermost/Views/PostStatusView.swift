//
//  PostStatusView.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 22.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


final class PostStatusView: UIView {
//    let state: PostStatus
    var post: Post?
    let errorView = UIButton()
    let sendingView = UIActivityIndicatorView()
    var errorHandler: (() -> Void)?
    
    init() {
        super.init(frame: CGRectZero)
        setupErrorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Setup
extension PostStatusView {
    func setupErrorView() {
        errorView.setImage(UIImage(named:  "message_fail_button"), forState: .Normal)
        errorView.addTarget(self, action: #selector(errorAction), forControlEvents: .TouchUpInside)
        errorView.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
    }
}
//MARK: - Action
extension PostStatusView {
    func errorAction() {
        errorHandler!()
    }
}

//MARK: - Configuration
extension PostStatusView {
    func configureWithStatus(post: Post) {
        self.post = post
        switch post.status {
        case .Error:
            addSubview(errorView)
        case .Sending:
            addSubview(sendingView)
        default:
            errorView.removeFromSuperview()
            sendingView.removeFromSuperview()
        }
    }
}

