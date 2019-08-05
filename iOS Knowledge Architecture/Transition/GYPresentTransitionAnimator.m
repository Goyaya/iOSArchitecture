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
        UIView *dimmingView = [[UIView alloc] init];
        dimmingView.backgroundColor = [UIColor clearColor];
        dimmingView.tag = 1;
        
        dimmingView.frame = containerView.bounds;
        [containerView addSubview:dimmingView];
        
        CGSize size = CGSizeMake(containerView.frame.size.width / 3 * 2, containerView.frame.size.height / 3 * 2);
        toView.center = CGPointMake(containerView.frame.size.width / 2, containerView.frame.size.height / 2);
        toView.bounds = CGRectMake(0, 0, 0, size.height);
        [containerView addSubview:toView];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            dimmingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            toView.bounds = CGRectMake(0, 0, size.width, size.height);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    } else {
        
        UIView *dimmingView = [containerView viewWithTag:1];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            dimmingView.backgroundColor = [UIColor clearColor];
            fromView.bounds = CGRectMake(0, 0, 0, fromView.bounds.size.height);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

@end
