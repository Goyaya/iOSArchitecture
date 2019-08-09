//
//  GYSlideTransitionAnimator.h
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/6.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, GYSlideTransitionAnimatorDirection) {
    GYSlideTransitionAnimatorDirectionFromRight,
    GYSlideTransitionAnimatorDirectionFromLeft
};

@interface GYSlideTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

/// direction
@property (nonatomic, readonly, assign) GYSlideTransitionAnimatorDirection direction;
- (instancetype)initWithDirection:(GYSlideTransitionAnimatorDirection)direction;

@end

NS_ASSUME_NONNULL_END
