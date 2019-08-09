//
//  GYSlideTransitionAnimator.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/6.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "GYSlideTransitionAnimator.h"

@implementation GYSlideTransitionAnimator

- (instancetype)initWithDirection:(GYSlideTransitionAnimatorDirection)direction {
    self = [super init];
    if (self) {
        _direction = direction;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    toView.bounds = containerView.bounds;
    
    CGRect frame = containerView.frame;
    
    switch (_direction) {
        case GYSlideTransitionAnimatorDirectionFromLeft: {
            toView.center = CGPointMake(-frame.size.width/2, frame.size.height / 2);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                toView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
                fromView.center = CGPointMake(frame.size.width / 2 + frame.size.width, frame.size.height / 2);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:finished];
            }];
            
            break;
        }
        case GYSlideTransitionAnimatorDirectionFromRight: {
            toView.center = CGPointMake(frame.size.width / 2 + frame.size.width, frame.size.height / 2);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                toView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
                fromView.center = CGPointMake(-frame.size.width / 2, frame.size.height / 2);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:finished];
            }];
            
            break;
        }
    }
}


@end

