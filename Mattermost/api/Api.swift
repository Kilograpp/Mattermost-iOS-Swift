//
// Created by Maxim Gubin on 28/06/16.
// Copyright (c) 2016 Kilograpp. All rights reserved.
//


import Foundation
import RealmSwift

private protocol UserApi {
    func login(email: String, password: String, completion: (error: Error?) -> Void)
}

private protocol TeamApi {
    func loadTeams(with completion:(userShouldSelectTeam: Bool, error: Error?) -> Void)
}

private protocol ChannelApi {
    func loadChannels(with completion:(error: Error?) -> Void)
}

private protocol PostApi {
    func loadFirstPage(channel: Channel, completion: (error: Error?) -> Void)
}

class Api: NSObject {
    static let sharedInstance = Api()
    private var _managerCache: ObjectManager?
    private var manager: ObjectManager  {
        if _managerCache == nil {
            _managerCache = ObjectManager(baseURL: self.baseUrl())
            _managerCache!.HTTPClient.setDefaultHeader(Constants.Http.Headers.RequestedWith, value: "XMLHttpRequest")
            _managerCache!.HTTPClient.setDefaultHeader(Constants.Http.Headers.AcceptLanguage, value: LocaleUtils.currentLocale())
            _managerCache!.HTTPClient.setDefaultHeader(Constants.Http.Headers.ContentType, value: RKMIMETypeJSON)
            _managerCache!.requestSerializationMIMEType = RKMIMETypeJSON;
            _managerCache!.addRequestDescriptorsFromArray(RKRequestDescriptor.findAllDescriptors())
            _managerCache!.addResponseDescriptorsFromArray(RKResponseDescriptor.findAllDescriptors())
        }
        return _managerCache!;
    }
   
    private override init() {
        super.init()
        self.setupMillisecondsValueTransformer()
    }
    func setupMillisecondsValueTransformer() {
        let transformer = RKValueTransformer.millisecondsToDateValueTransformer()
        RKValueTransformer.defaultValueTransformer().insertValueTransformer(transformer, atIndex: 0)
    }
    
    
    
    private func baseUrl() -> NSURL! {
        return NSURL(string: Preferences.sharedInstance.serverUrl!)?.URLByAppendingPathComponent(Constants.Api.Route)
    }
}


extension Api: UserApi {
    
    func login(email: String, password: String, completion: (error: Error?) -> Void) {
        let path = User.loginPathPattern()
        let parameters = ["login_id" : email, "password": password, "token" : ""]
        self.manager.postObject(path: path, parameters: parameters, success: { (mappingResult) in
            let user = mappingResult.firstObject as! User
            DataManager.sharedInstance.currentUser = user
            
            let realm = try! Realm()
            try! realm.write({
                realm.add(user, update: true)
            })
            
            completion(error: nil)
        }, failure: completion)
    }
}

extension Api: TeamApi {
    
    func loadTeams(with completion:(userShouldSelectTeam: Bool, error: Error?) -> Void) {
        let path = Team.initialLoadPathPattern()
        self.manager.getObject(path: path, success: { (mappingResult) in
            let teams = MappingUtils.fetchAllTeams(mappingResult)
            Preferences.sharedInstance.siteName = MappingUtils.fetchSiteName(mappingResult)
            RealmUtils.save(teams)
            if (teams.count == 1) {
                Preferences.sharedInstance.currentTeamId = teams.first!.identifier
                completion(userShouldSelectTeam: false, error: nil)
            } else {
                completion(userShouldSelectTeam: true, error: nil)
            }
            
        }) { (error) in
            completion(userShouldSelectTeam: true, error: error)
        }
    }
}

extension Api: ChannelApi {
    
    func loadChannels(with completion: (error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(Channel.listPathPattern(), DataManager.sharedInstance.currentTeam)
        self.manager.getObject(path: path, success: { (mappingResult) in
            
            
            let realm = try! Realm()
            let channels = mappingResult.dictionary()["members"] as! [Channel]
            
            try! realm.write({
                realm.add(mappingResult.dictionary()["channels"] as! [Channel], update: true)
                for channel in channels {
                    var dictionary: [String: AnyObject] = [String: AnyObject] ()
                    dictionary[ChannelAttributes.lastViewDate.rawValue] = channel.lastViewDate
                    dictionary[ChannelAttributes.identifier.rawValue] = channel.identifier
                    realm.create(Channel.self, value: dictionary, update: true)
                }
            })
            
            completion(error: nil)
        }, failure: completion)
    }
}

extension Api: PostApi {
    func loadFirstPage(channel: Channel, completion: (error: Error?) -> Void) {
        let wrapper = PageWrapper(channel: channel)
        let path = SOCStringFromStringWithObject(Post.firstPagePathPattern(), wrapper)
        
        self.manager.getObject(path: path, success: { (mappingResult) in
            RealmUtils.save(MappingUtils.fetchPosts(mappingResult))
            completion(error: nil)
        }) { (error) in
            completion(error: error)
        }
    }
}