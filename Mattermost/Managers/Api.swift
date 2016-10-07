
//
// Created by Maxim Gubin on 28/06/16.
// Copyright (c) 2016 Kilograpp. All rights reserved.
//


import Foundation
import RealmSwift
import RestKit
import SOCKit

private protocol Interface: class {
//    func isSignedIn() -> Bool
    func baseURL() -> URL!
//    func cookie() -> NSHTTPCookie?
    func avatarLinkForUser(_ user: User) -> String
}

private protocol UserApi: class {
    func login(_ email: String, password: String, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadCompleteUsersList(_ completion: @escaping (_ error: Mattermost.Error?) -> Void)
//    func updateStatusForUsers(users: Array<User>, completion: (error: Mattermost.Error?) -> Void)
}

private protocol TeamApi: class {
    func loadTeams(with completion: @escaping (_ userShouldSelectTeam: Bool, _ error: Mattermost.Error?) -> Void)
}

private protocol ChannelApi: class {
    func loadChannels(with completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadExtraInfoForChannel(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func updateLastViewDateForChannel(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadAllChannelsWithCompletion(_ completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func addUserToChannel(_ user:User, channel:Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
}

private protocol PostApi: class {
    func sendPost(_ post: Post, completion:  @escaping(_ error: Mattermost.Error?) -> Void)
    func updatePost(_ post: Post, completion:  @escaping(_ error: Mattermost.Error?) -> Void)
    func updateSinglePost(_ post: Post, completion:  @escaping(_ error: Mattermost.Error?) -> Void)
    func deletePost(_ post: Post, completion:  @escaping(_ error: Mattermost.Error?) -> Void)
    func loadFirstPage(_ channel: Channel, completion:  @escaping(_ error: Mattermost.Error?) -> Void)
    func loadNextPage(_ channel: Channel, fromPost: Post, completion:  @escaping(_ isLastPage: Bool, _ error: Mattermost.Error?) -> Void)
}

private protocol FileApi : class {
    func uploadImageItemAtChannel(_ item: AssignedPhotoViewItem,channel: Channel, completion:  @escaping (_ file: File?, _ error: Mattermost.Error?) -> Void, progress:  @escaping(_ identifier: String, _ value: Float) -> Void)
    func cancelUploadingOperationForImageItem(_ item: AssignedPhotoViewItem)
}

final class Api {
    static let sharedInstance = Api()
    fileprivate var _managerCache: ObjectManager?
    fileprivate var manager: ObjectManager  {
        if _managerCache == nil {
            _managerCache = ObjectManager(baseURL: self.computeAndReturnApiRootUrl())
            _managerCache!.httpClient.setDefaultHeader(Constants.Http.Headers.RequestedWith, value: "XMLHttpRequest")
            _managerCache!.httpClient.setDefaultHeader(Constants.Http.Headers.AcceptLanguage, value: LocaleUtils.currentLocale())
            _managerCache!.httpClient.setDefaultHeader(Constants.Http.Headers.ContentType, value: RKMIMETypeJSON)
            _managerCache!.requestSerializationMIMEType = RKMIMETypeJSON;
            _managerCache!.addRequestDescriptors(from: RKRequestDescriptor.findAllDescriptors())
            _managerCache!.addResponseDescriptors(from: RKResponseDescriptor.findAllDescriptors())
            
            _managerCache!.registerRequestOperationClass(KGObjectRequestOperation.self)

        }
        return _managerCache!;
    }
    
    fileprivate init() {
        self.setupMillisecondsValueTransformer()
    }
    fileprivate func setupMillisecondsValueTransformer() {
        let transformer = RKValueTransformer.millisecondsToDateValueTransformer()
        RKValueTransformer.defaultValueTransformer().insert(transformer, at: 0)
    }
    
    fileprivate func computeAndReturnApiRootUrl() -> URL! {
        return URL(string: Preferences.sharedInstance.serverUrl!)?.appendingPathComponent(Constants.Api.Route)
    }
}


extension Api: UserApi {
    
    func login(_ email: String, password: String, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = UserPathPatternsContainer.loginPathPattern()
        let parameters = ["login_id" : email, "password": password, "token" : ""]
        self.manager.postObject(path: path, parameters: parameters as [AnyHashable: Any]?, success: { (mappingResult) in
            let user = mappingResult.firstObject as! User
            let systemUser = DataManager.sharedInstance.instantiateSystemUser()
            user.computeDisplayName()
            DataManager.sharedInstance.currentUser = user
            RealmUtils.save([user, systemUser])
            SocketManager.sharedInstance.setNeedsConnect()
            completion(nil)
            }, failure: completion)
    }
    
    func logout(_ completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = UserPathPatternsContainer.logoutPathPattern()
        let parameters = ["user_id" : Preferences.sharedInstance.currentUserId!]
        self.manager.postObject(path: path, parameters: parameters, success: { (mappingResult) in
            completion(nil)
            }, failure: completion)
    }
    
    func loadCompleteUsersList(_ completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(UserPathPatternsContainer.completeListPathPattern(), DataManager.sharedInstance.currentTeam)
        self.manager.getObject(path: path!, success: { (mappingResult, skipMapping) in
            let users = MappingUtils.fetchUsersFromCompleteList(mappingResult)
            users.forEach {$0.computeDisplayName()}
            RealmUtils.save(users)
            completion(nil)
        }, failure: completion)
    }
    
//    func updateStatusForUsers(users: Array<User>, completion: (error: Mattermost.Error?) -> Void) {
//        let path = UserPathPatternsContainer.usersStatusPathPattern()
//        let params = (users as NSArray).valueForKey(UserAttributes.identifier.rawValue)
//        self.manager.postObject(nil, path: path, parametersAsArray: params as! [AnyObject], success: { (operation: RKObjectRequestOperation!, mappingResult: RKMappingResult!) in
//            UserStatusObserver.sharedObserver.reloadWithStatusesArray(mappingResult.array() as! Array<UserStatus>)
//            completion(error: nil)
//            }) { (operation, error) in
//                    let eror = try! RKNSJSONSerialization.objectFromData(operation.HTTPRequestOperation.request.HTTPBody)
//                    print(eror)
//         }
//        }
}

extension Api: TeamApi {
    
    func loadTeams(with completion:@escaping (_ userShouldSelectTeam: Bool, _ error: Mattermost.Error?) -> Void) {
        let path = TeamPathPatternsContainer.initialLoadPathPattern()
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            let teams = MappingUtils.fetchAllTeams(mappingResult)
            let users = MappingUtils.fetchUsersFromInitialLoad(mappingResult)
            users.forEach{ $0.computeDisplayName()}
            Preferences.sharedInstance.siteName = MappingUtils.fetchSiteName(mappingResult)
            RealmUtils.save(teams)
            RealmUtils.save(users)
            if (teams.count == 1) {
                Preferences.sharedInstance.currentTeamId = teams.first!.identifier
                completion(false, nil)
            } else {
                completion(true, nil)
            }
            
        }) { (error) in
            completion(true, error)
        }
    }
    
    func checkURL(with completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = TeamPathPatternsContainer.initialLoadPathPattern()
        self._managerCache = nil
        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
            Preferences.sharedInstance.siteName = MappingUtils.fetchSiteName(mappingResult)
            completion(nil)
        }) { (error) in
            completion(error)
        }
    }
}

extension Api: ChannelApi {
    
