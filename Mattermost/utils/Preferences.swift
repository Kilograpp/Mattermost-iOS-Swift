//
//  Preferences.swift
//  Mattermost
//
//  Created by Maxim Gubin on 29/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Interface: class {
    func save()
    
    // Debug Methods
    func predefinedLogin() -> String?
    func predefinedPassword() -> String?
    func predefinedServerUrl() -> String?
    
}

enum PreferencesAttributes: String {
    case siteName      = "siteName"
    case serverUrl     = "serverUrl"
    case currentUserId = "currentUserId"
    case currentTeamId = "currentTeamId"
    case shouldCompressImages = "shouldCompressImages"
}

final class Preferences: NSObject, NSCoding {
    static let sharedInstance = Preferences.loadInstanceFromUserDefaults() ?? Preferences()
    
    dynamic var serverUrl: String?
    dynamic var currentUserId: String?
    dynamic var currentTeamId: String?
    dynamic var siteName: String?
    dynamic var shouldCompressImages: NSNumber?
    
    fileprivate override init() {
        super.init()
        
#if DEBUG // Save on every move if debugging
        self.enumerateProperties { (name, type) in
            //s3 refactor (name -> name!)
            self.addObserver(self, forKeyPath: name!, options: .new, context: nil)
        }
#endif
    }
    
#if DEBUG // Save on every move if debugging
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.save()
    }
#endif
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        self.enumerateProperties { (name, type) in
            switch(type) {
                case .typeObject:
                    self.setValue(aDecoder.decodeObject(forKey: name!), forKey: name!)
                    break
                case .typePrimitiveBool:
                    self.setValue(aDecoder.decodeBool(forKey: name!), forKey: name!)
                    break
                default: break
            }
        }
    }
    
    func encode(with aCoder: NSCoder) {
        self.enumerateProperties { (name, type) in
            switch(type) {
                case .typeObject:
                    aCoder.encode(self.value(forKey: name!), forKey: name!)
                    break
                case .typePrimitiveBool:
                    aCoder.encode(self.value(forKey: name!) as! Bool, forKey: name!)
                    break
                    
                default: break
            }
        }
    }
    

}

private protocol Persistence: class {
    func save()
    static func loadInstanceFromUserDefaults() -> Preferences?
}

extension Preferences : Persistence {
    fileprivate static func loadInstanceFromUserDefaults() -> Preferences? {
        let defaults = UserDefaults.standard
        let data = defaults.object(forKey: Constants.Common.UserDefaultsPreferencesKey) as! Data?
        if let data = data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? Preferences
        }
        return nil
    }
    func save() {
        let defaults = UserDefaults.standard
        defaults.setValue(NSKeyedArchiver.archivedData(withRootObject: self), forKey: Constants.Common.UserDefaultsPreferencesKey)
        defaults.synchronize()
    }
}
extension Preferences: Interface {
    func predefinedServerUrl() -> String? {
        return ProcessInfo.processInfo.environment["MM_SERVER_URL"]
    }
    
    func predefinedLogin() -> String? {
        return ProcessInfo.processInfo.environment["MM_LOGIN"]
    }
    
    func predefinedPassword() -> String? {
        return ProcessInfo.processInfo.environment["MM_PASSWORD"]
    }
}




