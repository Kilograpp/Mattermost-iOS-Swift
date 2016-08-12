
//
// Created by Maxim Gubin on 28/06/16.
// Copyright (c) 2016 Kilograpp. All rights reserved.
//


import Foundation
import RealmSwift

private protocol Interface: class {
    func isSignedIn() -> Bool
    func baseURL() -> NSURL!
    func cookie() -> NSHTTPCookie?
    func avatarLinkForUser(user: User) -> String
}

private protocol UserApi: class {
    func login(email: String, password: String, completion: (error: Error?) -> Void)
    func loadCompleteUsersList(completion:(error: Error?) -> Void)
    func updateStatusForUsers(users: Array<User>, completion: (error: Error?) -> Void)
}

private protocol TeamApi: class {
    func loadTeams(with completion:(userShouldSelectTeam: Bool, error: Error?) -> Void)
}

private protocol ChannelApi: class {
    func loadChannels(with completion:(error: Error?) -> Void)
    func loadExtraInfoForChannel(channel: Channel, completion:(error: Error?) -> Void)
    func updateLastViewDateForChannel(channel: Channel, completion:(error: Error?) -> Void)
    func loadAllChannelsWithCompletion(completion:(error: Error?) -> Void)
}

private protocol PostApi: class {
    func sendPost(post: Post, completion: (error: Error?) -> Void)
    func updatePost(post: Post, completion: (error: Error?) -> Void)
    func loadFirstPage(channel: Channel, completion: (error: Error?) -> Void)
    func loadNextPage(channel: Channel, fromPost: Post, completion: (isLastPage: Bool, error: Error?) -> Void)
}

final class Api {
    static let sharedInstance = Api()
    private var _managerCache: ObjectManager?
    private var manager: ObjectManager  {
        if _managerCache == nil {
            _managerCache = ObjectManager(baseURL: self.computeAndReturnApiRootUrl())
            _managerCache!.HTTPClient.setDefaultHeader(Constants.Http.Headers.RequestedWith, value: "XMLHttpRequest")
            _managerCache!.HTTPClient.setDefaultHeader(Constants.Http.Headers.AcceptLanguage, value: LocaleUtils.currentLocale())
            _managerCache!.HTTPClient.setDefaultHeader(Constants.Http.Headers.ContentType, value: RKMIMETypeJSON)
            _managerCache!.requestSerializationMIMEType = RKMIMETypeJSON;
            _managerCache!.addRequestDescriptorsFromArray(RKRequestDescriptor.findAllDescriptors())
            _managerCache!.addResponseDescriptorsFromArray(RKResponseDescriptor.findAllDescriptors())
        }
        return _managerCache!;
    }
    
    private init() {
        self.setupMillisecondsValueTransformer()
    }
    private func setupMillisecondsValueTransformer() {
        let transformer = RKValueTransformer.millisecondsToDateValueTransformer()
        RKValueTransformer.defaultValueTransformer().insertValueTransformer(transformer, atIndex: 0)
    }
    
    private func computeAndReturnApiRootUrl() -> NSURL! {
        return NSURL(string: Preferences.sharedInstance.serverUrl!)?.URLByAppendingPathComponent(Constants.Api.Route)
    }
}


extension Api: UserApi {
    
    func login(email: String, password: String, completion: (error: Error?) -> Void) {
        let path = User.loginPathPattern()
        let parameters = ["login_id" : email, "password": password, "token" : ""]
        self.manager.postObject(path: path, parameters: parameters, success: { (mappingResult) in
            let user = mappingResult.firstObject as! User
            let systemUser = DataManager.sharedInstance.instantiateSystemUser()
            user.computeDisplayName()
            DataManager.sharedInstance.currentUser = user
            RealmUtils.save([user, systemUser])
            SocketManager.sharedInstance.setNeedsConnect()
            completion(error: nil)
            }, failure: completion)
    }
    
    func loadCompleteUsersList(completion:(error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(User.completeListPathPattern(), DataManager.sharedInstance.currentTeam)
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            let users = MappingUtils.fetchUsersFromCompleteList(mappingResult)
            users.forEach {$0.computeDisplayName()}
            RealmUtils.save(users)
            completion(error: nil)
        }, failure: completion)
    }
    
    func updateStatusForUsers(users: Array<User>, completion: (error: Error?) -> Void) {
        let path = User.usersStatusPathPattern()
        let params = (users as NSArray).valueForKey(UserAttributes.identifier.rawValue)
        self.manager.postObject(nil, path: path, parametersAsArray: params as! [AnyObject], success: { (operation: RKObjectRequestOperation!, mappingResult: RKMappingResult!) in
            UserStatusObserver.sharedObserver.reloadWithStatusesArray(mappingResult.array() as! Array<UserStatus>)
            completion(error: nil)
            }) { (operation, error) in
                    let eror = try! RKNSJSONSerialization.objectFromData(operation.HTTPRequestOperation.request.HTTPBody)
                    print(eror)
         }
        }
}

extension Api: TeamApi {
    