    func loadChannels(with completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.listPathPattern(), DataManager.sharedInstance.currentTeam)
        self.manager.getObject(path: path!, success: { (mappingResult, skipMapping) in
            let realm = RealmUtils.realmForCurrentThread()
            //uncomment later
//            let members  = mappingResult.dictionary()["members"]  as! [Member]
//            let currentUserId = Preferences.sharedInstance.currentUserId
            // + save to database
            //refactor
            
//            var membersViews = [String : Date]()
//            members.forEach({ (member:Member) in
//                if (member.userId == currentUserId) {
//                    membersViews[member.channelId!] = member.lastViewedAt
//                }
//            })
            
            let channels = MappingUtils.fetchAllChannelsFromList(mappingResult)
            try! realm.write({
                channels.forEach {
                    $0.currentUserInChannel = true
//                    $0.lastViewDate = membersViews[$0.identifier!]
                    $0.computeTeam()
                    $0.computeDispayNameIfNeeded()
                }
                realm.add(channels, update: true)
//                for channel in members {
//                    var dictionary: [String: AnyObject] = [String: AnyObject] ()
////                    dictionary[ChannelAttributes.lastViewDate.rawValue] = channel.lastViewDate as AnyObject
////                    dictionary[ChannelAttributes.lastPostDate.rawValue] = channel.lastPostDate as AnyObject
////                    dictionary[ChannelAttributes.identifier.rawValue] = channel.identifier as AnyObject
////                    realm.create(Channel.self, value: dictionary, update: true)
//                    let newChannel = Channel()
//                    newChannel.lastViewDate = channel.lastViewDate
//                    newChannel.lastPostDate = channel.lastPostDate
//                    newChannel.identifier = channel.identifier
//                    realm.create(Channel.self, value: newChannel, update: true)
//                }
            })
            
            completion(nil)
            }, failure: completion)
    }
    
