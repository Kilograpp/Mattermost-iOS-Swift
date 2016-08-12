//
//  RKObjectManager+Additions.h
//  Mattermost
//
//  Created by Igor Vedeneev on 12.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

#import <RestKit/RestKit.h>

@interface RKObjectManager (Additions)
- (void)postObject:(id)object
              path:(NSString *)path
        parametersAsArray:(NSArray *)parameters
           success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success
           failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;
@end
