//
//  MasterTableViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/7/29.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "MasterTableViewController.h"
#import "GYPageViewController.h"
#import "GYDetailViewController.h"
#import "GYNavigateTransitionAnimator.h"
#import "GYPresentTransitionAnimator.h"
#import "GYPresentationController.h"
#import "GYTableViewController.h"

#import <objc/message.h>

@interface MasterTableViewController ()
<GYPageViewControllerDataSource, GYPageViewControllerDelegate
, UINavigationControllerDelegate
, UIViewControllerTransitioningDelegate
, UIGestureRecognizerDelegate
>

/// mapper
@property (nonatomic, readwrite, strong) NSDictionary<NSNumber *, NSString *> *selectorMapper;
/// controllers
@property (nonatomic, readwrite, strong) NSArray<UIViewController *> *controllers;
/// interactivePresentPanGesture
@property (nonatomic, readwrite, strong) UIPanGestureRecognizer *interactivePresentPanGesture;

// 交互转场
/// 最新的移动点
@property (nonatomic, readwrite, assign) CGPoint latestPoint;
/// 交互控制器
@property (nonatomic, readwrite, strong) UIPercentDrivenInteractiveTransition *percentDrivenTransition;
/// 累计移动距离
@property (nonatomic, readwrite, assign) CGFloat distance;
/// 需要移动的距离
@property (nonatomic, readwrite, assign) CGFloat totalDistance;

@end

@implementation MasterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.selectorMapper = @{
                            @(0): NSStringFromSelector(@selector(showPageViewControllerWithDataSource)),
                            @(1): NSStringFromSelector(@selector(showPageViewControllerWithMetadata)),
                            @(2): NSStringFromSelector(@selector(showNavigateTransitionDemo)),
                            @(3): NSStringFromSelector(@selector(showPresentTransitionDemo))
                            };
    self.controllers = @[
                         ({
                             GYDetailViewController *cotnroller = [[GYDetailViewController alloc] init];
                             cotnroller.title = @"李白";
                             cotnroller;
                         }),
                         ({
                             GYDetailViewController *cotnroller = [[GYDetailViewController alloc] init];
                             cotnroller.title = @"杜甫";
                             cotnroller;
                         }),
                         ({
                             GYDetailViewController *cotnroller = [[GYDetailViewController alloc] init];
                             cotnroller.title = @"白居易";
                             cotnroller;
                         })
                         ];
    [self installInteractivePresentGesture];
}

- (void)showPageViewControllerWithDataSource {
    GYPageViewController *controller = [[GYPageViewController alloc] initWithDataSource:self];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showPageViewControllerWithMetadata {
    GYPageViewController *controller = [[GYPageViewController alloc] initWithControllers:self.controllers index:self.controllers.count - 1];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [controller setIndex:1 animation:YES complete:^{
            NSLog(@"%s", __func__);
        }];
    });
}

