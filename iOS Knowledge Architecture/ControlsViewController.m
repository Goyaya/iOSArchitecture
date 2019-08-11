//
//  ControlsViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/11.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "ControlsViewController.h"

@interface ControlsViewController ()

@property (strong, nonatomic) IBOutletCollection(UIControl) NSArray<UIControl *> *controls;


@end

@implementation ControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // UIControl 在添加 target-action 时，没有target时，会查找响应者链
    [self.controls enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addTarget:nil action:@selector(someControlTouchUpinside:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
