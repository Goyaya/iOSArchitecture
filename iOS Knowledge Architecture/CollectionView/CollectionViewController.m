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

#import "GYCollectionViewDivisionLayout.h"

#import "SectionModel.h"
#import "CellModel.h"

#import <Masonry.h>

@interface CollectionViewController () <
UICollectionViewDataSource
, UICollectionViewDelegate
, UICollectionViewDelegateFlowLayout
, UICollectionViewDragDelegate
, UICollectionViewDropDelegate
>

@property (nonatomic, readwrite, strong) UICollectionView *collectionView;
/// dataSource
@property (nonatomic, readwrite, strong) NSMutableArray<SectionModel *> *dataSource;
/// sectionTitle
@property (nonatomic, readwrite, strong) NSMutableArray<NSString *> *sectionTitles;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"切换" style:UIBarButtonItemStylePlain target:self action:@selector(changeCollectionLayout)];
    item.width = 50;
    self.navigationItem.rightBarButtonItem = item;
    
//    [self installMoveGesture];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int sections = 1;
        int cellsInSection = 1;
        for (int i = 0; i < sections; ++i) {
            SectionModel *sectionModel = [[SectionModel alloc] init];
            sectionModel.headerTitle = [NSString stringWithFormat:@"header - %d", i];
            sectionModel.footerTitle = [NSString stringWithFormat:@"footer - %d", i];
            [self.sectionTitles addObject:[NSString stringWithFormat:@"%d",i]];
            for (int j = 0; j < cellsInSection; ++j) {
                CellModel *model = [self cellModelWithTitle:[NSString stringWithFormat:@"cell - (%d, %d)", i, j]];
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

#pragma mark - action

- (void)changeCollectionLayout {
    if ([self.collectionView.collectionViewLayout isMemberOfClass:GYCollectionViewDivisionLayout.class]) {
        [self.collectionView setCollectionViewLayout:[self flowlayout] animated:YES completion:^(BOOL finished) {
            if (finished) {
                NSLog(@"转换完成");
            } else {
                NSLog(@"转换失败");
            }
        }];
    } else {
        [self.collectionView setCollectionViewLayout:[self divisionLayout] animated:YES completion:^(BOOL finished) {
            if (finished) {
                NSLog(@"转换完成");
            } else {
                NSLog(@"转换失败");
            }
        }];
    }
}

#pragma mark -

- (UICollectionViewFlowLayout *)flowlayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.sectionHeadersPinToVisibleBounds = YES;
//    layout.sectionFootersPinToVisibleBounds = YES;
    layout.estimatedItemSize = CGSizeMake(200, 50);
    layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    return layout;
}

- (GYCollectionViewDivisionLayout *)divisionLayout {
    GYCollectionViewDivisionLayout *layout = [[GYCollectionViewDivisionLayout alloc] init];
    layout.scrollDirection = self.direction;
//    layout.sectionHeadersPinToVisibleBounds = YES;
    return layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewLayout *layout = [self divisionLayout];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [_collectionView registerClass:[CollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:UICollectionElementKindSectionHeader];
        [_collectionView registerClass:[CollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:UICollectionElementKindSectionFooter];
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _collectionView.dragDelegate = self;
            _collectionView.dragInteractionEnabled = YES;
            
            _collectionView.dropDelegate = self;
            _collectionView.springLoaded = YES;
            _collectionView.reorderingCadence = UICollectionViewReorderingCadenceImmediate;
        }
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

- (CellModel *)cellModelWithTitle:(NSString *)title {
    CellModel *model = [[CellModel alloc] init];
    model.title = title;
    model.width = arc4random() % 120 + 50;
    model.height = arc4random() % 100 + 50;
    return model;
}

- (IBAction)insertCollectionViewCell {
    CellModel *model = [self cellModelWithTitle:[NSString stringWithFormat:@"inserted %@", [NSDate date]]];
    [self.dataSource.firstObject.cells insertObject:model atIndex:0];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
}

- (IBAction)deleteFirstCell:(UIButton *)sender {
    if (self.dataSource.firstObject.cells.count) {
        [self.dataSource.firstObject.cells removeObjectAtIndex:0];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    }
}

#pragma mark -

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(GYCollectionViewDivisionLayout *)collectionViewLayout valueReferTo:(CGFloat)refer atIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.section].cells[indexPath.item].height;
}

/// The waterfall columns in specify section. Default is 2
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfColumnsInSection:(NSInteger)section {
    return 2;
}

#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    CellModel * sourceModel = [self.dataSource[fromIndexPath.section].cells objectAtIndex:fromIndexPath.item];
    [self.dataSource[fromIndexPath.section].cells removeObject:sourceModel];
    [self.dataSource[toIndexPath.section].cells insertObject:sourceModel atIndex:toIndexPath.item];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"\n%s - %ld\n", __func__, section);
    return self.dataSource[section].cells.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    CellModel *model = self.dataSource[indexPath.section].cells[indexPath.item];
    cell.label.text = model.title;
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"\n%s", __func__);
    return self.dataSource.count;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
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
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, destinationIndexPath.section, destinationIndexPath.item);
//    if (sourceIndexPath.section == destinationIndexPath.section && sourceIndexPath.item == destinationIndexPath.item) {
//        return;
//    }
//
//    if (sourceIndexPath.section == destinationIndexPath.section) {
//        [self.dataSource[sourceIndexPath.section].cells exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
//    } else {
//        CellModel *sourceModel = self.dataSource[sourceIndexPath.section].cells[sourceIndexPath.item];
//
//        // 从之前组删除
//        [self.dataSource[sourceIndexPath.section].cells removeObject:sourceModel];
//        // 插入新的组
//        [self.dataSource[destinationIndexPath.section].cells insertObject:sourceModel atIndex:destinationIndexPath.item];
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
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    CellModel *model = self.dataSource[indexPath.section].cells[indexPath.item];
    return CGSizeMake(model.width, model.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSLog(@"\n%s - %ld\n", __func__, section);
    return UIEdgeInsetsMake(10, 5 * section, 10, 10);
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
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    [UIView animateWithDuration:0.25 animations:^{
//        cell.transform = CGAffineTransformMakeScale(1.3, 1.3);
//    }];
    
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    [UIView animateWithDuration:0.25 animations:^{
//        cell.transform = CGAffineTransformIdentity;
//    }];
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    return YES;
}
// called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    
}

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
    
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
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, indexPath.section, indexPath.item);
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
    NSLog(@"\n%s - (%ld, %ld)\n", __func__, proposedIndexPath.section, proposedIndexPath.item);
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

#pragma mark - drag

- (UIDragItem *)dragItemAatIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)) {
    if (indexPath.section < self.dataSource.count && indexPath.item < self.dataSource[indexPath.section].cells.count) {
        CellModel *model = self.dataSource[indexPath.section].cells[indexPath.item];
        NSItemProvider *provider = [[NSItemProvider alloc] initWithItem:model typeIdentifier:@"MODEL"];
        UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:provider];
        /// 提供文件类型
//        [[NSItemProvider alloc] registerFileRepresentationForTypeIdentifier:@"" fileOptions:NSItemProviderFileOptionOpenInPlace visibility:NSItemProviderRepresentationVisibilityAll loadHandler:^NSProgress * _Nullable(void (^ _Nonnull completionHandler)(NSURL * _Nullable, BOOL, NSError * _Nullable)) {
//            completionHandler(nil, YES, nil);
//            return [NSProgress currentProgress];
//        }];
        // 只能在本APP内部交换的数据
        dragItem.localObject = model;
        return dragItem;
    }
    return nil;
}