    func loadExtraInfoForChannel(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.loadOnePathPattern(), channel)
//        self.manager.getObject(path: path, success: { (mappingResult, skipMapping) in
//            try! RealmUtils.realmForCurrentThread().write({
//                RealmUtils.realmForCurrentThread().create(Channel.self,value: Reflection.fetchNotNullValues(mappingResult.firstObject as! Channel),
//                                                                    update: true)
//            })
//            completion(error: nil)
//        }, failure: completion)
    }
    
    func updateLastViewDateForChannel(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.updateLastViewDatePathPattern(), channel)
        self.manager.postObject(path: path, success: { (mappingResult) in
            try! RealmUtils.realmForCurrentThread().write({
                channel.lastViewDate = Date()
            })
            completion(nil)
        }, failure: completion)
    }
    
    func loadAllChannelsWithCompletion(_ completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.moreListPathPattern(), DataManager.sharedInstance.currentTeam)
        self.manager.getObject(path: path!, success: { (mappingResult, skipMapping) in
            let channels = MappingUtils.fetchAllChannelsFromList(mappingResult)
            try! RealmUtils.realmForCurrentThread().write({ 
                channels.forEach {$0.computeTeam()}
                RealmUtils.realmForCurrentThread().add(channels, update: true)
            })
            completion(nil)
        }, failure: completion)
    }
    func addUserToChannel(_ user:User, channel:Channel, completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.addUserPathPattern(), channel)
        let params = [ "user_id" : user.identifier ]
        self.manager.postObject(nil, path: path, parameters: params, success: { (mappingResult) in
            completion(nil)
            }, failure: completion)
    }
}

extension Api: PostApi {
    func loadFirstPage(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let wrapper = PageWrapper(channel: channel)
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.firstPagePathPattern(), wrapper)
        
