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
    
    let messageRenderOperationQueue = NSOperationQueue()
    
    private init() {
        self.setup()
    }
    
    private func setup() {
        self.configureMessageRenderQueue()
    }
    
    private func configureMessageRenderQueue() {
        self.messageRenderOperationQueue.qualityOfService = .UserInteractive
        self.messageRenderOperationQueue.maxConcurrentOperationCount = 2
    }
}