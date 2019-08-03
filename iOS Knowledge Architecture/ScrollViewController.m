//
//  ScrollViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/7/30.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "ScrollViewController.h"
#import <NSObject+FBKVOController.h>
#import "GYScrollView.h"

@interface ScrollViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet GYScrollView *customScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *shouldBeginSwitch;

@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customScrollView.touchesShouldBegin = YES;
    self.customScrollView.touchesShouldCancel = YES;
    
    self.customScrollView.delegate = self;
    self.scrollView.delegate = self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
}
- (IBAction)openShouldBegin:(id)sender {
    self.shouldBeginSwitch.on = YES;
    [self shouldBeginChanged:self.shouldBeginSwitch];
}

- (IBAction)changeCustomScrollViewDelaysContentTouches:(UISwitch *)sender {
    self.customScrollView.delaysContentTouches = sender.isOn;
}

- (IBAction)changeCustomScrollViewCanCancelContentTouches:(UISwitch *)sender {
    self.customScrollView.canCancelContentTouches = sender.isOn;
}

- (IBAction)shouldBeginChanged:(UISwitch *)sender {
    self.customScrollView.touchesShouldBegin = sender.isOn;
}

- (IBAction)shouldCancelChanged:(UISwitch *)sender {
    self.customScrollView.touchesShouldCancel = sender.isOn;
}


- (IBAction)changeScrollViewDelaysContentTouches:(UISwitch *)sender {
    self.scrollView.delaysContentTouches = sender.isOn;
}

- (IBAction)changeScrollViewCanCancelContentTouches:(UISwitch *)sender {
    self.scrollView.canCancelContentTouches = sender.isOn;
}

@end
