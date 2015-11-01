//
//  NCMainGuidedChannelListViewController.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCMainGuidedChannelListViewController.h"
#import "NCChannelItemCell.h"
#import "NCYoutubeDataContainer.h"
#import <NSTimeZone-CountryCode/NSTimeZone+CountryCode.h>
#import "NCVideoListViewController.h"

#pragma mark - enum Definition

/******************************************************************************
 * enum Definition
 *****************************************************************************/


/******************************************************************************
 * String Definition
 *****************************************************************************/


/******************************************************************************
 * Constant Definition
 *****************************************************************************/


/******************************************************************************
 * Function Definition
 *****************************************************************************/


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation NCMainGuidedChannelListViewController

#pragma mark - class life cycle

-(id)init
{
    self = [super init];
    if (self) {
        NSLog(@"NCMainGuidedChannelListViewController::INIT");
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
}

-(void)prepareForRelease
{
    
}

-(void)dealloc
{
    NSLog(@"NCMainGuidedChannelListViewController::DEALLOC");
}

#pragma mark - operations

-(void)initialize
{
    [self privateInitializeSetting];
    [self privateInitializeUI];
}

#pragma mark - view controller

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // remove view - apples recommendation
    if (![self.navigationController.topViewController isEqual:self]) {
        [self.view removeFromSuperview];
        self.view = nil;
    }
    else {
        DLog(@"NOT REMOVE VIEW::top viewcontoller::%@", [self class]);
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DLog(@"prepareForSegue");
    
    if ([[segue identifier] isEqualToString:@"MoveToVideoList"]) {
        // fetch slected data
        NSArray* arraySelected = [_collectionChannelList indexPathsForSelectedItems];
        NSIndexPath* indexPathSelected = arraySelected.firstObject;
        NSDictionary* dicInfo = _arrayDataList[indexPathSelected.row];
        DLog(@"selected dic=%@", dicInfo);
        
        // set data
        NCVideoListViewController *vc = [segue destinationViewController];
        vc.dicInfo = dicInfo;
    }
}

-(void)viewDidLayoutSubviews
{
    // scroll direction
    {
        // portrait -> scroll vertical
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
            DLog(@"viewDidLayoutSubviews::PORTRAIT");
            if (_collectionChannelListLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                _collectionChannelListLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
            }
            else {
                DLog(@"viewDidLayoutSubviews::DUPLICATE PORT");
            }
        }
        // landscape -> scroll horizontal
        else {
            DLog(@"viewDidLayoutSubviews::LANDSCAPE");
            if (_collectionChannelListLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
                _collectionChannelListLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            }
            else {
                DLog(@"viewDidLayoutSubviews::DUPLICATE LAND");
            }
        }
    }
    
    // refresh
    {
        // iphone
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [_collectionChannelList reloadData];
        }
        // ipad
        else {
            CGSize sizeCell = [self collectionView:_collectionChannelList
                                            layout:_collectionChannelListLayout
                            sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            
            [_collectionChannelListLayout setItemSize:sizeCell];
        }
    }
}

#pragma mark - private methods

-(BOOL)privateInitializeSetting
{
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    [_youtubeDataManager reqeustGuideCategoriesList];
    return YES;
}

-(BOOL)privateInitializeUI
{
    return YES;
}

-(BOOL)privateRequestList
{
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    
    [_youtubeDataManager reqeustPlayListWithChannelInfo:_defaultChannelID];
    return YES;
}

-(BOOL)privateAddLoadingView
{
    return YES;
}

-(BOOL)privateRemoveLoadingView
{
    return YES;
}

#pragma mark - NCYoutubeDataManagerDelegate

// reqeustguideCategoriesList
-(void)reqeustGuideCategoriesListFinished
{
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSString* keyToFetch = [NSTimeZone countryCodeFromLocalizedName];
    NSArray* arrayList = [dataContainer.dicYoutubeGuideInfoResult objectForKey:keyToFetch];
    
    NSDictionary* dicInfo = [arrayList firstObject];
    _defaultChannelID = [dicInfo valueForKeyPath:@"snippet.channelId"];
    
    [_youtubeDataManager reqeustPlayListWithChannelInfo:_defaultChannelID];
}

-(void)reqeustGuideCategoriesListNoData
{
    
}

-(void)reqeustGuideCategoriesListFailed
{
    
}

// reqeustPlayListWithChannelInfo
-(void)reqeustPlayListWithChannelInfoFinished:(NSString*)channelID
{
    if (![_defaultChannelID isEqualToString:channelID]) {
        return;
    }
    _bNextRequestSent = NO;
    _bAllListLoaded = NO;
    
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    _arrayDataList = [NSArray arrayWithArray:[dataContainer.dicYoutubePlayListResult objectForKey:channelID]];
    [_collectionChannelList reloadData];
}

-(void)reqeustPlayListWithChannelInfoNoData:(NSString*)channelID
{
    _bNextRequestSent = NO;
    _bAllListLoaded = NO;
}

