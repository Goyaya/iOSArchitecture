//
//  GYPageViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/7/29.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "GYPageViewController.h"

typedef struct {
    unsigned int mayChangeIndexTo: 1;
    unsigned int willChangeIndexTo: 1;
    unsigned int didChangeIndexTo: 1;
} GYPageViewControllerDeleteCapabilities;

@interface _GYPageViewControllerScrollView : UIScrollView @end

@interface _GYPageViewControllerDataSource : NSObject <GYPageViewControllerDataSource>

@property (nonatomic, readwrite, copy) NSArray<UIViewController *> *array;
- (instancetype)initWithArray:(NSArray<UIViewController *> *)array;
/// index
@property (nonatomic, readwrite, assign) NSInteger index;

@end

@interface GYPageViewControllerTransitionContext : NSObject
/// 起始索引
@property (nonatomic, readwrite, assign) NSInteger fromIndex;
/// 确切的目标索引
@property (nonatomic, readwrite, assign) NSInteger toIndex;
/// 可能的目标索引
@property (nonatomic, readwrite, assign) NSInteger predictIndex;
/// 拖动过程中最新的偏移量
@property (nonatomic, readwrite, assign) CGPoint latestOffset;
@end

@interface GYPageViewController () <
UIScrollViewDelegate
, GYPageViewControllerAppearance
>

/// inner scrollview
@property (nonatomic, readwrite, strong) _GYPageViewControllerScrollView *innerScrollView;
/// innerDataSource
@property (nonatomic, readwrite, strong) id<GYPageViewControllerDataSource> innerDataSource;
/// current display index
@property (nonatomic, readwrite, assign) NSInteger index;
/// transitionContext
@property (nonatomic, readwrite, strong) GYPageViewControllerTransitionContext *transitionContext;
/// delegate capability
@property (nonatomic, readwrite, assign) GYPageViewControllerDeleteCapabilities delegateCapabilities;
@end

@implementation GYPageViewController

- (instancetype)initWithControllers:(NSArray<UIViewController *> *)controllers index:(NSInteger)index {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _controllers = [controllers copy];
        _GYPageViewControllerDataSource *dataSource = [[_GYPageViewControllerDataSource alloc] initWithArray:controllers];
        dataSource.index = index;
        _innerDataSource = dataSource;
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
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.innerScrollView];
    self.innerScrollView.frame = self.view.bounds;
    self.innerScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self updateScrollViewContentSize];
    [self setIndex:[self indexOfFirstDisplayInPageViewController] animation:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateScrollViewContentSize];
}

- (void)viewWillTransitionToSize:(CGSize)targetSize withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:targetSize withTransitionCoordinator:coordinator];
    
    NSInteger itemCount = [self numberOfItemsInPageViewController];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self handleScrollDirectionWhenHorizontal:^{
            // contentSize
            self.innerScrollView.contentSize = CGSizeMake(targetSize.width * itemCount, 0);
            // childControllers' view frame
            for (NSInteger i = 0; i < itemCount; ++i) {
                UIViewController *controller = [self controllerAtIndexNoCheck:i];
                // 已经加入子控制器
                if (controller.parentViewController == self) {
                    CGSize size = controller.preferredContentSize;
                    if (CGSizeEqualToSize(CGSizeZero, size)) {
                        size = targetSize;
                    }
                    controller.view.frame = CGRectMake(i * targetSize.width + (targetSize.width - size.width) / 2, (targetSize.height - size.height) / 2, size.width, size.height);
                }
            }
            // offset
            self.innerScrollView.contentOffset = CGPointMake(self.index * targetSize.width, 0);
        } whenVertical:^{
            // contentSize
            self.innerScrollView.contentSize = CGSizeMake(0, targetSize.height * itemCount);
            // childControllers' view frame
            for (NSInteger i = 0; i < itemCount; ++i) {
                UIViewController *controller = [self controllerAtIndexNoCheck:i];
                if (controller.parentViewController == self) {
                    CGSize size = controller.preferredContentSize;
                    if (CGSizeEqualToSize(CGSizeZero, size)) {
                        size = targetSize;
                    }
                    controller.view.frame = CGRectMake((targetSize.width - size.width) / 2, i * targetSize.height + (targetSize.height - size.height) / 2, size.width, size.height);
                }
            }
            // offset
            self.innerScrollView.contentOffset = CGPointMake(0, self.index * targetSize.height);
        }];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

- (void)dealloc {
    
}

#pragma mark - public

