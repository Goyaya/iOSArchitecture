//
//  GYPresentTransitionAnimator.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/4.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "GYPresentTransitionAnimator.h"

@implementation GYPresentTransitionAnimator

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    if (toVC.isBeingPresented) {
        CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
        CGRect initialFrame = finalFrame;
        initialFrame.origin.y = containerView.frame.size.height;
        toView.frame = initialFrame;
        [containerView addSubview:toView];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.frame = finalFrame;
        } completion:^(BOOL finished) {
            BOOL transitionCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!transitionCancelled];
        }];
    } else {
        CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
        CGRect finalFrame = initialFrame;
        finalFrame.origin.y = containerView.frame.size.height;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.frame = finalFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

@end
