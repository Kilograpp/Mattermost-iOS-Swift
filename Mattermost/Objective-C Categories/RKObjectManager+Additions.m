//
//  RKObjectManager+Additions.m
//  Mattermost
//
//  Created by Igor Vedeneev on 12.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

#import "RKObjectManager+Additions.h"

@implementation RKObjectManager (Additions)
- (void)postObject:(id)object
              path:(NSString *)path
        parametersAsArray:(NSArray *)parameters
           success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success
           failure:(void (^)(RKObjectRequestOperation *, NSError *))failure {
    [self postObject:object path:path parameters:parameters success:success failure:failure];
}
@end
