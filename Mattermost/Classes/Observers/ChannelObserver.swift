//
//  ChannelObserver.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 30.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


import Foundation


protocol ChannelObserverDelegate : class {
    func didSelectChannelWithIdentifier(_ identifier: String!) -> Void
}


class ChannelObserver {
    var selectedChannel: Channel? {
        didSet { self.handleSelectedChannel() }
    }
    weak var delegate : ChannelObserverDelegate? {
        didSet {
            self.delegate?.didSelectChannelWithIdentifier(self.selectedChannel?.identifier)
        }
    }
    @nonobjc static let sharedObserver = ChannelObserver.sharedInstanse();
    
    //MARK: - Private
    fileprivate func handleSelectedChannel() {
        self.delegate?.didSelectChannelWithIdentifier(self.selectedChannel?.identifier)        
    }
}


extension ChannelObserver {
    fileprivate static func sharedInstanse() -> ChannelObserver {
        let sharedInstanse = ChannelObserver()
        return sharedInstanse
    }
}
