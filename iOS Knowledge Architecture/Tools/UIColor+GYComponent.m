//
//  UIColor+GYComponent.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/3.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "UIColor+GYComponent.h"

@implementation UIColor (GYComponent)

+ (UIColor *)randomColor {
    NSInteger red = arc4random() % 255;
    NSInteger green = arc4random() % 255;
    NSInteger blue = arc4random() % 255;
    UIColor *randColor = [UIColor colorWithRed: red /255.0f
                                         green:green / 255.0f
                                          blue:blue / 255.0f
                                         alpha:1.0f];
    return randColor;
}

@end
