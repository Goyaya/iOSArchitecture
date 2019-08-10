//
//  GYPresentationController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/5.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "GYPresentationController.h"

@interface GYPresentationController ()

@property (nonatomic, readwrite, strong) UIView *dimmingView;

@end

@implementation GYPresentationController

- (void)presentationTransitionWillBegin {
    [self.containerView insertSubview:self.dimmingView atIndex:0];
    self.dimmingView.alpha = 0;
    self.dimmingView.frame = self.containerView.bounds;
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0.5;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGSize size = CGSizeMake(self.containerView.frame.size.width, self.containerView.frame.size.height * 0.75);
//    return self.containerView
    return CGRectMake((self.containerView.frame.size.width - size.width) / 2, self.containerView.frame.size.height - size.height, size.width, size.height);
}

- (void)containerViewWillLayoutSubviews {
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

//- (BOOL)shouldRemovePresentersView { return YES; }

- (UIView *)dimmingView {
    if (!_dimmingView) {
        _dimmingView = [[UIView alloc] init];
        _dimmingView.backgroundColor = [UIColor blackColor];
    }
    return _dimmingView;
}

@end