        self.manager.getObject(path: path!, success: { (mappingResult, skipMapping) in
            guard !skipMapping else {
                completion(nil)
                return
            }

            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                RealmUtils.save(MappingUtils.fetchConfiguredPosts(mappingResult))
                
                DispatchQueue.main.sync {
                    completion(nil)
                }
                
            })
            
        }) { (error) in
            completion(error)
        }
    }
    
    func loadNextPage(_ channel: Channel, fromPost: Post, completion: @escaping (_ isLastPage: Bool, _ error: Mattermost.Error?) -> Void) {
        guard fromPost.identifier != nil else { return }
        let postIdentifier = fromPost.identifier!
        let wrapper = PageWrapper(channel: channel, lastPostId: postIdentifier)
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.nextPagePathPattern(), wrapper)
        
        self.manager.getObject(path: path!, success: { (mappingResult, skipMapping) in

            guard !skipMapping else {
                completion(MappingUtils.isLastPage(mappingResult, pageSize: wrapper.size), nil)
                return
            }
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                RealmUtils.save(MappingUtils.fetchConfiguredPosts(mappingResult))
                DispatchQueue.main.sync {
                    completion(MappingUtils.isLastPage(mappingResult, pageSize: wrapper.size), nil)
                }
            })
        }) { (error) in
            var isLastPage = false
            if error!.code == 1001 {
                isLastPage = true
            }
            completion(isLastPage, error)
        }
    }
    func sendPost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.creationPathPattern(), post)
        self.manager.postObject(post, path: path, success: { (mappingResult) in
            let resultPost = mappingResult.firstObject as! Post
//            resultPost.computeMissingFields()
//            resultPost.cellType = post.cellType
//            resultPost.localIdentifier = post.localIdentifier
//            RealmUtils.save(resultPost)
            try! RealmUtils.realmForCurrentThread().write {
                //не достающие параметры
                post.status = .default
                post.identifier = resultPost.identifier
            }
            completion(nil)
        }, failure: completion)
    }
    func updateSinglePost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.updatingPathPattern(), post)
        self.manager.postObject(post, path: path, success: { (mappingResult) in
            RealmUtils.save(mappingResult.firstObject as! Post)
            completion(nil)
            }, failure: completion)
    }
    func deletePost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.deletingPathPattern(), post)
        let params = ["team_id"    : Preferences.sharedInstance.currentTeamId!,
                      "channel_id" : post.channelId!,
                      "post_id"    : post.identifier!]
  
        self.manager.deletePost(with: post, path: path, parameters: params, success: { (mappingResult) in
            completion(nil)
            }) { (error) in
            completion(error)
        }
    }
    
    func updatePost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.updatePathPattern(), post)
        self.manager.getObject(post, path: path!, success: { (mappingResult, skipMapping) in
            RealmUtils.save(MappingUtils.fetchPostFromUpdate(mappingResult))
            completion(nil)
        }, failure: completion)
    }
}

extension Api : FileApi {
    func uploadImageItemAtChannel(_ item: AssignedPhotoViewItem,
                                  channel: Channel,
                                  completion: @escaping (_ file: File?, _ error: Mattermost.Error?) -> Void,
                                  progress: @escaping (_ identifier: String, _ value: Float) -> Void) {
        let path = SOCStringFromStringWithObject(FilePathPatternsContainer.uploadPathPattern(), DataManager.sharedInstance.currentTeam)
        let params = ["channel_id" : channel.identifier!,
                      "client_ids"  : StringUtils.randomUUID()]
        
        self.manager.postImage(with: item.image, name: "files", path: path, parameters: params, success: { (mappingResult) in
            let file = File()
            //s3 refactor
            let dictionary = mappingResult.firstObject as! [String:String]
            let rawLink = dictionary[FileAttributes.rawLink.rawValue]
            file.rawLink = rawLink
            completion(file, nil)
            RealmUtils.save(file)
            }, failure: { (error) in
                completion(nil, nil)
            }) { (value) in
                progress(item.identifier, value)
        }
    }
    
    func cancelUploadingOperationForImageItem(_ item: AssignedPhotoViewItem) {
        self.manager.cancelUploadingOperationForImageItem(item)
    }
    
    func uploadFileItemAtChannel(_ url: URL,
                                  channel: Channel,
                                  completion: @escaping (_ file: File?, _ error: Mattermost.Error?) -> Void,
                                  progress: @escaping (_ identifier: String, _ value: Float) -> Void) {
        let path = SOCStringFromStringWithObject(FilePathPatternsContainer.uploadPathPattern(), DataManager.sharedInstance.currentTeam)
        let params = ["channel_id" : channel.identifier!,
                      "client_ids"  : StringUtils.randomUUID()]
        
        self.manager.postFile(with: url, name: "files", path: path, parameters: params, success: { (mappingResult) in
            let file = File()
            //refactor
            let dictionary = mappingResult.firstObject as! [String:String]
            let rawLink = dictionary[FileAttributes.rawLink.rawValue]
            file.rawLink = rawLink
            completion(file, nil)
            RealmUtils.save(file)
            }, failure: { (error) in
                completion(nil, nil)
        }) { (value) in
//            progress(item.identifier, value)
        }
    }
}

extension Api: Interface {
    func baseURL() -> URL! {
        return self.manager.httpClient.baseURL
    }
    func avatarLinkForUser(_ user: User) -> String {
        let path = SOCStringFromStringWithObject(UserPathPatternsContainer.avatarPathPattern(), user)
        let url = URL(string: path!, relativeTo: self.manager.httpClient.baseURL)
        return url!.absoluteString
    }
}
