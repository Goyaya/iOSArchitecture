//
//  ScrollViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/7/30.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "ScrollViewController.h"
#import <NSObject+FBKVOController.h>

@interface ScrollViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.scrollView.contentInset = UIEdgeInsetsMake(100, 100, 0, 0);
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
//        self.scrollView.safeAreaInsets
    }
    
    [self.KVOControllerNonRetaining observe:self.scrollView keyPath:@"contentOffset" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        if (@available(iOS 11.0, *)) {
            NSLog(@"%@ : %@ ~ %@", change[FBKVONotificationKeyPathKey], change[NSKeyValueChangeNewKey], NSStringFromUIEdgeInsets(self.scrollView.adjustedContentInset));
        } else {
            NSLog(@"%@ : %@", change[FBKVONotificationKeyPathKey], change[NSKeyValueChangeNewKey]);
        }
    }];
    
    [self.KVOControllerNonRetaining observe:self.scrollView keyPath:@"adjustedContentInset" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSLog(@"%@ : %@", change[FBKVONotificationKeyPathKey], change[NSKeyValueChangeNewKey]);
        
    }];
    
    [self.KVOControllerNonRetaining observe:self.scrollView keyPath:@"safeAreaInsets" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSLog(@"%@ : %@", change[FBKVONotificationKeyPathKey], change[NSKeyValueChangeNewKey]);
        
    }];
}

#pragma mark - scrolling
// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
}   // called on finger up as we are moving

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
}     // called when scroll view grinds to a halt


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
} // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating


#pragma mark - dragging
// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"%s", __func__);
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"%s", __func__);
}

#pragma mark - zooming
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
    return self.imageView;
}     // return a view that will be scaled. if delegate returns nil, nothing happens

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    
    NSLog(@"%s", __func__);
} // called before the scroll view begins zooming its content

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    
    NSLog(@"%s", __func__);
}// scale between minimum and maximum. called after any 'bounce' animations

#pragma mark - top touch
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
    return YES;
}   // return a yes if you want to scroll to the top. if not defined, assumes YES

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
    
}      // called when scrolling animation finished. may be called immediately if already at top

#pragma mark - adjustedContentInset
/* Also see -[UIScrollView adjustedContentInsetDidChange]
 */
- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView {
    
    NSLog(@"%s", __func__);
}

@end
