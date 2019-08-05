//
//  GYNavigateTransitionAnimator.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/4.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "GYNavigateTransitionAnimator.h"

@implementation GYNavigateTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIView *containerView = [transitionContext containerView];
    // fromView和toView在push和pop过程中相反
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:[self transitionDuration:transitionContext]
                       options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished)
    {
        [transitionContext completeTransition:finished];
    }];
}

@end
