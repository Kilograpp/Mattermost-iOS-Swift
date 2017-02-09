//
// Created by Maxim Gubin on 28/06/16.
// Copyright (c) 2016 Kilograpp. All rights reserved.
//


import Foundation
import RealmSwift
import RestKit
import SOCKit

private protocol Interface: class {
    func baseURL() -> URL!
    func avatarLinkForUser(_ user: User) -> String
    func cancelSearchRequestFor(channel: Channel)
    func isNetworkReachable() -> Bool
}

private protocol PreferencesApi: class {
    func savePreferencesWith(_ params: Dictionary<String, String>, complection: @escaping (_ error: Mattermost.Error?) -> Void)
    func listPreferencesWith(_ category: NSString, completion: @escaping (_ error: Mattermost.Error?) -> Void)
}

private protocol NotifyPropsApi: class {
    func updateNotifyProps(_ notifyProps: NotifyProps, completion: @escaping(_ error: Mattermost.Error?) -> Void)
}

private protocol TeamApi: class {
    func loadTeams(with completion: @escaping (_ userShouldSelectTeam: Bool, _ error: Mattermost.Error?) -> Void)
    func sendInvites(_ invites: [Dictionary<String , String>], completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadTeamMembersListBy(ids: [String], completion: @escaping (_ error: Mattermost.Error?) -> Void)
}

private protocol ChannelApi: class {
    func loadChannels(with completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadExtraInfoForChannel(_ channelId: String, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func updateLastViewDateForChannel(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func updateHeader(_ header: String, channel:Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func updatePurpose(_ purpose: String, channel:Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func update(newDisplayName:String, newName: String, channel:Channel, completion:@escaping (_ error: Mattermost.Error?) -> Void)
    //func loadChannelsMoreWithCompletion(_ completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadChannelsMoreWithCompletion(_ completion: @escaping (_ channels: Array<Channel>?, _ error: Mattermost.Error?) -> Void)
    func addUserToChannel(_ user:User, channel:Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func createChannel(_ type: String, displayName: String, name: String, header: String, purpose: String, completion: @escaping (_ channel: Channel?, _ error: Error?) -> Void)
    func createDirectChannelWith(_ user: User, completion: @escaping (_ channel: Channel?, _ error: Mattermost.Error?) -> Void)
    func leaveChannel(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func joinChannel(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func delete(channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func getChannel(channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func getChannelMembers(completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func getChannelMember(channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
}

private protocol UserApi: class {
    func login(_ email: String, password: String, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadCurrentUser(completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func update(firstName: String?, lastName: String?, userName: String?, nickName: String?, email: String?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func update(currentPassword: String, newPassword: String, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func update(profileImage: UIImage, completion: @escaping (_ error: Mattermost.Error?) -> Void, progress: @escaping (_ value: Float) -> Void)
    func subscribeToRemoteNotifications(completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func passwordResetFor(email: String, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    
    func loadUsersListBy(ids: [String], completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadCompleteUsersList(_ completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadUsersListFrom(channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func loadUsersAreNotIn(channel: Channel, completion: @escaping (_ error: Mattermost.Error?,_ users: Array<User>? ) -> Void)
    func loadUsersFromCurrentTeam(completion: @escaping (_ error: Mattermost.Error?,_ users: Array<User>? ) -> Void)
    func autocompleteUsersIn(channel: Channel, completion: @escaping (_ error: Mattermost.Error?,_ usersInChannel: Array<User>?, _ usersOutOfChannel:  Array<User>?) -> Void)
    func loadMissingAuthorsFor(posts: [Post], completion: @escaping (_ error: Mattermost.Error?) -> Void)
}

private protocol PostApi: class {
    func sendPost(_ post: Post, completion:  @escaping(_ error: Mattermost.Error?) -> Void)
    func getPostWithId(_ identifier: String, channel: Channel, completion: @escaping ((_ post: Post?, _ error: Error?) -> Void))
    func updatePost(_ post: Post, completion:  @escaping(_ error: Mattermost.Error?) -> Void)
    func updateSinglePost(post: Post, postId: String, channelId: String, message: String, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func deletePost(_ post: Post, completion:  @escaping(_ error: Mattermost.Error?) -> Void)
    func searchPostsWithTerms(terms: String, channel: Channel, completion: @escaping(_ posts: Array<Post>?, _ error: Error?) -> Void)
    func loadFirstPage(_ channel: Channel, completion:  @escaping(_ error: Mattermost.Error?) -> Void)
    func loadNextPage(_ channel: Channel, fromPost: Post, completion:  @escaping(_ isLastPage: Bool, _ error: Mattermost.Error?) -> Void)
    func loadPostsBeforePost(post: Post/*, shortList: Bool?*/, completion: @escaping(_ isLastPage: Bool, _ error: Error?) -> Void)
    func loadPostsAfterPost(post: Post/*, shortList: Bool?*/, completion: @escaping(_ isLastPage: Bool, _ error: Error?) -> Void)
}

private protocol FileApi : class {
    func cancelUploadingOperationForImageItem(_ item: AssignedAttachmentViewItem)
    func getInfo(fileId: String)
    func loadFileInfosFor(posts: [Post], completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func getFileInfos(post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
}

final class Api {
    
//MARK: Properties
    static let sharedInstance = Api()
    fileprivate var _managerCache: ObjectManager?
    fileprivate var downloadOperationsArray = Array<AFRKHTTPRequestOperation>()
    fileprivate var networkReachabilityManager = NetworkReachabilityManager.init()
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
    
//MARK: LifeCycle
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


//MARK: PreferencesApi
extension Api: PreferencesApi {
    func savePreferencesWith(_ params: Dictionary<String, String>, complection: @escaping (_ error: Mattermost.Error?) -> Void) {
       let path = PreferencesPathPatternsContainer.savePathPattern()
        
        self.manager.savePreferencesAt(path: path, parameters: [params], success: { (success) in
            DispatchQueue.main.async {
                complection(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                complection(error)
            }
        }
    }
    
    func listPreferencesWith(_ category: NSString, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let preference = Preference()
        preference.category = "direct_channel_show"
        let path = SOCStringFromStringWithObject(PreferencesPathPatternsContainer.listPreferencesPathPatterns(), preference)!
        
        self.manager.get(path: path, success: { (mappingResult, skipMapping) in
            let preferences = MappingUtils.fetchAllPreferences(mappingResult)
            for preference in preferences {
                let user = User.objectById(preference.name!)
                if (user?.hasChannel())! {
                    let channel = user?.directChannel()
                    try! RealmUtils.realmForCurrentThread().write {
                        channel?.isDirectPrefered = ((preference as Preference).value == Constants.CommonStrings.True)
                    }
                }
            }
            DispatchQueue.main.async {
                completion(nil)
            }
            }, failure: { (error) in
                DispatchQueue.main.async {
                    completion(error)
                }
        })
    }
}


//MARK: NotifyProps
extension Api: NotifyPropsApi {
    func updateNotifyProps(_ notifyProps: NotifyProps, completion: @escaping(_ error: Mattermost.Error?) -> Void) {
        let path = NotifyPropsPathPatternsContainer.updatePathPattern()
        
        self.manager.post(object: notifyProps, path: path, parameters: nil, success: { (mappingResult) in
            let object = mappingResult.dictionary()["notify_props"] as! NotifyProps
            let notifyProps = DataManager.sharedInstance.currentUser?.notificationProperies()
//Will replace after connection problems solved
            try! RealmUtils.realmForCurrentThread().write {
                notifyProps?.channel = object.channel
                notifyProps?.comments = object.comments
                notifyProps?.desktop = object.desktop
                notifyProps?.desktopDuration = object.desktopDuration
                notifyProps?.desktopSound = object.desktopSound
                notifyProps?.email = object.email
                notifyProps?.firstName = object.firstName
                notifyProps?.mentionKeys = object.mentionKeys
                notifyProps?.push = object.push
                notifyProps?.pushStatus = notifyProps?.pushStatus
            }
            DispatchQueue.main.async {
                completion(nil)
            }
            }, failure: { (error) in
                DispatchQueue.main.async {
                    completion(error)
                }
        })
    }
}


//MARK: TeamApi
extension Api: TeamApi {
    func loadTeams(with completion:@escaping (_ userShouldSelectTeam: Bool, _ error: Mattermost.Error?) -> Void) {
        let path = TeamPathPatternsContainer.initialLoadPathPattern()
        
        self.manager.get(path: path, success: { (mappingResult, skipMapping) in
            let teams = MappingUtils.fetchAllTeams(mappingResult)
            //let users = MappingUtils.fetchUsersFromInitialLoad(mappingResult)
            let preferences = MappingUtils.fetchPreferencesFromInitialLoad(mappingResult)
            preferences.forEach{ $0.computeKey() }
            Preferences.sharedInstance.siteName = MappingUtils.fetchSiteName(mappingResult)
            RealmUtils.save(teams)
            let currentUser = DataManager.sharedInstance.currentUser
            let realm = RealmUtils.realmForCurrentThread()
            let oldPreferences = currentUser?.preferences
            try! realm.write {
                currentUser?.preferences.removeAll()
                realm.delete(oldPreferences!)
                realm.add(preferences, update: true)
                currentUser?.preferences.append(objectsIn: preferences)
            }
            if (teams.count == 1) {
                DataManager.sharedInstance.currentTeam = teams.first
                Preferences.sharedInstance.currentTeamId = teams.first?.identifier
                Preferences.sharedInstance.save()
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                
            } else {
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(true, error)
            }
        }
    }
    
    func checkURL(with completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = TeamPathPatternsContainer.initialLoadPathPattern()
        self._managerCache = nil
        
        self.manager.get(path: path, success: { (mappingResult, skipMapping) in
            Preferences.sharedInstance.siteName = MappingUtils.fetchSiteName(mappingResult)
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func sendInvites(_ invites: [Dictionary<String , String>], completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(TeamPathPatternsContainer.teamInviteMembers(), DataManager.sharedInstance.currentTeam)
        let params: Dictionary = ["invites" : invites]
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    func loadTeamMembersListBy(ids: [String], completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let currentTeam = DataManager.sharedInstance.currentTeam
        let path = SOCStringFromStringWithObject(TeamPathPatternsContainer.teamMembersIds(), currentTeam)
        
        self.manager.post(nil, path: path, parametersAs: ids, success: { (operation, mappingResult) in
            let teamMembers = mappingResult?.array() as! [Member]
            let realm = RealmUtils.realmForCurrentThread()
            for teamMember in teamMembers {
                let user = realm.object(ofType: User.self, forPrimaryKey: teamMember.userId)
                try! realm.write {
                    user?.isOnTeam = true
                    user?.directChannel()?.isInterlocuterOnTeam = true
                }
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (operation, error) in
            DispatchQueue.main.async {
                completion(Error.errorWithGenericError(error))
            }
        }
    }
}


//MARK: ChannelApi
extension Api: ChannelApi {
    func loadChannels(with completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.listPathPattern(), DataManager.sharedInstance.currentTeam)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let realm = RealmUtils.realmForCurrentThread()
            
            let channels = mappingResult.array() as! [Channel]//MappingUtils.fetchAllChannelsFromList(mappingResult)
            let oldChannels = try! Realm().objects(Channel.self)
            try! realm.write({
                oldChannels.forEach {
                    $0.currentUserInChannel = false
                }
                channels.forEach {
                    $0.currentUserInChannel = true
                    $0.computeTeam()
                    $0.gradientType = Int(arc4random_uniform(5))
                    realm.add($0, update: true)
                }
            })
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func loadExtraInfoForChannel(_ channelId: String, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let teamId = Preferences.sharedInstance.currentTeamId
        let newChannel = Channel()
        newChannel.identifier = channelId
        newChannel.team = RealmUtils.realmForCurrentThread().object(ofType: Team.self, forPrimaryKey: teamId)
        let path =  SOCStringFromStringWithObject(ChannelPathPatternsContainer.loadOnePathPattern(), newChannel)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let channelDictionary = Reflection.fetchNotNullValues(object: mappingResult.firstObject as! Channel)
            RealmUtils.create(channelDictionary)
            let updatedChannel = try! Realm().objects(Channel.self).filter("identifier = %@", (mappingResult.firstObject as! Channel).identifier!).first!
            let realm = RealmUtils.realmForCurrentThread()
            try! realm.write({
                let updatedMembers = updatedChannel.members
                for member in updatedMembers{
                    member.computeDisplayNameWidth()
                }
            })
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func updateLastViewDateForChannel(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.updateLastViewDatePathPattern(), channel)
        let channelId = channel.identifier!
        self.manager.post(path: path, success: { (mappingResult) in
            let channel = Channel.objectById(channelId)!
            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - channel.mentionsCount  
            try! RealmUtils.realmForCurrentThread().write({
                channel.lastViewDate = channel.lastPostDate
                channel.mentionsCount = 0
            })
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func loadChannelsMoreWithCompletion(_ completion: @escaping (_ channels: Array<Channel>?, _ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.moreListPathPattern(), DataManager.sharedInstance.currentTeam)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let allChannels = MappingUtils.fetchAllChannelsFromList(mappingResult)
            DispatchQueue.main.async {
                completion(allChannels, nil)
            }
        }, failure: { (error) in
            DispatchQueue.main.async {
                completion(nil, error)
            }
        })
    }
    
    func addUserToChannel(_ user:User, channel:Channel, completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.addUserPathPattern(), channel)
        let params: Dictionary<String, String> = [ "user_id" : user.identifier ]
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func updateHeader(_ header:String, channel:Channel, completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.updateHeader(), channel)
        let channelId = channel.identifier
        let params: Dictionary<String, String> = [ "channel_header" : header, "channel_id" : channel.identifier! ]
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            let realm = RealmUtils.realmForCurrentThread()
            let channel = realm.object(ofType: Channel.self, forPrimaryKey: channelId)
            try! realm.write {
                channel?.header = header
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func updatePurpose(_ purpose:String, channel:Channel, completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.updatePurpose(), channel)
        let channelId = channel.identifier
        let params: Dictionary<String, String> = [ "channel_purpose" : purpose, "channel_id" : channel.identifier! ]
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            let realm = RealmUtils.realmForCurrentThread()
            let channel = realm.object(ofType: Channel.self, forPrimaryKey: channelId)
            try! realm.write {
                channel?.purpose = purpose
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func update(newDisplayName:String, newName: String, channel:Channel, completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.update(), channel)
        
        let params: Dictionary<String, Any> = [
            "create_at"       : Int(channel.createdAt!.timeIntervalSince1970),
            "creator_id"      : String(Preferences.sharedInstance.currentUserId!)!,
            "delete_at"       : 0,
            "display_name"    : newDisplayName,
            "extra_update_at" : Int(NSDate().timeIntervalSince1970),
            "header"          : channel.header!,
            "id"              : channel.identifier!,
            "last_post_at"    : Int(channel.lastPostDate!.timeIntervalSince1970),
            "name"            : newName,
            "purpose"         : channel.purpose!,
            "team_id"         : channel.team!.identifier!,
            "total_msg_count" : Int(channel.messagesCount!)!,
            "type"            : channel.privateType!,
            "update_at"       : Int(NSDate().timeIntervalSince1970)]
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    
    func createChannel(_ type: String, displayName: String, name: String, header: String, purpose: String, completion: @escaping (_ channel: Channel?, _ error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.createChannelPathPattern(), DataManager.sharedInstance.currentTeam)
      
        let newChannel = Channel()
        newChannel.privateType = type
        newChannel.name = name.lowercased()
        newChannel.displayName = displayName
        newChannel.header = header
        newChannel.purpose = purpose
        
        RealmUtils.save(newChannel)
        
        self.manager.post(object: newChannel, path: path, parameters: nil, success: { (mappingResult) in
            let realm = RealmUtils.realmForCurrentThread()
            let channel = mappingResult.firstObject as! Channel
            try! realm.write({
                channel.currentUserInChannel = true
                channel.computeTeam()
                channel.computeDispayNameIfNeeded()
                channel.gradientType = Int(arc4random_uniform(5))
                realm.add(channel)
            })
            DispatchQueue.main.async {
                completion(channel ,nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }

    func createDirectChannelWith(_ user: User, completion: @escaping (_ channel: Channel?, _ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.createDirrectChannelPathPattern(), DataManager.sharedInstance.currentTeam)
        let params: Dictionary<String, String> = [ "user_id" : user.identifier ]
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            let realm = RealmUtils.realmForCurrentThread()
            let channel = mappingResult.firstObject as! Channel
            try! realm.write({
                channel.currentUserInChannel = true
                channel.computeTeam()
                channel.computeDispayNameIfNeeded()
                realm.add(channel)
            })
            DispatchQueue.main.async {
                completion(nil ,nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
    
    func leaveChannel(_ channel: Channel, completion: @escaping (Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.leaveChannelPathPattern(), channel)
        
        self.manager.post(object: nil, path: path, parameters: nil, success: { (mappingResult) in
            let channelId = (mappingResult.firstObject as! Channel).identifier
            
            try! RealmUtils.realmForCurrentThread().write {
                Channel.objectById(channelId!)?.currentUserInChannel = false
            }
            
            let notificationName = Constants.NotificationsNames.UserJoinNotification
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: channel)
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func joinChannel(_ channel: Channel, completion: @escaping (Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.joinChannelPathPattern(), channel)
        
        self.manager.post(object: nil, path: path, parameters: nil, success: { (mappingResult) in
            let channelId = (mappingResult.firstObject as! Channel).identifier
            
            try! RealmUtils.realmForCurrentThread().write {
                Channel.objectById(channelId!)?.currentUserInChannel = true
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func delete(channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.deleteChannelPathPattern(), channel)
        
        self.manager.post(path: path, success: { (mappingResult) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }, failure: { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        })
    }
    
    //TODO: BrightFutures
    func fetchFilesForPost(channelId: String, postId: String, completion: @escaping (_ error: Mattermost.Error?, _ files: [File]) -> Void) {
        let wrapper = FileWrapper(channelId: channelId, postId: postId)
        let path = SOCStringFromStringWithObject(FilePathPatternsContainer.getFileInfosPathPattern(), wrapper)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let files = mappingResult.array() as! [File]
            DispatchQueue.main.async {
                completion(nil, files)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error, [File]())
            }
        }
    }
    //TODO: BrightFutures
    func fetchChannel(channelId: String, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        guard let channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId) else {
            return
        }
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.getChannelPathPattern(), channel)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let realm = RealmUtils.realmForCurrentThread()
            guard let channel = realm.object(ofType: Channel.self, forPrimaryKey: channelId) else {
                return
            }
            let obtainedChannel = MappingUtils.fetchAllChannels(mappingResult).first
            
            try! realm.write({
                channel.updateAt = obtainedChannel?.updateAt
                channel.deleteAt = obtainedChannel?.deleteAt
                channel.displayName = obtainedChannel?.displayName!
                channel.name = obtainedChannel?.name!
                channel.header = obtainedChannel?.header!
                channel.purpose = obtainedChannel?.purpose!
                channel.lastPostDate = obtainedChannel?.lastPostDate
                channel.messagesCount = obtainedChannel?.messagesCount
                channel.extraUpdateDate = obtainedChannel?.extraUpdateDate
                channel.mentionsCount = obtainedChannel!.mentionsCount
            })
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
 
    }
    
    //FIXMEGETCHANNEL
    func getChannel(channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.getChannelPathPattern(), channel)
        let channelRef = ThreadSafeReference(to: channel)
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let realm = RealmUtils.realmForCurrentThread()
            let obtainedChannel = MappingUtils.fetchAllChannels(mappingResult).first
            let channel = realm.resolve(channelRef)!
            try! realm.write({
                channel.updateAt = obtainedChannel?.updateAt
                channel.deleteAt = obtainedChannel?.deleteAt
                channel.displayName = obtainedChannel?.displayName!
                channel.name = obtainedChannel?.name!
                channel.header = obtainedChannel?.header!
                channel.purpose = obtainedChannel?.purpose!
                channel.lastPostDate = obtainedChannel?.lastPostDate
                channel.messagesCount = obtainedChannel?.messagesCount
                channel.extraUpdateDate = obtainedChannel?.extraUpdateDate
                //channel.mentionsCount = obtainedChannel!.mentionsCount
            })
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func getChannelMembers(completion: @escaping (Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.getChannelMembersPathPattern(), DataManager.sharedInstance.currentTeam)
        self.manager.getObjectsAt(path: path!, success: {  (operation, mappingResult) in
            let realm = RealmUtils.realmForCurrentThread()
            let data = operation.httpRequestOperation.responseData
            let responseArray = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Array<Dictionary<String, Any>>
            
            try! realm.write({
                responseArray.forEach {
                    let newMentionsCount = ($0["mention_count"]! as! NSNumber).intValue
                    guard let updateChannel = try! Realm().objects(Channel.self).filter("identifier = %@", $0["channel_id"]!).first else { return }
                    updateChannel.lastViewDate = Date(timeIntervalSince1970: TimeInterval(($0["last_viewed_at"]! as! NSNumber).doubleValue) / 1000)
                    updateChannel.messagesCount! = String(describing: ($0["msg_count"]! as! NSNumber).intValue)
                    updateChannel.mentionsCount = newMentionsCount
                }
            })
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func getChannelMember(channel: Channel, completion: @escaping (Error?) -> Void) {
        let path = SOCStringFromStringWithObject(ChannelPathPatternsContainer.getChannelMemberPathPattern(), channel)
        self.manager.getObjectsAt(path: path!, success: {  (operation, mappingResult) in
            let realm = RealmUtils.realmForCurrentThread()
            let data = operation.httpRequestOperation.responseData
            let responseDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
            
            try! realm.write({
                let newMentionsCount = (responseDictionary["mention_count"]! as! NSNumber).intValue
                guard let updateChannel = try! Realm().objects(Channel.self).filter("identifier = %@", responseDictionary["channel_id"]!).first else { return }
                updateChannel.lastViewDate = Date(timeIntervalSince1970: TimeInterval((responseDictionary["last_viewed_at"]! as! NSNumber).doubleValue) / 1000)
                updateChannel.messagesCount! = String(describing: (responseDictionary["msg_count"]! as! NSNumber).intValue)
                updateChannel.mentionsCount = newMentionsCount
            })
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
}


//MARK: UserApi
extension Api: UserApi {
    func login(_ email: String, password: String, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = UserPathPatternsContainer.loginPathPattern()
        let parameters = ["login_id" : email, "password": password, "token" : ""]
        
        self.manager.post(path: path, parameters: parameters as [AnyHashable: Any]?, success: { (mappingResult) in
            let user = mappingResult.firstObject as! User
            let notifyProps = user.notifyProps
            notifyProps?.userId = user.identifier
            notifyProps?.computeKey()
            let systemUser = DataManager.sharedInstance.instantiateSystemUser()
            user.computeDisplayName()
            DataManager.sharedInstance.currentUser = user
            RealmUtils.save([user, systemUser])
            RealmUtils.save(notifyProps!)
            
            _ = DataManager.sharedInstance.currentUser

            SocketManager.sharedInstance.setNeedsConnect()
            NotificationsUtils.subscribeToRemoteNotificationsIfNeeded(completion: completion)
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func logout(_ completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = UserPathPatternsContainer.logoutPathPattern()
        let parameters = ["user_id" : Preferences.sharedInstance.currentUserId!]
        
        self.manager.post(path: path, parameters: parameters, success: { (mappingResult) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func loadCurrentUser(completion: @escaping (Error?) -> Void) {
        let path = UserPathPatternsContainer.loadCurrentUser()
        
        self.manager.get(path: path, success: { (mappingResult, skipMapping) in
            UserUtils.updateCurrentUserWith(serverUser: mappingResult.firstObject as! User)
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func loadUsersListBy(ids: [String], completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = UserPathPatternsContainer.usersByIdsPathPattern()
        
        self.manager.post(path: path, arrayParameters: ids, success: { (operation, mappingResult) in
            let responseDictionary = operation.httpRequestOperation.responseString!.toDictionary()
            let users = MappingUtils.fetchUsersFrom(response: responseDictionary!)
            users.forEach({ UserUtils.updateOnTeamAndPreferedStatesFor(user: $0) })
            DispatchQueue.main.async {
                completion(nil)
            }

        }, failure: { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        })

    }
    
    func loadCompleteUsersList(_ completion:@escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(UserPathPatternsContainer.completeListPathPattern(), DataManager.sharedInstance.currentTeam)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let users = MappingUtils.fetchUsersFromCompleteList(mappingResult)
            users.forEach {$0.computeDisplayName()}
            RealmUtils.save(users)
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func loadUsersList(offset: Int, completion: @escaping (_ users: Array<User>?, _ error: Mattermost.Error?) -> Void) {
        let pageWrapper = PageWrapper(size: 100, channel: Channel(), offset: 0)//PageWrapper.usersListPageWrapper(offset: offset)
        let path = SOCStringFromStringWithObject(UserPathPatternsContainer.usersListPathPattern(), pageWrapper)
        
        self.manager.getObjectsAt(path: path!, success: {  (operation, mappingResult) in
            let responseDictionary = operation.httpRequestOperation.responseString!.toDictionary()
            let users = MappingUtils.fetchUsersFrom(response: responseDictionary!)
            DispatchQueue.main.async {
                completion(users, nil)
            }
            
        }, failure:{ error in
            DispatchQueue.main.async {
                completion(nil, error)
            }
        })
    }
    
    func loadUsersListFrom(channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(UserPathPatternsContainer.usersFromChannelPathPattern(), channel)!
        let channelId = channel.identifier!
        self.manager.getObjectsAt(path: path, success: {  (operation, mappingResult) in
            let responseDictionary = operation.httpRequestOperation.responseString!.toDictionary()
            let users = MappingUtils.fetchUsersFrom(response: responseDictionary!)
            let channel = Channel.objectById(channelId)!
            users.forEach({ UserUtils.updateOnTeamAndPreferedStatesFor(user: $0) })
            for user in users {
                let existUser = User.objectById(user.identifier)
                if !channel.members.contains(where: { $0.identifier == existUser?.identifier }) {
                    let realm = RealmUtils.realmForCurrentThread()
                    try! realm.write { channel.members.append(existUser!) }
                }
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func loadUsersAreNotIn(channel: Channel, completion: @escaping (_ error: Mattermost.Error?,_ users: Array<User>? ) -> Void){
        let path = SOCStringFromStringWithObject(UserPathPatternsContainer.usersNotInChannelPathPattern(), channel)!
        self.manager.getObjectsAt(path: path, success: {  (operation, mappingResult) in
            //Temp cap
            let responseDictionary = operation.httpRequestOperation.responseString!.toDictionary()
            var users = Array<User>()
            let ids = Array(responseDictionary!.keys.map{$0})
            for userId in ids {
                let user = UserUtils.userFrom(dictionary: (responseDictionary?[userId])! as! Dictionary<String, Any>)
                users.append(user)
            }
            DispatchQueue.main.async {
                completion(nil, users)
            }
        }, failure:{ error in
            DispatchQueue.main.async {
                completion(error, nil)
            }
        })
    }
    
    func loadUsersFromCurrentTeam(completion: @escaping (_ error: Mattermost.Error?,_ users: Array<User>? ) -> Void) {
        let path = SOCStringFromStringWithObject(UserPathPatternsContainer.usersFromCurrentTeamPathPattern(), DataManager.sharedInstance.currentTeam)!
        self.manager.getObjectsAt(path: path, success: {  (operation, mappingResult) in
            let responseDictionary = operation.httpRequestOperation.responseString!.toDictionary()
            var users = Array<User>()
            let ids = Array(responseDictionary!.keys.map{$0})
            for userId in ids {
                let user = UserUtils.userFrom(dictionary: (responseDictionary?[userId])! as! Dictionary<String, Any>)
                users.append(user)
            }
            DispatchQueue.main.async {
                completion(nil, users)
            }
            
        }, failure:{ error in
            DispatchQueue.main.async {
                completion(error, nil)
            }
        })
    }
    
    func autocompleteUsersIn(channel: Channel, completion: @escaping (_ error: Mattermost.Error?,_ usersInChannel: Array<User>?, _ usersOutOfChannel:  Array<User>?) -> Void) {
        let path = SOCStringFromStringWithObject(UserPathPatternsContainer.autocompleteUsersInChannelPathPattern(), channel)!
        self.manager.getObjectsAt(path: path, success: {  (operation, mappingResult) in
            let responseDictionary = operation.httpRequestOperation.responseString!.toDictionary()
            let inChannelDictionary = responseDictionary?["in_channel"] as! Array<Dictionary<String, Any>>
            let outOfChannelDictionary = responseDictionary?["out_of_channel"] as! Array<Dictionary<String, Any>>
            var usersInChannel = Array<User>()
            var usersOutOfChannel = Array<User>()
            for userDescription in inChannelDictionary {
                let user = UserUtils.userFrom(dictionary: userDescription)
                usersInChannel.append(user)
            }
            for userDescription in outOfChannelDictionary {
                let user = UserUtils.userFrom(dictionary: userDescription)
                usersOutOfChannel.append(user)
            }
            DispatchQueue.main.async {
                completion(nil, usersInChannel, usersOutOfChannel)
            }
        }, failure:{ error in
            completion(error, nil, nil)
        })
    }
    func update(firstName: String? = nil,
                lastName: String? = nil,
                userName: String? = nil,
                nickName: String? = nil,
                email: String? = nil,
                completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = UserPathPatternsContainer.userUpdatePathPattern()
        let user = DataManager.sharedInstance.currentUser
        
        var params: [String : Any] = ["id" : user?.identifier! as Any,
                                      "create_at" : (user?.createAt?.timeIntervalSince1970)! * 1000]
        params["first_name"] = firstName ?? user?.firstName
        params["last_name"] = lastName ?? user?.lastName
        params["nickname"] = nickName ?? user?.nickname
        params["username"] = userName ?? user?.username
        params["email"] = email ?? user?.email
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            let realm = RealmUtils.realmForCurrentThread()
            try! realm.write {
                user?.firstName = firstName ?? user?.firstName
                user?.lastName = lastName ?? user?.lastName
                user?.nickname = nickName ?? user?.nickname
                user?.username = userName ?? user?.username
                user?.displayName = userName ?? user?.username
                user?.computeDisplayNameWidth()
                user?.email = email ?? user?.email
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func update(currentPassword: String, newPassword: String, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = UserPathPatternsContainer.userUpdatePasswordPathPattern()
        
        let params = ["user_id" : DataManager.sharedInstance.currentUser?.identifier as Any,
                      "current_password" : currentPassword,
                      "new_password" : newPassword] as [String : Any]
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func update(profileImage: UIImage,
                completion: @escaping (_ error: Mattermost.Error?) -> Void,
                progress: @escaping (_ value: Float) -> Void) {
        let path = UserPathPatternsContainer.userUpdateImagePathPattern()
    
        self.manager.post(image: profileImage, identifier: "image_id", name: "image", path: path, parameters: nil, success: { (mappingResult) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }, failure: { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }) { (value) in
            DispatchQueue.main.async {
                progress(value)
            }
        }
    }
    
    func subscribeToRemoteNotifications(completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = UserPathPatternsContainer.attachDevicePathPattern()
        let deviceUUID = Preferences.sharedInstance.deviceUUID
        let params = ["device_id" : "apple:" + deviceUUID!]
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }, failure: { (error) in
            completion(error)
        })
    }
    
    func passwordResetFor(email: String, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = UserPathPatternsContainer.passwordResetPathPattern()
        let params = [ "email" : email ]
        
        self.manager.post(object: nil, path: path, parameters: params, success: { (mappingResult) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }, failure: { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        })
    }
    
    func loadMissingAuthorsFor(posts: [Post], completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        var missingUserIds = Array<String>()
        for post in posts {
            let authorId = post.authorId
            if User.objectById(authorId!) == nil && !missingUserIds.contains(authorId!) {
                missingUserIds.append(post.authorId!)
            }
        }
        
        guard missingUserIds.count > 0 else { completion(nil); return }
        
        self.loadUsersListBy(ids: missingUserIds, completion: { (error) in
            completion(error)
        })
    }
}


//MARK: PostApi
extension Api: PostApi {
    func loadFirstPage(_ channel: Channel, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.firstPagePathPattern(), PageWrapper(channel: channel))
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            guard !skipMapping else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let posts = MappingUtils.fetchConfiguredPosts(mappingResult)
            self.loadMissingAuthorsFor(posts: posts, completion: { (error) in
                if error != nil { print(error.debugDescription) }
                self.loadFileInfosFor(posts: posts, completion: { (error) in

                    RealmUtils.save(posts)
                    DispatchQueue.main.async {
                        completion(error)
                    }
                })
            })
        }) { (error) in
            if let error = error {
                if (error.code == -1011) {
                    let notificationName = Constants.NotificationsNames.UserJoinNotification
                    try! RealmUtils.realmForCurrentThread().write {
                        channel.currentUserInChannel = false
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: channel)
                }
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func loadNextPage(_ channel: Channel, fromPost: Post, completion: @escaping (_ isLastPage: Bool, _ error: Mattermost.Error?) -> Void) {
        guard fromPost.identifier != nil else { return }
        let postIdentifier = fromPost.identifier!
        let wrapper = PageWrapper(channel: channel, lastPostId: postIdentifier)
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.nextPagePathPattern(), wrapper)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let isLastPage = MappingUtils.isLastPage(mappingResult, pageSize: wrapper.size)
            guard !skipMapping else { completion(isLastPage, nil); return }
            
            let posts = MappingUtils.fetchConfiguredPosts(mappingResult)
            
            self.loadMissingAuthorsFor(posts: posts, completion: { (error) in
                if error != nil { print(error.debugDescription) }
                
                self.loadFileInfosFor(posts: posts, completion: { (error) in
                    RealmUtils.save(posts)
                    DispatchQueue.main.async {
                        completion(isLastPage, nil)
                    }
                })
            })
        }) { (error) in
            let isLastPage = (error!.code == 1001) ? true : false
            DispatchQueue.main.async {
                completion(isLastPage, error)
            }
        }
    }
    
    func loadPostsBeforePost(post: Post/*, shortList: Bool? = false*/, completion: @escaping(_ isLastPage: Bool, _ error: Error?) -> Void) {
        //let size = (shortList == true) ? 10 : 60
        let wrapper = PageWrapper(size: 60, channel: post.channel, lastPostId: post.identifier)
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.beforePostPathPattern(), wrapper)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let isLastPage = MappingUtils.isLastPage(mappingResult, pageSize: wrapper.size)
            guard !skipMapping else { completion(isLastPage, nil); return }
            
            let posts = MappingUtils.fetchConfiguredPosts(mappingResult)
            self.loadMissingAuthorsFor(posts: posts, completion: { (error) in
                if error != nil { print(error.debugDescription) }
                
                self.loadFileInfosFor(posts: posts, completion: { (error) in
                    RealmUtils.save(posts)
                    completion(isLastPage, nil)
                })
            })
            
        }) { (error) in
            let isLastPage = (error!.code == 1001) ? true : false
            DispatchQueue.main.async {
                completion(isLastPage, error)
            }
        }
    }
    
    func loadPostsAfterPost(post: Post,/* shortList: Bool? = false,*/ completion: @escaping(_ isLastPage: Bool, _ error: Error?) -> Void) {
        //let size = (shortList == true) ? 10 : 60
        let wrapper = PageWrapper(size: 60, channel: post.channel, lastPostId: post.identifier)
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.afterPostPathPattern(), wrapper)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let isLastPage = MappingUtils.isLastPage(mappingResult, pageSize: wrapper.size)
            guard !skipMapping else { completion(isLastPage, nil); return }
            
            let posts = MappingUtils.fetchConfiguredPosts(mappingResult)
            
            self.loadMissingAuthorsFor(posts: posts, completion: { (error) in
                if error != nil { print(error.debugDescription) }
                
                self.loadFileInfosFor(posts: posts, completion: { (error) in
                    RealmUtils.save(posts)
                    DispatchQueue.main.async {
                        completion(isLastPage, error)
                    }
                })
            })
            

        }) { (error) in
            let isLastPage = (error!.code == 1001) ? true : false
            DispatchQueue.main.async {
                completion(isLastPage, error)
            }
        }
    }
    
    func sendPost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.creationPathPattern(), post)

        let array: NSMutableArray = NSMutableArray()
        post.files.forEach({array.add($0.identifier as! NSString)})
        self.manager.post(post, path: path, parameters: ["file_ids" : array.copy()], success: { (operation, mappingResult) in
            let resultPost = mappingResult?.firstObject as! Post
            try! RealmUtils.realmForCurrentThread().write {
                //addition parameters
                post.status = .default
                post.identifier = resultPost.identifier
            }
        }) { (operation, error) in
            completion(Mattermost.Error(error: error))
        }
    }
    
    func getPostWithId(_ identifier: String, channel: Channel, completion: @escaping ((_ post: Post?, _ error: Error?) -> Void)) {
        var path = "teams/" + (channel.team?.identifier)!
            path += "/channels/" + channel.identifier!
            path += "/posts/" + identifier + "/get"
        self.manager.get(path: path, success: { (mappingResult, canSkipMapping) in
            let resultPost = mappingResult.firstObject as! Post
            resultPost.computeMissingFields()
            RealmUtils.save(resultPost)
            completion(resultPost, nil)
        }) { (error) in
            completion(nil, error)
        }
    }
    
    func updateSinglePost(post: Post, postId: String, channelId: String, message: String, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.updatingPathPattern(), post)
        let parameters = ["message" : message, "id": postId, "channel_id" : channelId ]
        let postReference = ThreadSafeReference(to: post)
        
        self.manager.post(object: post, path: path, parameters: parameters, success: { (mappingResult) in
            RealmUtils.realmQueue.async {
                let updatedPost = mappingResult.firstObject as! Post
                let realm = RealmUtils.realmForCurrentThread()
                guard let post = realm.resolve(postReference) else {
                    return
                }
                try! realm.write ({
                    post.updatedAt = updatedPost.updatedAt
                    post.createdAt = updatedPost.createdAt
                    post.message = updatedPost.message
                    post.configureBackendPendingId()
    //                    assignFilesToPostIfNeeded(post)
                    post.computeMissingFields()
                })
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
            completion(error)
            }
        }
    }
    
    func deletePost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.deletingPathPattern(), post)
        let params = ["team_id"    : Preferences.sharedInstance.currentTeamId!,
                      "channel_id" : post.channelId!,
                      "post_id"    : post.identifier!]
        
        self.manager.deletePostAt(path: path, parameters: params, success: { (mappingResult) in
            completion(nil)
        }) { (error) in
            completion(error)
        }
    }
    
    func searchPostsWithTerms(terms: String, channel: Channel, completion: @escaping(_ posts: Array<Post>?, _ error: Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.searchingPathPattern(), channel)
        let params = ["team_id" : Preferences.sharedInstance.currentTeamId!]
        
        self.manager.searchPostsWith(terms: terms, path: path, parameters: params, success: { (mappingResult) in
            
            let posts = MappingUtils.fetchConfiguredPosts(mappingResult)
            
            self.loadMissingAuthorsFor(posts: posts, completion: { (error) in
                if error != nil { print(error.debugDescription) }
                
                self.loadFileInfosFor(posts: posts, completion: { (error) in
                    DispatchQueue.main.async {
                        RealmUtils.save(posts)
                        completion(posts, nil)
                    }
                    
                })
                
            })
        }) { (error) in
            DispatchQueue.main.async {
                completion(nil, error)
            }
            
        }
    }
    
    func updatePost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.updatePathPattern(), post)
                
        self.manager.get(object: post, path: path!, success: { (mappingResult, skipMapping) in
            RealmUtils.save(MappingUtils.fetchPostFromUpdate(mappingResult))
            completion(nil)
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
}


//MARK: FileApi
extension Api : FileApi {
    func cancelUploadingOperationForImageItem(_ item: AssignedAttachmentViewItem) {
        self.manager.cancelUploadingOperationForImageItem(item)
    }
    
    func uploadFileItemAtChannel(_ item: AssignedAttachmentViewItem,
                                  channel: Channel,
                                  completion: @escaping (_ identifier: String?, _ error: Mattermost.Error?) -> Void,
                                  progress: @escaping (_ identifier: String, _ value: Float) -> Void) {
        let path = SOCStringFromStringWithObject(FilePathPatternsContainer.uploadPathPattern(), DataManager.sharedInstance.currentTeam)
        let params = ["channel_id" : channel.identifier!,
                      "client_ids" : item.identifier]
        
        let particialCompletion = { (mappingResult: RKMappingResult) in
            let file = mappingResult.firstObject as! File
            RealmUtils.save(file)
            completion(file.identifier, nil)
        }
        
        if item.isFile {
            self.manager.postFileWith(url: item.url, identifier: params["client_ids"]!, name: "files", path: path, parameters: params, success: { (mappingResult) in
                particialCompletion(mappingResult)
                }, failure: { (error) in
                    completion(nil, error)
            }) { (value) in
                progress(item.identifier, value)
            }
        } else {
            self.manager.post(image: item.image, identifier: params["client_ids"]!, name: "files", path: path, parameters: params, success: { (mappingResult) in
                particialCompletion(mappingResult)
                }, failure: { (error) in
                    completion(nil, error)
            }) { (value) in
                progress(item.identifier, value)
            }
        }
    }
    
    func getFileInfos(post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let wrapper = FileWrapper(channelId: post.channelId, postId: post.identifier!)
        let path = SOCStringFromStringWithObject(FilePathPatternsContainer.getFileInfosPathPattern(), wrapper)
        
        self.manager.get(path: path!, success: { (mappingResult, skipMapping) in
            let fileInfos = mappingResult.array() as! [File]

            post.files.removeAll()
            
            
            for file in fileInfos {
                file.computeIsImage()
                file.computeRawLink()
                post.files.append(file)

            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
        
    }
    
    func loadFileInfosFor(posts: [Post], completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let filesGroup = DispatchGroup()
        var commonError: Mattermost.Error?
        for post in posts {
            guard post.files.count > 0 else {continue }
            
            filesGroup.enter()
            self.getFileInfos(post: post, completion: { (error) in
                commonError = error
                filesGroup.leave()
            })
        }

        filesGroup.notify(queue: ObjectManager.responseHandlerQueue) {
            completion(commonError)
        }
        

    }
    
    func getInfo(fileId: String) {
        var file = RealmUtils.realmForCurrentThread().object(ofType: File.self, forPrimaryKey: fileId)
        let path = "teams/" + (DataManager.sharedInstance.currentTeam?.identifier)! + "/files/get_info" + file!.rawLink!
        
        self.manager.get(path: path, success: { (mappingResult, skipMapping) in
            let realm = RealmUtils.realmForCurrentThread()
            file = realm.object(ofType: File.self, forPrimaryKey: fileId)
            let result = mappingResult.firstObject as! File
            try! realm.write {
                file?.ext = result.ext
                file?.size = result.size
                file?.hasPreview = result.hasPreview
                file?.mimeType = result.mimeType
            }
            let notification = Notification(name: NSNotification.Name(Constants.NotificationsNames.ReloadFileSizeNotification),
                                            object: nil, userInfo: ["fileId" : fileId, "fileSize" : result.size])
            NotificationCenter.default.post(notification as Notification)
            
        }) { (error) in
            print(error?.message! ?? "getInfo_error")
        }
    }
    
    func download(fileId: String,
                         completion: @escaping (_ error: Mattermost.Error?) -> Void,
                         progress: @escaping (_ identifier: String, _ value: Float) -> Void) {
        for operation in self.downloadOperationsArray {
            if (operation.userInfo["identifier"] as! String) == fileId {
                return
            }
        }
        
        var file = File.objectById(fileId)
        let request: NSMutableURLRequest = NSMutableURLRequest(url: file!.downloadURL()!)
        request.httpMethod = "GET"
        
        let filePath = FileUtils.localLinkFor(file: file!)
        let operation: AFRKHTTPRequestOperation = AFRKHTTPRequestOperation(request: request as URLRequest!)
        operation.outputStream = OutputStream(toFileAtPath: filePath, append: false)
        operation.userInfo = ["identifier" : fileId]
        
        operation.setDownloadProgressBlock { (written: UInt, totalWritten: Int64, expectedToWrite: Int64) -> Void in
            let result = Float(totalWritten) / Float(expectedToWrite)
            progress(fileId, result)
        }
        
        operation.setCompletionBlockWithSuccess({ (operation: AFRKHTTPRequestOperation?, responseObject: Any?) in
            let realm = RealmUtils.realmForCurrentThread()
            file = realm.object(ofType: File.self, forPrimaryKey: fileId)
            try! realm.write {
                file?.downoloadedSize = (file?.size)!
                file?.localLink = filePath
            }
            self.downloadOperationsArray.removeObject(operation!)
            completion(nil)
        }, failure: { (operation: AFRKHTTPRequestOperation?, error: Swift.Error?) -> Void in
            self.downloadOperationsArray.removeObject(operation!)
            let realm = RealmUtils.realmForCurrentThread()
            file = realm.object(ofType: File.self, forPrimaryKey: fileId)
            FileUtils.removeLocalCopyOf(file: file!)
            try! realm.write {
                file?.downoloadedSize = 0
                file?.localLink = nil
            }
            guard (error as! NSError).code != -999 else { return }
            completion(Error.errorWithGenericError(error))
        })
        operation.start()
        self.downloadOperationsArray.append(operation)
    }
    
    func cancelDownloading(fileId: String) {
        for operation in self.downloadOperationsArray {
            if (operation.userInfo["identifier"] as! String) == fileId {
                operation.cancel()
                self.downloadOperationsArray.removeObject(operation)
                break
            }
        }
    }
}


//MARK: Interface
extension Api: Interface {
    func baseURL() -> URL! {
        return self.manager.httpClient.baseURL
    }
    
    func avatarLinkForUser(_ user: User) -> String {
        let path = SOCStringFromStringWithObject(UserPathPatternsContainer.avatarPathPattern(), user)
        let url = URL(string: path!, relativeTo: self.manager.httpClient.baseURL)
        return url!.absoluteString
    }
    
    func cancelSearchRequestFor(channel: Channel) {
        let path = SOCStringFromStringWithObject(PostPathPatternsContainer.searchingPathPattern(), channel)
        self.manager.cancelAllObjectRequestOperations(with: .any, matchingPathPattern: path)
    }
    
    func isNetworkReachable() -> Bool {
        return (self.networkReachabilityManager?.isReachable)!
    }
}
