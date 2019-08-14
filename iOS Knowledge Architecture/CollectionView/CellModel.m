//
//  CellModel.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/13.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "CellModel.h"

@implementation CellModel

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeFloat:self.height forKey:@"height"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        self.height = [aDecoder decodeFloatForKey:@"height"];
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end
