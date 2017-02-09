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
    fileprivate var selectedChannelIdentifier: String? {
        didSet { self.handleSelectedChannel() }
    }
    
    var selectedChannel: Channel? {
        set(newChannel) {
            self.selectedChannelIdentifier = newChannel?.identifier
        }
        get {
            guard let identifier = self.selectedChannelIdentifier else { return nil }
            return Channel.objectById(identifier)
        }
    }
    
    weak var delegate : ChannelObserverDelegate? {
        didSet {
            self.handleSelectedChannel()
        }
    }
    @nonobjc static let sharedObserver = ChannelObserver.sharedInstanse();
    
    //MARK: - Private
    fileprivate func handleSelectedChannel() {
        DispatchQueue.main.async {
            self.delegate?.didSelectChannelWithIdentifier(self.selectedChannelIdentifier)
        }
    }
}


extension ChannelObserver {
    fileprivate static func sharedInstanse() -> ChannelObserver {
        let sharedInstanse = ChannelObserver()
        return sharedInstanse
    }
}
