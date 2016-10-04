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
    func subscribeForLogoutNotification(_ observer:AnyObject, selector:Selector)
    func subscribeForNotification(_ observer:AnyObject, name:String, selector:Selector)
}

extension Observer: ObserverProtocol {
    func subscribeForLogoutNotification(_ observer:AnyObject, selector:Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector,
                                                         name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserLogoutNotificationName),
                                                         object: nil)
    }
    func subscribeForNotification(_ observer:AnyObject, name:String, selector:Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector,
                                                         name: NSNotification.Name(rawValue: name),
                                                         object: nil)
    }
}
