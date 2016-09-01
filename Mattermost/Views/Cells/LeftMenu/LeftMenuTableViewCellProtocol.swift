//
//  LeftMenuTableViewCellProtocol.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

protocol LeftMenuTableViewCellProtocol : class, Reusable {
    //FIXME: CodeReview: Убрать set
    var channel : Channel? { get set }
    var test : (() -> Void)? { get set }
    
    func configureWithChannel(channel: Channel, selected: Bool)
//    static func height(channel: Channel) -> CGFloat
    func subscribeToNotifications()
    func reloadCell()
    
    func removeObservers()
}


extension LeftMenuTableViewCellProtocol {
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
