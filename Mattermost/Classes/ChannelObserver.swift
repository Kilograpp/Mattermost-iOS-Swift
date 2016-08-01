//
//  ChannelObserver.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 30.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


import Foundation


protocol ChannelObserverDelegate {
    func didSelectChannelWithIdentifier(identifier: String!) -> Void
}


class ChannelObserver {
    var selectedChannel: Channel? {
        didSet {
            self.handleSelectedChannel()
        }
    }
    var delegate : ChannelObserverDelegate? {
        didSet {
            self.delegate?.didSelectChannelWithIdentifier(self.selectedChannel?.identifier)
        }
    }
    @nonobjc static let sharedObserver = ChannelObserver.sharedInstanse();
    
    //MARK: - Private
    
    private func handleSelectedChannel() {
        self.delegate?.didSelectChannelWithIdentifier(self.selectedChannel?.identifier)
    }
}


extension ChannelObserver {
    private static func sharedInstanse() -> ChannelObserver {
        let sharedInstanse = ChannelObserver()
        return sharedInstanse
    }
}