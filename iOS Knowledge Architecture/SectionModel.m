//
//  SectionModel.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/13.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "SectionModel.h"

@implementation SectionModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cells = [NSMutableArray array];
    }
    return self;
}

@end
