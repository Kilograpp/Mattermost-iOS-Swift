//
//  NSObject+EnumerateProperties.m
//  Mattermost
//
//  Created by Maxim Gubin on 28/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

#import "NSObject+EnumerateProperties.h"
#import <objc/runtime.h>

@implementation NSObject (EnumerateProperties)

- (void)enumeratePropertiesWithBlock:(void(^)(NSString* propertyName, KGPropertyType type))handler {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithCString:propName
                                                        encoding:[NSString defaultCStringEncoding]];
            if (handler) {
                handler(propertyName, getPropertyType(property));
            }
        }
    }
    free(properties);
}


static KGPropertyType getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            if (attribute[1] == 'c') {
                return KGTypePrimitiveBool;
            }
            return KGTypePrimitiveUnknown;
        }
        if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return KGTypeObject;//(const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return KGTypePrimitiveUnknown;
}


@end