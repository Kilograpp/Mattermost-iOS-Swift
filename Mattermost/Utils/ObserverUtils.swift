//
//  ObserverUtils.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 21.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

//refactor later: all .addObserver -> this class

class Observer {
    static let sharedObserver = Observer()
}

private protocol ObserverProtocol {
    func subscribeForLogoutNotification(observer:AnyObject, selector:Selector)
    func subscribeForNotification(observer:AnyObject, name:String, selector:Selector)
}

extension Observer: ObserverProtocol {
    func subscribeForLogoutNotification(observer:AnyObject, selector:Selector) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector,
                                                         name: Constants.Common.UserLogoutNotificationName,
                                                         object: nil)
    }
    func subscribeForNotification(observer:AnyObject, name:String, selector:Selector) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector,
                                                         name: name,
                                                         object: nil)
    }
}
