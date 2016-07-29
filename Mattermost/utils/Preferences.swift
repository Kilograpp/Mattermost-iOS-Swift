//
//  Preferences.swift
//  Mattermost
//
//  Created by Maxim Gubin on 29/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Interface {
    func save()
}

public enum PreferencesAttributes: String {
    case siteName      = "siteName"
    case serverUrl     = "serverUrl"
    case currentUserId = "currentUserId"
    case currentTeamId = "currentTeamId"
}

class Preferences: NSObject, NSCoding {
    static let sharedInstance = Preferences.loadInstanceFromUserDefaults() ?? Preferences()
    
    dynamic var serverUrl: String?
    dynamic var currentUserId: String?
    dynamic var currentTeamId: String?
    dynamic var siteName: String?
    
    
    private override init() {
        super.init()
        
#if DEBUG // Save on every move if debugging
        self.enumeratePropertiesWithBlock { (name, type) in
            self.addObserver(self, forKeyPath: name, options: .New, context: nil)
        }
#endif
    }
    
#if DEBUG // Save on every move if debugging
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.save()
    }
#endif
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        self.enumeratePropertiesWithBlock { (name, type) in
            switch(type) {
                case .TypeObject:
                    self.setValue(aDecoder.decodeObjectForKey(name), forKey: name)
                    break
                case .TypePrimitiveBool:
                    self.setValue(aDecoder.decodeBoolForKey(name), forKey: name)
                    break
                default: break
            }
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        self.enumeratePropertiesWithBlock { (name, type) in
            switch(type) {
                case .TypeObject:
                    aCoder.encodeObject(self.valueForKey(name), forKey: name)
                    break
                case .TypePrimitiveBool:
                    aCoder.encodeBool(self.valueForKey(name) as! Bool, forKey: name)
                    break
                    
                default: break
            }
        }
    }
    

}

private protocol Persistence {
    func save()
    static func loadInstanceFromUserDefaults() -> Preferences?
}

extension Preferences : Persistence {
    private static func loadInstanceFromUserDefaults() -> Preferences? {
        let defaults = NSUserDefaults.standardUserDefaults()
        let data = defaults.objectForKey(Constants.Common.UserDefaultsPreferencesKey) as! NSData?
        if let data = data {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Preferences
        }
        return nil
    }
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(NSKeyedArchiver.archivedDataWithRootObject(self), forKey: Constants.Common.UserDefaultsPreferencesKey)
        defaults.synchronize()
    }
}



