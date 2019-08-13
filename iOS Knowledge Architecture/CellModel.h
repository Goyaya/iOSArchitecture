//
//  CellModel.h
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/13.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellModel : NSObject

/// size
@property (nonatomic, readwrite, assign) float width;
@property (nonatomic, readwrite, assign) float height;

/// title
@property (nonatomic, readwrite, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
