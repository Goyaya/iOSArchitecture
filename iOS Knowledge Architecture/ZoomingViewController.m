//
//  ZoomingViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/3.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "ZoomingViewController.h"

@interface ZoomingViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *zoomingImageView;

@end

@implementation ZoomingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImageViewWithGesture:)];
    tap.numberOfTapsRequired = 2;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tap];
}

// 手势的selector应该包含对应手势参数
- (void)zoomImageViewWithGesture:(UITapGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale <= self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.zoomingImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    NSLog(@"%s", __func__);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
}

@end
