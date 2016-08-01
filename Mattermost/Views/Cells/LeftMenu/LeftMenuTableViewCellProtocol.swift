//
//  LeftMenuTableViewCellProtocol.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

protocol LeftMenuTableViewCellProtocol : class, MattermostTableViewCellProtocol {
//    var channel : Channel? { get set }
    
    func configureWithChannel(channel: Channel, selected: Bool) -> Void
//    static func height(channel: Channel) -> CGFloat
}
//
//если нужна реализация
//extension FeedTableViewCellProtocol {
//    static func height(channel: Channel) -> CGFloat {
//        return 42
//    }
//}