    func loadTeams(with completion:(userShouldSelectTeam: Bool, error: Error?) -> Void) {
        let path = Team.initialLoadPathPattern()
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            let teams = MappingUtils.fetchAllTeams(mappingResult)
            let users = MappingUtils.fetchUsersFromInitialLoad(mappingResult)
            users.forEach{ $0.computeDisplayName()}
            Preferences.sharedInstance.siteName = MappingUtils.fetchSiteName(mappingResult)
            RealmUtils.save(teams)
            RealmUtils.save(users)
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
    
    func checkURL(with completion:(error: Error?) -> Void) {
        let path = Team.initialLoadPathPattern()
        self._managerCache = nil
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            Preferences.sharedInstance.siteName = MappingUtils.fetchSiteName(mappingResult)
            completion(error: nil)
        }) { (error) in
            completion(error: error)
        }
    }
}

extension Api: ChannelApi {
    
    func loadChannels(with completion: (error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(Channel.listPathPattern(), DataManager.sharedInstance.currentTeam)
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            let realm = RealmUtils.realmForCurrentThread()
            let members  = mappingResult.dictionary()["members"]  as! [Channel]
            let channels = MappingUtils.fetchAllChannelsFromList(mappingResult)
            try! realm.write({
                channels.forEach {
                    $0.computeTeam()
                    $0.computeDispayNameIfNeeded()
                }
                realm.add(channels, update: true)
                for channel in members {
                    var dictionary: [String: AnyObject] = [String: AnyObject] ()
                    dictionary[ChannelAttributes.lastViewDate.rawValue] = channel.lastViewDate
                    dictionary[ChannelAttributes.identifier.rawValue] = channel.identifier
                    realm.create(Channel.self, value: dictionary, update: true)
                    
                }
            })
            
            completion(error: nil)
            }, failure: completion)
    }
    
    func loadExtraInfoForChannel(channel: Channel, completion: (error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(Channel.extraInfoPathPattern(), channel)
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            RealmUtils.save(mappingResult.firstObject as! Channel)
            completion(error: nil)
        }, failure: completion)
    }
    
    func updateLastViewDateForChannel(channel: Channel, completion: (error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(Channel.updateLastViewDatePathPattern(), channel)
        self.manager.postObject(path: path, success: { (mappingResult) in
            try! RealmUtils.realmForCurrentThread().write({
                channel.lastViewDate = NSDate()
            })
            completion(error: nil)
        }, failure: completion)
    }
    
    func loadAllChannelsWithCompletion(completion: (error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(Channel.moreListPathPattern(), DataManager.sharedInstance.currentTeam)
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            let channels = MappingUtils.fetchAllChannelsFromList(mappingResult)
            try! RealmUtils.realmForCurrentThread().write({ 
                channels.forEach {$0.computeTeam()}
                RealmUtils.realmForCurrentThread().add(channels, update: true)
            })
            completion(error: nil)
        }, failure: completion)
    }
}

extension Api: PostApi {
    func loadFirstPage(channel: Channel, completion: (error: Error?) -> Void) {
        let wrapper = PageWrapper(channel: channel)
        let path = SOCStringFromStringWithObject(Post.firstPagePathPattern(), wrapper)
        
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            defer {completion( error: nil) }
            guard !skipMapping else { return }
            let posts = MappingUtils.fetchPosts(mappingResult)
            posts.forEach { $0.setSystemAuthorIfNeeded() }
            RealmUtils.save(posts)
        }) { (error) in
            completion(error: error)
        }
    }
    
    func loadNextPage(channel: Channel, fromPost: Post, completion: (isLastPage: Bool, error: Error?) -> Void) {
        let postIdentifier = fromPost.identifier!
        let wrapper = PageWrapper(channel: channel, lastPostId: postIdentifier)
        let path = SOCStringFromStringWithObject(Post.nextPagePathPattern(), wrapper)
        
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            defer { completion(isLastPage: MappingUtils.isLastPage(mappingResult, pageSize: wrapper.size), error: nil) }
            guard !skipMapping else { return }
            let posts = MappingUtils.fetchPosts(mappingResult)
            posts.forEach { $0.setSystemAuthorIfNeeded() }
            RealmUtils.save(posts)
        }) { (error) in
            var isLastPage = false
            if error!.code == 1001 {
                isLastPage = true
            }
            completion(isLastPage: isLastPage, error: error)
        }
    }
    func sendPost(post: Post, completion: (error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(Post.creationPathPattern(), post)
        self.manager.postObject(post, path: path, success: { (mappingResult) in
            RealmUtils.save(mappingResult.firstObject as! Post)
            completion(error: nil)
        }, failure: completion)
    }
    
    func updatePost(post: Post, completion: (error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(Post.updatePathPattern(), post)
        self.manager.getObject(post, path: path, success: { (mappingResult, skipMapping) in
            RealmUtils.save(MappingUtils.fetchPostFromUpdate(mappingResult))
            completion(error: nil)
        }, failure: completion)
        
    }
}

extension Api: Interface {
    func baseURL() -> NSURL! {
        return self.manager.HTTPClient.baseURL
    }
    func cookie() -> NSHTTPCookie? {
        return NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies?.filter { $0.name == Constants.Common.MattermostCookieName }.first
    }
    func isSignedIn() -> Bool {
        return self.cookie() != nil
    }
    func avatarLinkForUser(user: User) -> String {
        let path = SOCStringFromStringWithObject(User.avatarPathPattern(), user)
        return NSURL(string: path, relativeToURL: self.manager.HTTPClient?.baseURL)!.absoluteString
    }
}