- (void)showNavigateTransitionDemo {
    self.navigationController.delegate = self;
    GYDetailViewController *controller = [[GYDetailViewController alloc] init];
    controller.title = @"transition";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showPresentTransitionDemo {
    GYTableViewController *controller = [[GYTableViewController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationCustom;
    controller.transitioningDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - GYPageViewController DataSource & Delegate

- (NSInteger)numberOfItemsInPageViewController:(GYPageViewController *)pageViewController {
    return self.controllers.count;
}

- (NSInteger)indexOfFirstDisplayInPageViewController:(GYPageViewController *)pageViewController {
    return 0;
}

- (UIViewController *)pageViewController:(GYPageViewController *)controller controllerAtIndex:(NSInteger)index {
    return self.controllers[index];
}

- (GYPageViewControllerScrollDirection)scrollDirectionInPageViewController:(GYPageViewController *)pageViewController {
    return GYPageViewControllerScrollDirectionHorizontal;
}

- (void)pageViewController:(GYPageViewController *)controller mayChangeIndexTo:(NSInteger)index progress:(float)progress {
    NSLog(@"index may change from: %ld to %ld, progress:%.2f", controller.index, index, progress);
}

- (void)pageViewController:(GYPageViewController *)controller willChangeIndexTo:(NSInteger)index {
    NSLog(@"index will change to: %ld", index);
}

- (void)pageViewController:(GYPageViewController *)controller didChangeIndexTo:(NSInteger)index {
    NSLog(@"index did change to: %ld", index);
}

#pragma mark - Navigation Animation

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    return [[GYNavigateTransitionAnimator alloc] init];
}

#pragma mark - Modal Animation

- (void)installInteractivePresentGesture {
//    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(interactivePresentGestureHander:)];
//    gesture.delegate = self;
//    [gesture requireGestureRecognizerToFail:self.tableView.panGestureRecognizer];
//    [self.tableView addGestureRecognizer:gesture];
//    self.interactivePresentPanGesture = gesture;
    [self.tableView.panGestureRecognizer addTarget:self action:@selector(interactivePresentGestureHander:)];
}

- (void)interactivePresentGestureHander:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state) {
        case UIGestureRecognizerStatePossible:  break;
        case UIGestureRecognizerStateBegan: {
            
            _percentDrivenTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            
            self.latestPoint = [panGesture locationInView:self.view];
            self.distance = 0;
            self.totalDistance = self.tableView.frame.size.height / 3 * 2;
            [self showPresentTransitionDemo];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // tableView没有滚动到最底部时，不触发转场进度. 但是在已触发转场后需要
            CGFloat limit = 0;
            if (@available(iOS 11.0, *)) {
                limit = self.tableView.contentSize.height + self.tableView.adjustedContentInset.top - self.tableView.bounds.size.height;
            } else {
                limit = self.tableView.contentSize.height + self.tableView.contentInset.top + self.tableView.contentInset.bottom - self.tableView.bounds.size.height;
            }
            if (self.tableView.contentOffset.y < limit && self.distance <= 0) {
                return;
            }
            
            CGPoint offset = self.tableView.contentOffset;
            offset.y = limit;
            self.tableView.contentOffset = offset;
            
            CGPoint velocity = [panGesture velocityInView:self.view];
            // x方向的分量大于y方向，时不更新
            if (fabs(velocity.x) > fabs(velocity.y)) {
                return;
            }
            
            CGPoint point = [panGesture locationInView:self.view];
            CGPoint movePoint = CGPointMake(point.x - self.latestPoint.x, point.y - self.latestPoint.y);
            self.latestPoint = point;
            self.distance -= movePoint.y;
            CGFloat percent = self.distance / self.totalDistance;
            [self.percentDrivenTransition updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            // 结束时的速度和动画曲线
            CGFloat velocity = fabs([panGesture velocityInView:self.view].y);
            self.percentDrivenTransition.completionCurve = UIViewAnimationCurveEaseOut;
            CGFloat percent = self.distance / self.totalDistance;
            if (percent > 0.5) {
                self.percentDrivenTransition.completionSpeed = velocity / ((1 - percent) * self.totalDistance);
                [self.percentDrivenTransition finishInteractiveTransition];
            } else {
                self.percentDrivenTransition.completionSpeed = velocity /  (percent * self.totalDistance);
                [self.percentDrivenTransition cancelInteractiveTransition];
            }
            _percentDrivenTransition = nil;
            break;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != self.interactivePresentPanGesture) {
        return YES;
    }
    UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint velocity = [gesture velocityInView:gesture.view];
    NSLog(@"%s,\nvelocity: %@", __func__, NSStringFromCGPoint(velocity));
    
    BOOL result = velocity.y < velocity.x && velocity.y < 0 && self.tableView.contentOffset.y + self.tableView.bounds.size.height >= self.tableView.contentSize.height;
    return result;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[GYPresentTransitionAnimator alloc] init];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[GYPresentTransitionAnimator alloc] init];
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.percentDrivenTransition;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[GYPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selString = self.selectorMapper[@(indexPath.row)];
    SEL sel = NSSelectorFromString(selString);
    if ([self respondsToSelector:sel]) {
        ((void (*)(id, SEL))objc_msgSend)(self, sel);
    }
}

@end