- (void)setIndex:(NSInteger)index animation:(BOOL)animation {
    NSInteger itemCount = [self numberOfItemsInPageViewController];
    NSParameterAssert(index < itemCount && index > -1);
    _index = index;
    // offset
    [self handleScrollDirectionWhenHorizontal:^{
        [self.innerScrollView setContentOffset:CGPointMake(self.innerScrollView.bounds.size.width * index, 0) animated:animation];
    } whenVertical:^{
        [self.innerScrollView setContentOffset:CGPointMake(0, self.innerScrollView.bounds.size.height * index) animated:animation];
    }];
    // controller
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadViewControllerAtIndex:index];
    });
}

- (void)setDelegate:(id<GYPageViewControllerDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        _delegateCapabilities = (GYPageViewControllerDeleteCapabilities){};
        _delegateCapabilities.mayChangeIndexTo = [_delegate respondsToSelector:@selector(pageViewController:mayChangeIndexTo:progress:)];
        _delegateCapabilities.willChangeIndexTo = [_delegate respondsToSelector:@selector(pageViewController:willChangeIndexTo:)];
        _delegateCapabilities.didChangeIndexTo = [_delegate respondsToSelector:@selector(pageViewController:didChangeIndexTo:)];
    }
}

#pragma mark -

- (void)handleScrollDirectionWhenHorizontal:(void (^_Nonnull)(void))whenHorizontal
                               whenVertical:(void (^_Nonnull)(void))whenVertical {
    GYPageViewControllerScrollDirection direction = [self scrollDirectionInPageViewController];
    switch (direction) {
        case GYPageViewControllerScrollDirectionHorizontal: {
            whenHorizontal();
            break;
        }
        case GYPageViewControllerScrollDirectionVertical: {
            whenVertical();
            break;
        }
    }
}

- (void)updateScrollViewContentSize {
    NSInteger itemCount = [self numberOfItemsInPageViewController];
    [self handleScrollDirectionWhenHorizontal:^{
        self.innerScrollView.contentSize = CGSizeMake(self.innerScrollView.bounds.size.width * itemCount, 0);
    } whenVertical:^{
        self.innerScrollView.contentSize = CGSizeMake(0, self.innerScrollView.bounds.size.height * itemCount);
    }];
}

