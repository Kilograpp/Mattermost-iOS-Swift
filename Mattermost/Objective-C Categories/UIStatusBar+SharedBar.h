//
// Created by Maxim Gubin on 23/06/16.
// Copyright (c) 2016 Kilograpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIStatusBar : UIView
@end

@interface UIStatusBar (SharedBar)
+ (instancetype)sharedStatusBar;

- (void)attachToDefault;
- (void)attachToView:(UIView*)view;
- (void)reset;

@end
