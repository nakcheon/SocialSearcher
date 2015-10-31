//
//  NCMainGuidedChannelListViewController.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCMainGuidedChannelListViewController.h"
#import "NCChannelItemCell.h"

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


/******************************************************************************
 * Type Definition
 *****************************************************************************/

@interface NCMainGuidedChannelListViewController() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionChannelList;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionChannelListLayout;
@end

@interface NCMainGuidedChannelListViewController(CreateMethods)
@end

@interface NCMainGuidedChannelListViewController(PrivateMethods)
@end

@interface NCMainGuidedChannelListViewController(PrivateServerCommunications)
@end

@interface NCMainGuidedChannelListViewController(selectors)
@end

@interface NCMainGuidedChannelListViewController(IBActions)
@end

@interface NCMainGuidedChannelListViewController(ProcessMethod)
@end


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

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

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
    
}

#pragma mark - overrides

-(void)viewDidLayoutSubviews
{
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        DLog(@"viewDidLayoutSubviews::PORTRAIT");
        if (_collectionChannelListLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            _collectionChannelListLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
        else {
            DLog(@"viewDidLayoutSubviews::DUPLICATE PORT");
        }
    }
    else {
        DLog(@"viewDidLayoutSubviews::LANDSCAPE");
        if (_collectionChannelListLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
            _collectionChannelListLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        }
        else {
            DLog(@"viewDidLayoutSubviews::DUPLICATE LAND");
        }
    }
    
    [_collectionChannelList reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        float width = (self.view.bounds.size.width - 15) / 2;
        float height = (width / 16 * 9) * 1.5;
        return CGSizeMake(width, height);
    }
    else {
        float startY = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
        float height = (_collectionChannelList.bounds.size.height - startY - 15) / 2;
        float width = (height / 3 * 2) / 9 * 16;
        return CGSizeMake(width, height);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

#pragma mark - UICollectionViewDataSource
//@required

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
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
    
//    // set data
//    {
//        NSDictionary* dicUserInfo = [NSDictionary dictionaryWithDictionary:_arrayDataList[indexPath.row]];
//        cell.delegate = self;
//        cell.dicInfo = dicUserInfo;
//        [cell initialize];
//    }
    
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

@end