- (void)loadViewControllerAtIndex:(NSInteger)index {
    UIViewController *controller = [self controllerAtIndexNoCheck:index];
    // 已经加入直接返回
    if (controller.parentViewController == self) {
        return;
    }
    
    if (controller.parentViewController != nil) {
        [controller willMoveToParentViewController:nil];
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
    }
    
    CGSize size = controller.preferredContentSize;
    if (CGSizeEqualToSize(CGSizeZero, size)) {
        size = self.view.bounds.size;
    }
    [self addChildViewController:controller];
    [self handleScrollDirectionWhenHorizontal:^{
        controller.view.frame = CGRectMake(self.innerScrollView.bounds.size.width * index + (self.innerScrollView.bounds.size.width - size.width) / 2, (self.innerScrollView.bounds.size.height - size.height) / 2, size.width, size.height);
    } whenVertical:^{
        controller.view.frame = CGRectMake((self.innerScrollView.bounds.size.width - size.width) / 2, self.innerScrollView.bounds.size.height * index, size.width, size.height);
    }];
    [self.innerScrollView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

#pragma mark -

- (NSInteger)numberOfItemsInPageViewController {
    if (_dataSource) {
        return [_dataSource numberOfItemsInPageViewController:self];
    }
    if (_innerDataSource) {
        return [_innerDataSource numberOfItemsInPageViewController:self];
    }
    return 0;
}

- (NSInteger)indexOfFirstDisplayInPageViewController {
    if (_dataSource) {
        return [_dataSource indexOfFirstDisplayInPageViewController:self];
    }
    if (_innerDataSource) {
        return [_innerDataSource indexOfFirstDisplayInPageViewController:self];
    }
    return 0;
}

- (UIViewController *)controllerAtIndexNoCheck:(NSInteger)index {
    UIViewController *controller = nil;
    if (_dataSource) {
        controller = [_dataSource pageViewController:self controllerAtIndex:index];
    }
    if (_innerDataSource) {
        controller = [_innerDataSource pageViewController:self controllerAtIndex:index];
    }
    NSAssert(controller, @"must have a view controller");
    return controller;
}

- (GYPageViewControllerScrollDirection)scrollDirectionInPageViewController {
    if (_dataSource && [_dataSource respondsToSelector:@selector(scrollDirectionInPageViewController:)]) {
        return [_dataSource scrollDirectionInPageViewController:self];
    }
    if (_innerDataSource) {
        return [_innerDataSource scrollDirectionInPageViewController:self];
    }
    return GYPageViewControllerScrollDirectionHorizontal;
}

- (void)notifyDelegateMayChangeIndexTo:(NSInteger)index progress:(float)progress {
    if (_delegateCapabilities.mayChangeIndexTo) {
        [_delegate pageViewController:self mayChangeIndexTo:index progress:progress];
    }
}

- (void)notifyDelegateWillChangeIndexTo:(NSInteger)index {
    if (_delegateCapabilities.willChangeIndexTo) {
        [_delegate pageViewController:self willChangeIndexTo:index];
    }
}

- (void)notifyDelegateDidChangeIndexTo:(NSInteger)index {
    if (_delegateCapabilities.didChangeIndexTo) {
        [_delegate pageViewController:self didChangeIndexTo:index];
    }
}

#pragma mark -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.transitionContext == nil) {
        self.transitionContext = [GYPageViewControllerTransitionContext new];
        self.transitionContext.fromIndex = self.index;
        self.transitionContext.toIndex = NSNotFound;
        self.transitionContext.predictIndex = NSNotFound;
        self.transitionContext.latestOffset = scrollView.contentOffset;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 更新预测的索引
    CGPoint predictPoint = CGPointMake(scrollView.contentOffset.x - self.transitionContext.latestOffset.x,
                                       scrollView.contentOffset.y - self.transitionContext.latestOffset.y);
    float __block progress = 0;
    [self handleScrollDirectionWhenHorizontal:^{
        if (predictPoint.x > 0) {
            self.transitionContext.predictIndex = self.transitionContext.fromIndex + 1;
            progress = scrollView.contentOffset.x / (self.transitionContext.predictIndex * scrollView.bounds.size.width);
        } else {
            self.transitionContext.predictIndex = self.transitionContext.fromIndex - 1;
            progress = scrollView.contentOffset.x / (self.transitionContext.predictIndex * scrollView.bounds.size.width) - 1.0;
        }
    } whenVertical:^{
        if (predictPoint.y > 0) {
            self.transitionContext.predictIndex = self.transitionContext.fromIndex + 1;
            progress = scrollView.contentOffset.y / (self.transitionContext.predictIndex * scrollView.bounds.size.height);
        } else {
            self.transitionContext.predictIndex = self.transitionContext.fromIndex - 1;
            progress = scrollView.contentOffset.y / (self.transitionContext.predictIndex * scrollView.bounds.size.height) - 1.0;
        }
    }];
    [self notifyDelegateMayChangeIndexTo:self.transitionContext.predictIndex progress:progress];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    // 更新确切目标索引
    CGPoint contentOffset = *targetContentOffset;
    [self handleScrollDirectionWhenHorizontal:^{
        self.transitionContext.toIndex = (NSInteger)(contentOffset.x / scrollView.bounds.size.width);
    } whenVertical:^{
        self.transitionContext.toIndex = (NSInteger)(contentOffset.y / scrollView.bounds.size.height);
    }];
    if (self.transitionContext.fromIndex != self.transitionContext.toIndex) {
        [self notifyDelegateWillChangeIndexTo:self.transitionContext.toIndex];
        [self loadViewControllerAtIndex:self.transitionContext.toIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.index = self.transitionContext.toIndex;
    if (_transitionContext.fromIndex != self.transitionContext.toIndex) {
        [self notifyDelegateDidChangeIndexTo:self.transitionContext.toIndex];
    }
    self.transitionContext = nil;
}


#pragma mark - appearance

- (void)setShowsVerticalScrollIndicator:(BOOL)ifNeeds {
    self.innerScrollView.showsVerticalScrollIndicator = ifNeeds;
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)ifNeeds {
    self.innerScrollView.showsHorizontalScrollIndicator = ifNeeds;
}

#pragma mark -

- (_GYPageViewControllerScrollView *)innerScrollView {
    if (_innerScrollView == nil) {
        _innerScrollView = [[_GYPageViewControllerScrollView alloc] init];
        _innerScrollView.pagingEnabled = YES;
        _innerScrollView.showsVerticalScrollIndicator = NO;
        _innerScrollView.showsHorizontalScrollIndicator = NO;
        _innerScrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _innerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
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

- (GYPageViewControllerScrollDirection)scrollDirectionInPageViewController:(GYPageViewController *)pageViewController {
    return GYPageViewControllerScrollDirectionHorizontal;
}

- (NSInteger)indexOfFirstDisplayInPageViewController:(nonnull GYPageViewController *)pageViewController {
    return _index;
}

@end

@implementation GYPageViewControllerTransitionContext

- (instancetype)init {
    self = [super init];
    if (self) {
        _fromIndex = NSNotFound;
        _toIndex = NSNotFound;
    }
    return self;
}

@end