/* Provide items to begin a drag associated with a given indexPath.
 * If an empty array is returned a drag session will not begin.
 */
- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)) {
    NSLog(@"\n%s", __func__);
    UIDragItem *item = [self dragItemAatIndexPath:indexPath];
    if (item) {
        return @[item];
    }
    return @[];
}

/* Called to request items to add to an existing drag session in response to the add item gesture.
 * You can use the provided point (in the collection view's coordinate space) to do additional hit testing if desired.
 * If not implemented, or if an empty array is returned, no items will be added to the drag and the gesture
 * will be handled normally.
 */
- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView
              itemsForAddingToDragSession:(id<UIDragSession>)session
                              atIndexPath:(NSIndexPath *)indexPath
                                    point:(CGPoint)point  API_AVAILABLE(ios(11.0)) {
    NSLog(@"\n%s", __func__);
    UIDragItem *item = [self dragItemAatIndexPath:indexPath];
    if (item) {
        return @[item];
    }
    return @[];
}

/* Allows customization of the preview used for the item being lifted from or cancelling back to the collection view.
 * If not implemented or if nil is returned, the entire cell will be used for the preview.
 */
- (nullable UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dragPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)) {
    NSLog(@"\n%s", __func__);
    return nil;
}

/* Called after the lift animation has completed to signal the start of a drag session.
 * This call will always be balanced with a corresponding call to -collectionView:dragSessionDidEnd:
 */
