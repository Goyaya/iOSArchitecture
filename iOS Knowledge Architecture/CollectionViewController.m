//
//  CollectionViewController.m
//  iOS Knowledge Architecture
//
//  Created by 高洋 on 2019/8/11.
//  Copyright © 2019 Gaoyang. All rights reserved.
//

#import "CollectionViewController.h"
#import <LXReorderableCollectionViewFlowLayout.h>
#import "CollectionViewCell.h"
#import "CollectionReusableView.h"

#import "SectionModel.h"
#import "CellModel.h"

@interface CollectionViewController () <
UICollectionViewDataSource
, UICollectionViewDelegate
, UICollectionViewDelegateFlowLayout
>

@property (nonatomic, readwrite, strong) UICollectionView *collectionView;
/// dataSource
@property (nonatomic, readwrite, strong) NSMutableArray<SectionModel *> *dataSource;
/// sectionTitle
@property (nonatomic, readwrite, strong) NSMutableArray<NSString *> *sectionTitles;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = self.view.bounds;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    [self installMoveGesture];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int sections = 5;
        int cellsInSection = 20;
        for (int i = 0; i < sections; ++i) {
            SectionModel *sectionModel = [[SectionModel alloc] init];
            sectionModel.headerTitle = [NSString stringWithFormat:@"header - %d", i];
            sectionModel.footerTitle = [NSString stringWithFormat:@"footer - %d", i];
            [self.sectionTitles addObject:[NSString stringWithFormat:@"%d",i]];
            for (int j = 0; j < cellsInSection; ++j) {
                CellModel *model = [[CellModel alloc] init];
                model.width = arc4random() % 120 + 50;
                model.height = arc4random() % 100 + 50;
                model.title = [NSString stringWithFormat:@"cell - (%d, %d)", i, j];
                [sectionModel.cells addObject:model];
            }
            [self.dataSource addObject:sectionModel];
        }
        
        SectionModel *sectionModel = [[SectionModel alloc] init];
        sectionModel.headerTitle = @"Empty section header";
        sectionModel.footerTitle = @"Empty section footer";
        [self.dataSource addObject:sectionModel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake(100, 50);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [_collectionView registerClass:[CollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:UICollectionElementKindSectionHeader];
        [_collectionView registerClass:[CollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:UICollectionElementKindSectionFooter];
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (NSMutableArray<SectionModel *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray<NSString *> *)sectionTitles {
    if (!_sectionTitles) {
        _sectionTitles = [NSMutableArray array];
    }
    return _sectionTitles;
}

#pragma mark -

- (void)installMoveGesture {
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHander:)];
    [self.collectionView addGestureRecognizer:gesture];
}

- (void)longPressGestureHander:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.collectionView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
            if (indexPath == nil) {
                return;
            }
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self.collectionView updateInteractiveMovementTargetPosition:location];
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            [self.collectionView endInteractiveMovement];
            break;
        }
            
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    CellModel * sourceModel = [self.dataSource[fromIndexPath.section].cells objectAtIndex:fromIndexPath.row];
    [self.dataSource[fromIndexPath.section].cells removeObject:sourceModel];
    [self.dataSource[toIndexPath.section].cells insertObject:sourceModel atIndex:toIndexPath.row];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"\n%s - %ld\n", __func__, section);
    return self.dataSource[section].cells.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    CellModel *model = self.dataSource[indexPath.section].cells[indexPath.row];
    cell.label.text = model.title;
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"\n%s", __func__);
    return self.dataSource.count;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    CollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kind forIndexPath:indexPath];
    SectionModel *model = self.dataSource[indexPath.section];
    if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
        view.label.text = model.headerTitle;
    } else if ([UICollectionElementKindSectionFooter isEqualToString:kind]) {
        view.label.text = model.footerTitle;
    }
    return view;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    return indexPath.row % 2 == 0;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, destinationIndexPath.section, destinationIndexPath.row);
