//
//  GYPageViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/7/29.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "GYPageViewController.h"

@interface _GYPageViewControllerScrollView : UIScrollView

@end

@interface _GYPageViewControllerDataSource : NSObject <GYPageViewControllerDataSource>

@property (nonatomic, readwrite, copy) NSArray<UIViewController *> *array;
- (instancetype)initWithArray:(NSArray<UIViewController *> *)array;

@end

@interface GYPageViewController ()

/// inner scrollview
@property (nonatomic, readwrite, strong) _GYPageViewControllerScrollView *innerScrollView;
/// innerDataSource
@property (nonatomic, readwrite, strong) id<GYPageViewControllerDataSource> innerDataSource;

@end

@implementation GYPageViewController

- (instancetype)initWithControllers:(NSArray<UIViewController *> *)controllers {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _controllers = [controllers copy];
    }
    return self;
}

- (instancetype)initWithDataSource:(id<GYPageViewControllerDataSource>)dataSource {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _dataSource = dataSource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.innerScrollView];
    self.innerScrollView.frame = self.view.bounds;
    self.innerScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
}

#pragma mark - method forward

/// 做DataSource的方法转发
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (_dataSource) {
        return nil;
    }
    return self.innerDataSource;
}

#pragma mark -

- (_GYPageViewControllerScrollView *)innerScrollView {
    if (_innerScrollView == nil) {
        _innerScrollView = [[_GYPageViewControllerScrollView alloc] init];
    }
    return _innerScrollView;
}

- (id<GYPageViewControllerDataSource>)innerDataSource {
    if (_innerDataSource == nil) {
        _innerDataSource = [[_GYPageViewControllerDataSource alloc] initWithArray:_controllers];
    }
    return _innerDataSource;
}

@end

@implementation _GYPageViewControllerScrollView
@end

@implementation _GYPageViewControllerDataSource

- (instancetype)initWithArray:(NSArray<UIViewController *> *)array {
    self = [super init];
    if (self) {
        _array = [array copy];
    }
    return self;
}

- (NSInteger)numberOfItemsInPageViewController:(nonnull GYPageViewController *)pageViewController {
    return _array.count;
}

- (nonnull UIViewController *)pageViewController:(nonnull GYPageViewController *)controller controllerAtIndex:(NSInteger)index {
    return _array[index];
}

@end
