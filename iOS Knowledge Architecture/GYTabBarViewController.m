//
//  GYTabBarViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/6.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "GYTabBarViewController.h"
#import "GYSlideTransitionAnimator.h"

@interface GYTabBarViewController () <UITabBarControllerDelegate>

@end

@implementation GYTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}


- (nullable id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
                     animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                                       toViewController:(UIViewController *)toVC {
    NSInteger fromIndex = [self.viewControllers indexOfObject:fromVC];
    NSInteger toIndex = [self.viewControllers indexOfObject:toVC];
    if (fromIndex < toIndex) {
        return [[GYSlideTransitionAnimator alloc] initWithDirection:GYSlideTransitionAnimatorDirectionFromRight];
    }
    
    return [[GYSlideTransitionAnimator alloc] initWithDirection:GYSlideTransitionAnimatorDirectionFromLeft];;
}

@end
