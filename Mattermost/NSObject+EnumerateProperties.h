//
//  NSObject+EnumerateProperties.h
//  Mattermost
//
//  Created by Maxim Gubin on 28/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KGPropertyType) {
    KGTypeObject,
    KGTypePrimitiveBool,
    KGTypePrimitiveUnknown,
    KGTypeUnknown
};


@interface NSObject (EnumerateProperties)
- (void)enumeratePropertiesWithBlock:(void(^)(NSString* propertyName, KGPropertyType type))handler;
@end