-(void)reqeustPlayListWithChannelInfoFailed:(NSString*)channelID
{
    _bNextRequestSent = NO;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // ipad - 3 columns (portrait) or lines (landscape)
    // iphone - 2 columns (portrait) or lines (landscape)
    int numberOfCells = 2;
    float totalMargin = 15;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        numberOfCells = 3;
        totalMargin = 20;
    }
    
    // portait - calculate with width (16:9)
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        float width = (self.view.bounds.size.width - totalMargin) / numberOfCells;
        float height = (width / 16 * 9) * 1.5;
        return CGSizeMake(width, height);
    }
    // landscate - calcuate with height (16:9)
    else {
        float startY = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
        float height = (_collectionChannelList.bounds.size.height - startY - totalMargin) / numberOfCells;
        float width = (height / 3 * 2) / 9 * 16;
        return CGSizeMake(width, height);
    }
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

#pragma mark - UICollectionViewDataSource
//@required

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrayDataList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // create
    NCChannelItemCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NCChannelItemCell"
                                                                        forIndexPath:indexPath];
    [cell prepareForReuse];
    
    // ui automation support
    cell.isAccessibilityElement = YES;
    cell.accessibilityLabel = @"NCChannelItemCell";
    
    // set data
    NSDictionary* dicUserInfo = [NSDictionary dictionaryWithDictionary:_arrayDataList[indexPath.row]];
    cell.dicInfo = dicUserInfo;
    [cell initialize];
    
    return cell;
}

//@optional
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
//
//// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0);
//- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath NS_AVAILABLE_IOS(9_0);

#pragma mark - UICollectionViewDelegate
//@optional
//
//// Methods for notification of selection/deselection and highlight/unhighlight events.
//// The sequence of calls leading to selection from a user touch is:
////
//// (when the touch begins)
//// 1. -collectionView:shouldHighlightItemAtIndexPath:
//// 2. -collectionView:didHighlightItemAtIndexPath:
////
//// (when the touch lifts)
//// 3. -collectionView:shouldSelectItemAtIndexPath: or -collectionView:shouldDeselectItemAtIndexPath:
//// 4. -collectionView:didSelectItemAtIndexPath: or -collectionView:didDeselectItemAtIndexPath:
//// 5. -collectionView:didUnhighlightItemAtIndexPath:
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath; // called when the user taps on an already-selected item in multi-select mode
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0);
//- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0);
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
//
//// These methods provide support for copy/paste actions on cells.
//// All three should be implemented if any are.
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender;
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender;
//
//// support for custom transition layout
//- (nonnull UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout;
//#ifndef SDK_HIDE_TIDE
//// Focus
//- (BOOL)collectionView:(UICollectionView *)collectionView canFocusItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0);
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context NS_AVAILABLE_IOS(9_0);
//- (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator NS_AVAILABLE_IOS(9_0);
//- (nullable NSIndexPath *)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView NS_AVAILABLE_IOS(9_0);
//#endif
//
//- (NSIndexPath *)collectionView:(UICollectionView *)collectionView targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)originalIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath NS_AVAILABLE_IOS(9_0);
//
//- (CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset NS_AVAILABLE_IOS(9_0); // customize the content offset to be applied during transition or update animations

#pragma mark - UIScrollViewDelegate
//@optional

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_arrayDataList.count <= 0) {
        return;
    }
    
    // load more
    {
        // portait
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
            if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height) {
                DLog(@"contents size = %f", scrollView.contentSize.height);
                if (!_bNextRequestSent && !_bAllListLoaded) {
                    [_collectionChannelList setContentOffset:CGPointMake(_collectionChannelList.contentOffset.x, _collectionChannelList.frame.origin.y + _collectionChannelList.contentSize.height-self.view.frame.size.height + 40)
                                                    animated:YES];
                    _bNextRequestSent = YES;
                    if ([self privateRequestList]) {
                        [self privateAddLoadingView];
                    }
                }
            }
        }
        // landscapte
        else {
            if (scrollView.contentOffset.x + scrollView.frame.size.width > scrollView.contentSize.width) {
                DLog(@"contents size = %f", scrollView.contentSize.height);
                if (!_bNextRequestSent && !_bAllListLoaded) {
                    [_collectionChannelList setContentOffset:CGPointMake(_collectionChannelList.frame.origin.x + _collectionChannelList.contentSize.width-self.view.frame.size.width + 40, _collectionChannelList.contentOffset.y)
                                                    animated:YES];
                    _bNextRequestSent = YES;
                    if ([self privateRequestList]) {
                        [self privateAddLoadingView];
                    }
                }
            }
        }
    }
}
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2); // any zoom scale changes
//
//// called on start of dragging (may require some time and or distance to move)
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
//// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0);
//// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
//
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;   // called on finger up as we are moving
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;      // called when scroll view grinds to a halt
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
//
//- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;     // return a view that will be scaled. if delegate returns nil, nothing happens
//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view NS_AVAILABLE_IOS(3_2); // called before the scroll view begins zooming its content
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale; // scale between minimum and maximum. called after any 'bounce' animations
//
//- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;   // return a yes if you want to scroll to the top. if not defined, assumes YES
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;      // called when scrolling animation finished. may be called immediately if already at top

@end
