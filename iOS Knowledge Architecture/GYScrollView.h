//
//  GYScrollView.h
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/1.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYScrollView : UIScrollView

@property (nonatomic, readwrite, assign) BOOL touchesShouldBegin;
@property (nonatomic, readwrite, assign) BOOL touchesShouldCancel;

@end

NS_ASSUME_NONNULL_END
