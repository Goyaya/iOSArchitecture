//
//  GYDetailViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/3.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "GYDetailViewController.h"
#import "UIColor+GYComponent.h"

@interface GYDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;


@end

@implementation GYDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSLog(@"%@ - %s", self,  __func__);
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)viewDidLoad {
    NSLog(@"%@ - %s", self,  __func__);
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.label.backgroundColor = [UIColor randomColor];
    [self.view addSubview:self.label];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    NSLog(@"%s - %@", __func__, parent);//0x7fb1e2ac5c10
}
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%@ - %s", self,  __func__);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%@ - %s", self,  __func__);
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%@ - %s", self,  __func__);
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%@ - %s", self,  __func__);
    [super viewDidDisappear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"%@ - %s", self,  __func__);
}

- (void)dealloc {
    NSLog(@"%@ - %s", self,  __func__);
}
- (IBAction)dismissIfNeeds:(id)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
