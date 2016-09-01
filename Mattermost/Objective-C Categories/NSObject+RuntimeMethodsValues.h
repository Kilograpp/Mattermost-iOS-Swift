//
//  NSObject+MethodDump.h
//  Mattermost
//
//  Created by Maxim Gubin on 07/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RuntimeMethodsValues)

+ (NSArray*)dumpValuesFromRootClass:(Class)rootClass withClassPrefix:(const NSString*)prefixToTrim;

@end