- (void)collectionView:(UICollectionView *)collectionView dragSessionWillBegin:(id<UIDragSession>)session  API_AVAILABLE(ios(11.0)) {
    NSLog(@"\n%s", __func__);
}

/* Called to signal the end of the drag session.
 */
- (void)collectionView:(UICollectionView *)collectionView dragSessionDidEnd:(id<UIDragSession>)session  API_AVAILABLE(ios(11.0)) {
    
    NSLog(@"\n%s", __func__);
}


/* Controls whether move operations (see UICollectionViewDropProposal.operation) are allowed for the drag session.
 * If not implemented this will default to YES.
 */
- (BOOL)collectionView:(UICollectionView *)collectionView dragSessionAllowsMoveOperation:(id<UIDragSession>)session  API_AVAILABLE(ios(11.0)){
    NSLog(@"\n%s", __func__);
    return YES;
}

/* Controls whether the drag session is restricted to the source application.
 * If YES the current drag session will not be permitted to drop into another application.
 * If not implemented this will default to NO.
 */
- (BOOL)collectionView:(UICollectionView *)collectionView dragSessionIsRestrictedToDraggingApplication:(id<UIDragSession>)session  API_AVAILABLE(ios(11.0)) {
    NSLog(@"\n%s", __func__);
    return NO;
}

#pragma mark - drop

/* Called when the user initiates the drop.
 * Use the dropCoordinator to specify how you wish to animate the dropSession's items into their final position as
 * well as update the collection view's data source with data retrieved from the dropped items.
 * If the supplied method does nothing, default drop animations will be supplied and the collection view will
 * revert back to its initial pre-drop session state.
 */
- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator  API_AVAILABLE(ios(11.0)) {
    NSLog(@"\n%s", __func__);
    NSInteger __block offset = coordinator.destinationIndexPath.item;
    for (id<UICollectionViewDropItem>  _Nonnull dropItem in coordinator.items) {
        // 同一个collectionView的数据交流
        if (dropItem.sourceIndexPath) {
            CellModel *model = self.dataSource[dropItem.sourceIndexPath.section].cells[dropItem.sourceIndexPath.item];
            [self.dataSource[dropItem.sourceIndexPath.section].cells removeObjectAtIndex:dropItem.sourceIndexPath.item];
            [self.dataSource[coordinator.destinationIndexPath.section].cells insertObject:model atIndex:offset];
            
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[dropItem.sourceIndexPath]];
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:offset inSection:coordinator.destinationIndexPath.section]]];
            } completion:^(BOOL finished) { }];
            
            offset ++;
        }
        // 本APP内部数据交流
        else if (dropItem.dragItem.localObject && [dropItem.dragItem.localObject isKindOfClass:[CellModel class]]){
            CellModel *sourceModel = dropItem.dragItem.localObject;
            [self.dataSource[dropItem.sourceIndexPath.section].cells removeObjectAtIndex:dropItem.sourceIndexPath.item];
            [self.dataSource[coordinator.destinationIndexPath.section].cells insertObject:sourceModel atIndex:offset];
            [coordinator dropItem:dropItem.dragItem toItemAtIndexPath:[NSIndexPath indexPathForItem:offset inSection:coordinator.destinationIndexPath.section]];
            offset ++;
        } else {
            // 通过Provider获取数据
            [dropItem.dragItem.itemProvider loadItemForTypeIdentifier:@"MODEL" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *unarchiver = nil;
                    CellModel *model = nil;
                    NSData *mayBeData = (NSData *)item;
                    if ([mayBeData isKindOfClass:NSData.class]) {
                        model = [NSKeyedUnarchiver unarchivedObjectOfClass:CellModel.class fromData:mayBeData error:&unarchiver];
                    }
                    if (error || [model isKindOfClass:CellModel.class] == NO) {
                        return ;
                    }
                    switch (coordinator.proposal.intent) {
                        case UICollectionViewDropIntentUnspecified:
                        case UICollectionViewDropIntentInsertAtDestinationIndexPath: {
                            [self.dataSource[coordinator.destinationIndexPath.section].cells insertObject:model atIndex:offset];
                            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:offset inSection:coordinator.destinationIndexPath.section]]];
                            offset ++;
                        } break;
                        case UICollectionViewDropIntentInsertIntoDestinationIndexPath: {
                            CellModel *desModel = self.dataSource[coordinator.destinationIndexPath.section].cells[coordinator.destinationIndexPath.item];
                            desModel.title = [desModel.title stringByAppendingString:model.title];
                            [self.collectionView reloadItemsAtIndexPaths:@[coordinator.destinationIndexPath]];
                        }  break;
                    }
                });
            }];
        }
    }
}

/* If NO is returned no further delegate methods will be called for this drop session.
 * If not implemented, a default value of YES is assumed.
 */
- (BOOL)collectionView:(UICollectionView *)collectionView canHandleDropSession:(id<UIDropSession>)session  API_AVAILABLE(ios(11.0)) {
    NSLog(@"\n%s", __func__);
    return YES;
}

/* Called when the drop session begins tracking in the collection view's coordinate space.
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnter:(id<UIDropSession>)session  API_AVAILABLE(ios(11.0)){
    NSLog(@"\n%s", __func__);
    
}

/* Called frequently while the drop session being tracked inside the collection view's coordinate space.
 * When the drop is at the end of a section, the destination index path passed will be for a item that does not yet exist (equal
 * to the number of items in that section), where an inserted item would append to the end of the section.
 * The destination index path may be nil in some circumstances (e.g. when dragging over empty space where there are no cells).
 * Note that in some cases your proposal may not be allowed and the system will enforce a different proposal.
 * You may perform your own hit testing via -[UIDropSession locationInView]
 */
- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath  API_AVAILABLE(ios(11.0)) {
    NSLog(@"\n%s", __func__);
    UIDropOperation opeartion = UIDropOperationCopy;
    if (session.allowsMoveOperation) {
        opeartion = UIDropOperationMove;
    }
    return [[UICollectionViewDropProposal alloc] initWithDropOperation:opeartion intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
}

/* Called when the drop session is no longer being tracked inside the collection view's coordinate space.
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidExit:(id<UIDropSession>)session  API_AVAILABLE(ios(11.0)){
    NSLog(@"\n%s", __func__);
    
}

/* Called when the drop session completed, regardless of outcome. Useful for performing any cleanup.
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnd:(id<UIDropSession>)session  API_AVAILABLE(ios(11.0)){
    NSLog(@"\n%s", __func__);
    
}

/* Allows customization of the preview used for the item being dropped.
 * If not implemented or if nil is returned, the entire cell will be used for the preview.
 *
 * This will be called as needed when animating drops via -[UICollectionViewDropCoordinator dropItem:toItemAtIndexPath:]
 * (to customize placeholder drops, please see UICollectionViewDropPlaceholder.previewParametersProvider)
 */
- (nullable UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dropPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    NSLog(@"\n%s", __func__);
    return nil;
}

@end
