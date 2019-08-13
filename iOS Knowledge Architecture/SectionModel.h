//
//  SectionModel.h
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/13.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CellModel;

@interface SectionModel : NSObject

/// header
@property (nonatomic, readwrite, copy) NSString *headerTitle;
/// footer
@property (nonatomic, readwrite, copy) NSString *footerTitle;
/// items
@property (nonatomic, readwrite, copy) NSMutableArray<CellModel *> *cells;

@end

NS_ASSUME_NONNULL_END
