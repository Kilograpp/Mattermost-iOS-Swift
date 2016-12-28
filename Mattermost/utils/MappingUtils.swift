//
//  MappingUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit


final class MappingUtils {}

private protocol PreferenceMethods: class {
    static func fetchAllPreferences(_ mappingResult: RKMappingResult) -> [Preference]
}

private protocol TeamMethods: class {
    static func containsSingleTeam(_ mappingResult: RKMappingResult) -> Bool
    static func fetchSiteName(_ mappingResult: RKMappingResult) -> String?
    static func fetchAllTeams(_ mappingResult: RKMappingResult) -> [Team]
}

private protocol ChannelMethods: class {
    static func fetchAllChannelsFromList(_ mappingResult: RKMappingResult) -> [Channel]
}

private protocol PostMethods: class {
    static func isLastPage(_ mappingResult: RKMappingResult, pageSize: Int) -> Bool
    static func fetchConfiguredPosts(_ mappingResult: RKMappingResult) -> [Post]
    static func fetchPostFromUpdate(_ mappingResult: RKMappingResult) -> Post
}

private protocol UserMethod: class {
    static func fetchUsersFromInitialLoad(_ mappingResult: RKMappingResult) -> [User]
    static func fetchPreferencesFromInitialLoad(_ mappingResult: RKMappingResult) -> [Preference]
    static func fetchUsersFromCompleteList(_ mappingResult: RKMappingResult) -> [User]
    static func fetchUsersBy(ids: [String], response: Dictionary<String, Any>) -> [User]
}


//MARK: PreferenceMethods

extension MappingUtils: PreferenceMethods {
    static func fetchAllPreferences(_ mappingResult: RKMappingResult) -> [Preference] {
        return mappingResult.array() as! [Preference]
    }
}


// MARK: Team

extension MappingUtils: TeamMethods {
    static func containsSingleTeam(_ mappingResult: RKMappingResult) -> Bool {
        let resultDictionary = mappingResult.dictionary()
        let teams = resultDictionary?[Constants.CommonKeyPaths.Teams] as AnyObject
        return (teams.count == 1)
        //return (mappingResult.dictionary()["teams"] as AnyObject).count == 1
    }
    
    static func fetchSiteName(_ mappingResult: RKMappingResult) -> String? {
        //s3 refactor
        let resultDictionary = mappingResult.dictionary()
        let clientConfigDictionary = resultDictionary?["client_cfg"] as! [String:String]
        return clientConfigDictionary[PreferencesAttributes.siteName.rawValue]
    }
    
    static func fetchAllTeams(_ mappingResult: RKMappingResult) -> [Team] {
        return mappingResult.dictionary()[/*"teams"*/Constants.CommonKeyPaths.Teams] as! [Team]
    }
    
    static func fetchAllChannels(_ mappingResult: RKMappingResult) -> [Channel] {
        return mappingResult.array() as! [Channel]
    }
}

extension MappingUtils: PostMethods {
    static func fetchConfiguredPosts(_ mappingResult: RKMappingResult) -> [Post] {
        let posts = (mappingResult.array() as! [Post]).sorted(by: { $0.createdAt?.compare($1.createdAt! as Date) == .orderedAscending })
        var previousPost: Post?
        posts.forEach {
            $0.setSystemAuthorIfNeeded()
            $0.computeMissingFields()
            let existingPost = RealmUtils.realmForCurrentThread().objects(Post.self).filter("%K == %@", "identifier", $0.identifier!).first
            if existingPost != nil {
                $0.localIdentifier = existingPost!.localIdentifier!
            }
            $0.cellType = FeedCellBuilder.typeForPost($0, previous: previousPost)
            previousPost = $0
        }
        return posts
    }

    static func fetchPostFromUpdate(_ mappingResult: RKMappingResult) -> Post {
        return mappingResult.firstObject as! Post
    }
    static func isLastPage(_ mappingResult: RKMappingResult, pageSize: Int) -> Bool {
        return Int(mappingResult.count) < pageSize
    }
}

extension MappingUtils: UserMethod {
    static func fetchUsersFromInitialLoad(_ mappingResult: RKMappingResult) -> [User] {
        if let users = mappingResult.dictionary()["direct_profiles"] {
            return users as! [User]
        }
        return []
    }
    
    static func fetchPreferencesFromInitialLoad(_ mappingResult: RKMappingResult) -> [Preference] {
        if let preferences = mappingResult.dictionary()["preferences"] {
            return preferences as! [Preference]
        }
        return []
    }
        
    static func fetchUsersFromCompleteList(_ mappingResult: RKMappingResult) -> [User] {
        return mappingResult.array() as! [User]
    }

    static func fetchUsersBy(ids: [String], response: Dictionary<String, Any>) -> [User] {
        var users = Array<User>()
        for userId in ids {
            guard response[userId] != nil else { continue }
            
            let user = UserUtils.userFrom(dictionary: response[userId] as! Dictionary<String, Any>)
            users.append(user)
        }
        return users
    }
}

extension MappingUtils: ChannelMethods {
    static func fetchAllChannelsFromList(_ mappingResult: RKMappingResult) -> [Channel] {
        return mappingResult.array() as! [Channel]
    }
}
