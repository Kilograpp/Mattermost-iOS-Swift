//
//  NSObject+MethodDump.m
//  Mattermost
//
//  Created by Maxim Gubin on 07/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

#import "NSObject+RuntimeMethodsValues.h"
#import <objc/runtime.h>

NSArray *ClassGetSubclasses(Class parentClass);

@implementation NSObject (RuntimeMethodsValues)


+ (NSArray*)dumpValuesFromRootClass:(Class)rootClass withClassPrefix:(const NSString *)prefixToTrim {
    
    NSMutableArray* values = [NSMutableArray array];
    
    for (Class clazz in ClassGetSubclasses(rootClass)) {
        NSArray* methodNames = [self dumpMethodsFromClass:clazz prefixToTrim:prefixToTrim];
        
        for (NSString* methodName in methodNames) {
            
            SEL selector = NSSelectorFromString(methodName);
            if ([clazz respondsToSelector:selector]) {
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                            [[clazz class] methodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:clazz];
                [invocation invoke];
                id __unsafe_unretained value;
                [invocation getReturnValue:&value];
                [values addObject:value];
            }
        }
    }
    
    return [NSArray arrayWithArray: values];
}

+ (NSArray*)dumpMethodsFromClass:(Class)clz prefixToTrim:(const NSString *)prefixToTrim {
    NSMutableArray* methodsToCall = [NSMutableArray array];
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(object_getClass(clz), &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        
        NSString* methodName = [NSString stringWithUTF8String:sel_getName(method_getName(method))];
        NSString* descriptorPostfix = [NSStringFromClass(self) substringFromIndex:prefixToTrim.length];
        
        if ([[methodName lowercaseString] hasSuffix:[descriptorPostfix lowercaseString]]) {
            [methodsToCall addObject: methodName];
        }
    }
    
    free(methods);
    
    return methodsToCall;


}

NSArray *ClassGetSubclasses(Class parentClass)
{
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < numClasses; i++)
    {
        Class superClass = classes[i];
        do
        {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != parentClass);
        
        if (superClass == nil)
        {
            continue;
        }
        
        [result addObject:classes[i]];
    }
    
    free(classes);
    
    return result;
}

@end