//    if (sourceIndexPath.section == destinationIndexPath.section && sourceIndexPath.row == destinationIndexPath.row) {
//        return;
//    }
//
//    if (sourceIndexPath.section == destinationIndexPath.section) {
//        [self.dataSource[sourceIndexPath.section].cells exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
//    } else {
//        CellModel *sourceModel = self.dataSource[sourceIndexPath.section].cells[sourceIndexPath.row];
//
//        // 从之前组删除
//        [self.dataSource[sourceIndexPath.section].cells removeObject:sourceModel];
//        // 插入新的组
//        [self.dataSource[destinationIndexPath.section].cells insertObject:sourceModel atIndex:destinationIndexPath.row];
//    }
}

/// Returns a list of index titles to display in the index view (e.g. ["A", "B", "C" ... "Z", "#"])
- (nullable NSArray<NSString *> *)indexTitlesForCollectionView:(UICollectionView *)collectionView API_AVAILABLE(tvos(10.2)) {
    NSLog(@"\n%s", __func__);
    return self.sectionTitles;
}

/// Returns the index path that corresponds to the given title / index. (e.g. "B",1)
/// Return an index path with a single index to indicate an entire section, instead of a specific item.
- (NSIndexPath *)collectionView:(UICollectionView *)collectionView indexPathForIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSLog(@"\n%s - %ld", __func__, index);
    return [NSIndexPath indexPathForItem:0 inSection:index];
}

#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    CellModel *model = self.dataSource[indexPath.section].cells[indexPath.row];
    return CGSizeMake(model.width, model.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSLog(@"\n%s - %ld\n", __func__, section);
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"\n%s - %ld\n", __func__, section);
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"\n%s - %ld\n", __func__, section);
    return 10;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    NSLog(@"\n%s - %ld\n", __func__, section);
    return CGSizeMake(50, 50);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    NSLog(@"\n%s - %ld\n", __func__, section);
    return CGSizeMake(50, 50);
}

#pragma mark - UICollectionViewDelegate

// Methods for notification of selection/deselection and highlight/unhighlight events.
// The sequence of calls leading to selection from a user touch is:
//
// (when the touch begins)
// 1. -collectionView:shouldHighlightItemAtIndexPath:
// 2. -collectionView:didHighlightItemAtIndexPath:
//
// (when the touch lifts)
// 3. -collectionView:shouldSelectItemAtIndexPath: or -collectionView:shouldDeselectItemAtIndexPath:
// 4. -collectionView:didSelectItemAtIndexPath: or -collectionView:didDeselectItemAtIndexPath:
// 5. -collectionView:didUnhighlightItemAtIndexPath:
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.25 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.3, 1.3);
    }];
    
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.25 animations:^{
        cell.transform = CGAffineTransformIdentity;
    }];
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    return YES;
}
// called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    
}

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    return indexPath.row % 2 != 0;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    
}

// support for custom transition layout
- (nonnull UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                                transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout
                                                   newLayout:(UICollectionViewLayout *)toLayout {
    NSLog(@"\n%s", __func__);
    return [[UICollectionViewTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
}

// Focus NS_AVAILABLE_IOS(9_0)
- (BOOL)collectionView:(UICollectionView *)collectionView canFocusItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.row);
    return YES;
}
// NS_AVAILABLE_IOS(9_0)
- (BOOL)collectionView:(UICollectionView *)collectionView shouldUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context {
    NSLog(@"\n%s", __func__);
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    NSLog(@"\n%s", __func__);
    
}
// NS_AVAILABLE_IOS(9_0)
- (nullable NSIndexPath *)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"\n%s", __func__);
    return nil;
}

// NS_AVAILABLE_IOS(9_0)
- (NSIndexPath *)collectionView:(UICollectionView *)collectionView targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)originalIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath  {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, proposedIndexPath.section, proposedIndexPath.row);
    return proposedIndexPath;
}
// NS_AVAILABLE_IOS(9_0); // customize the content offset to be applied during transition or update animations
- (CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    NSLog(@"\n%s", __func__);
    return proposedContentOffset;
}

// Spring Loading

/* Allows opting-out of spring loading for an particular item.
 *
 * If you want the interaction effect on a different subview of the spring loaded cell, modify the context.targetView property.
 * The default is the cell.
 *
 * If this method is not implemented, the default is YES.
 * API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos, watchos)
 */
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSpringLoadItemAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context  API_AVAILABLE(ios(11.0)) {
    NSLog(@"\n%s", __func__);
    return YES;
}

@end
