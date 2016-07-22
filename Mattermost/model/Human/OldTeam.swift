import Foundation

@objc(Team)
public class Team: _Team {}

private protocol PathPatterns {
    static func teamListingsPathPattern() -> String
    static func initialLoadPathPattern() -> String
}

private protocol Mappings {
    static func entityMapping() -> RKEntityMapping
    static func configMapping() -> RKObjectMapping
}

private protocol ResponseDescriptors {
    static func teamListingsResponseDescriptor() -> RKResponseDescriptor
    static func initialLoadTeamsResponseDescriptor() -> RKResponseDescriptor
    static func initialLoadConfigResponseDescriptor() -> RKResponseDescriptor
}


// MARK: - Path Patterns
extension Team: PathPatterns {
    class func teamListingsPathPattern() -> String {
        return "teams/all_team_listings"
    }
    
    class func initialLoadPathPattern() -> String {
        return "users/initial_load"
    }
}

// MARK: - Mappings
extension Team: Mappings {
    override class func entityMapping() -> RKEntityMapping {
        let entityMapping = super.entityMapping()
        entityMapping.addAttributeMappingsFromDictionary([
            "display_name" : TeamAttributes.displayName.rawValue
        ])
        entityMapping.addAttributeMappingsFromArray([TeamAttributes.name.rawValue])
        return entityMapping
    }
    
    class func configMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(withClass: NSMutableDictionary.self)
        mapping.addAttributeMappingsFromDictionary([
            "SiteName" : CommonAttributes.SiteName.rawValue
        ])
        return mapping
    }
}

// MARK: - Response Descriptors
extension Team : ResponseDescriptors {
    class func initialLoadTeamsResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: entityMapping(),
                                     method: .GET,
                                pathPattern: initialLoadPathPattern(),
                                    keyPath: "teams",
                                statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    
    class func initialLoadConfigResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: configMapping(),
                                     method: .GET,
                                pathPattern: initialLoadPathPattern(),
                                    keyPath: "client_cfg",
                                statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    
    class func teamListingsResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: emptyResponseMapping(),
                                    method: .GET,
                                    pathPattern: teamListingsPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}

