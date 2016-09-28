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
    var errorHandler: ((post: Post) -> Void)?
    
    init() {
        super.init(frame: CGRectZero)
        setupErrorView()
        setupSendingView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.sendingView.frame = self.bounds
        self.errorView.frame = self.bounds
    }
}

//MARK: - Setup
extension PostStatusView {
    func setupErrorView() {
        errorView.setImage(UIImage(named:  "message_fail_button"), forState: .Normal)
        errorView.addTarget(self, action: #selector(errorAction), forControlEvents: .TouchUpInside)
        errorView.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
    }
    func setupSendingView() {
        sendingView.activityIndicatorViewStyle = .Gray
        
    }
}
//MARK: - Action
extension PostStatusView {
    func errorAction() {
        guard errorHandler != nil else { return }
        errorHandler!(post: post!)
    }
}

//MARK: - Configuration
extension PostStatusView {
    func configureWithStatus(post: Post) {
        self.post = post
        print(post.status.rawValue)
        switch post.status {
        case .Error:
            sendingView.removeFromSuperview()
            addSubview(errorView)
        case .Sending:
//            addSubview(errorView)
            errorView.removeFromSuperview()
            sendingView.startAnimating()
            addSubview(sendingView)
        default:
            errorView.removeFromSuperview()
            sendingView.stopAnimating()
            sendingView.removeFromSuperview()
        }
    }
}

