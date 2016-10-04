//
//  PerformanceManager.swift
//  Mattermost
//
//  Created by Maxim Gubin on 10/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class PerformanceManager {
    static let sharedInstance = PerformanceManager()
    
    let messageRenderOperationQueue = OperationQueue()
    
    fileprivate init() {
        self.setup()
    }
    
    fileprivate func setup() {
        self.configureMessageRenderQueue()
    }
    
    fileprivate func configureMessageRenderQueue() {
        self.messageRenderOperationQueue.qualityOfService = .userInteractive
        self.messageRenderOperationQueue.maxConcurrentOperationCount = 2
    }
}
