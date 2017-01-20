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
    var errorHandler: ((_ post: Post) -> Void)?
    
    init() {
        super.init(frame: CGRect.zero)
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
        errorView.setImage(UIImage(named:  "message_fail_button"), for: UIControlState())
        errorView.addTarget(self, action: #selector(errorAction), for: .touchUpInside)
        errorView.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
    }
    func setupSendingView() {
        sendingView.activityIndicatorViewStyle = .gray
        
    }
}


//MARK: - Action
extension PostStatusView {
    func errorAction() {
        guard errorHandler != nil else { return }
        errorHandler!(post!)
    }
}


//MARK: - Configuration
extension PostStatusView {
    func configureWithStatus(_ post: Post) {
        self.post = post
        switch post.status {
        case .error:
            sendingView.removeFromSuperview()
            addSubview(errorView)
        case .sending:
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

