//
//  GYCollectionViewDivisionLayout.h
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/13.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GYCollectionViewDivisionLayout;

@protocol GYCollectionViewDivisionLayoutDataSource <UICollectionViewDataSource>

@optional

/// 每个section的等分行数（水平滚动）或列数（垂直滚动）。默认 2
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfColumnsInSection:(NSInteger)section;

@end

@protocol GYCollectionViewDivisionLayoutDelegate <UICollectionViewDelegateFlowLayout>

/**
 根据给定宽度（垂直滚动）参考值获取高度；或根据给定高度（水平滚动）参考值获取宽度；
 
 @param collectionView collectionView
 @param collectionViewLayout layout
 @param refer 参考值
 @param indexPath indexPath
 @return 高度或宽度
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(GYCollectionViewDivisionLayout *)collectionViewLayout valueReferTo:(CGFloat)refer atIndexPath:(NSIndexPath *)indexPath;

@optional

/// 和滚动方向垂直cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(GYCollectionViewDivisionLayout *)collectionViewLayout fixedLineSpacingForSectionAtIndex:(NSInteger)section;

/// 和滚动方向平行cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(GYCollectionViewDivisionLayout *)collectionViewLayout fixedInteritemSpacingForSectionAtIndex:(NSInteger)section;

@end

/**
 一个等分宽度或高度的layout，类似瀑布流。
 * 支持垂直滚动和水平滚动。
 * 支持header和footer视图
 */
@interface GYCollectionViewDivisionLayout : UICollectionViewFlowLayout

/// 列数或行数。默认2
@property (nonatomic, readwrite, assign) NSInteger columns;

/// 两行之间的间距。默认10
@property (nonatomic, readwrite, assign) CGFloat fixedLineSpacing;
/// 两列之间的间距。默认10
@property (nonatomic, readwrite, assign) CGFloat fixedInteritemSpacing;

- (instancetype)initWithColumns:(NSInteger)columns
               fixedLineSpacing:(CGFloat)fixedLineSpacing
          fixedInteritemSpacing:(CGFloat)fixedInteritemSpacing;

@end

NS_ASSUME_NONNULL_END
