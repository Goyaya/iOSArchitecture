//
//  CollectionViewCell.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/11.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "CollectionViewCell.h"
#import "UIColor+GYComponent.h"

@implementation CollectionViewCell

@synthesize label = _label;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.contentView addSubview:self.label];
        self.contentView.backgroundColor = [UIColor randomColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
    }
    return _label;
}

@end
