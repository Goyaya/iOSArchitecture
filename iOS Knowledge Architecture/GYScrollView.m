//
//  GYScrollView.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/1.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "GYScrollView.h"

@implementation GYScrollView

- (BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    NSLog(@"💙touchesShouldBegin, self: %p, view: %p", self, view);
//    return ![view isKindOfClass:UIButton.class];
    return self.touchesShouldBegin;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    NSLog(@"💚touchesShouldCancelInContentView, self: %p, view: %p", self, view);
//    return [view isKindOfClass:UIButton.class];
    return self.touchesShouldCancel;
}

@end
