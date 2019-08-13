//
//  CollectionReusableView.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/13.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "CollectionReusableView.h"
#import "UIColor+GYComponent.h"

@implementation CollectionReusableView

@synthesize label = _label;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor randomColor];
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
    }
    return _label;
}

@end
