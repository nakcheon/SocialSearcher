//
//  NCVideoListViewController.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCVideoListViewController.h"
#import "NCVideoItemCell.h"
#import "NCYoutubeDataManager.h"
#import "NCYoutubeDataContainer.h"
#import "NCVideoPlayerViewController.h"
#import "RequestDefine.h"

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

@interface NCVideoListViewController() <UITableViewDataSource, UITableViewDelegate, NCYoutubeDataManagerDelegate>
{
    NSString* _defaultPlayListID;
    NSArray* _arrayDataList;
    UIDeviceOrientation _deviceOrientation;
    
    // load more
    NCYoutubeDataManager* _youtubeDataManager;
}
@property (strong, nonatomic) IBOutlet UITableView *tableVideoList;
// load more
@property (assign, nonatomic) BOOL bNextRequestSent;
@property (assign, nonatomic) BOOL bAllListLoaded;
@end

@interface NCVideoListViewController(CreateMethods)
-(BOOL)createTalbeListView;
@end

@interface NCVideoListViewController(PrivateMethods)
// life cycle
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
// load more
-(BOOL)privateRequestList;
-(BOOL)privateAddLoadingView;
-(BOOL)privateRemoveLoadingView;
@end

@interface NCVideoListViewController(PrivateServerCommunications)
@end

@interface NCVideoListViewController(selectors)
@end

@interface NCVideoListViewController(IBActions)
@end

@interface NCVideoListViewController(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation NCVideoListViewController

#pragma mark - class life cycle

-(id)init
{
    self = [super init];
    if (self) {
        NSLog(@"NCVideoListViewController::INIT");
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
    NSLog(@"NCVideoListViewController::DEALLOC");
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
    
    if ([[segue identifier] isEqualToString:@"ShowVideoPlayer"]) {
        // fetch slected data
        NSIndexPath* indexPathSelected = [_tableVideoList indexPathForSelectedRow];
        NSDictionary* dicInfo = _arrayDataList[indexPathSelected.row];
        DLog(@"selected dic=%@", dicInfo);
        
        // set data
        NCVideoPlayerViewController *vc = [segue destinationViewController];
        vc.dicInfo = dicInfo;
    }
}

-(void)viewDidLayoutSubviews
{
    // check refresh
    BOOL bNeedToRefresh = NO;
    {
        // portrait -> scroll vertical
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
            DLog(@"viewDidLayoutSubviews::PORTRAIT");
            if (UIDeviceOrientationIsLandscape(_deviceOrientation)) {
                _deviceOrientation = [UIDevice currentDevice].orientation;
                bNeedToRefresh = YES;
            }
            else {
                DLog(@"viewDidLayoutSubviews::DUPLICATE PORT");
            }
        }
        // landscape -> scroll horizontal
        else {
            DLog(@"viewDidLayoutSubviews::LANDSCAPE");
            if (UIDeviceOrientationIsPortrait(_deviceOrientation)) {
                _deviceOrientation = [UIDevice currentDevice].orientation;
                bNeedToRefresh = YES;
            }
            else {
                DLog(@"viewDidLayoutSubviews::DUPLICATE LAND");
            }
        }
    }
    
    // refresh
    if (bNeedToRefresh) {
        [_tableVideoList reloadData];
    }
}

#pragma mark - create methods

-(BOOL)createTalbeListView
{
    _tableVideoList.estimatedRowHeight = 100.0;
    _tableVideoList.rowHeight = UITableViewAutomaticDimension;
    _tableVideoList.separatorColor = [UIColor clearColor];
    return YES;
}

#pragma mark - operations

-(void)initialize
{
    [self privateInitializeSetting];
    [self privateInitializeUI];
}

#pragma mark - private methods

-(BOOL)privateInitializeSetting
{
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    // data came from recommended categories
    _defaultPlayListID = _dicInfo[@"id"];
    if (![_defaultPlayListID isKindOfClass:[NSString class]]) {
        _defaultPlayListID = [_dicInfo valueForKeyPath:@"id.playlistId"];
    }
    if (![_defaultPlayListID isKindOfClass:[NSString class]]) {
        _defaultPlayListID = [_dicInfo valueForKeyPath:@"id.channelId"];
    }
    
    // reset data
    [[NCYoutubeDataContainer sharedInstance] RemoveYoutubeVideoList:_defaultPlayListID];
    
    // data came from search view controller
    [_youtubeDataManager reqeustVideoListWithPlayListInfo:_defaultPlayListID];
    
    // datas
    _deviceOrientation = [UIDevice currentDevice].orientation;
    return YES;
}

-(BOOL)privateInitializeUI
{
    self.title = [_dicInfo valueForKeyPath:@"snippet.title"];
    [self createTalbeListView];
    
    return YES;
}

-(BOOL)privateRequestList
{
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    
    [_youtubeDataManager reqeustVideoListWithPlayListInfo:_defaultPlayListID];
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

// reqeustVideoListWithPlayListInfo
-(void)reqeustVideoListWithPlayListInfoFinished:(NSString*)playListID
{
    if (![_defaultPlayListID isEqualToString:playListID]) {
        return;
    }
    _bNextRequestSent = NO;
    _bAllListLoaded = NO;
    
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    _arrayDataList = [NSArray arrayWithArray:[dataContainer.dicYoutubeVideoListResult objectForKey:_defaultPlayListID]];
    [_tableVideoList reloadData];
    
    // check load all
    NSString* savedNextToken = [dataContainer.dicYoutubeVideoListNextTokenInfo objectForKey:_defaultPlayListID];
    if (_arrayDataList.count < [DEFAULT_MAXRESULTS intValue] && !savedNextToken) {
        _bAllListLoaded = YES;
    }
}

-(void)reqeustVideoListWithPlayListInfoNoData:(NSString*)playListID
{
    NCVideoListViewController* __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong NCVideoListViewController* strongSelf = weakSelf;
        strongSelf.bNextRequestSent = NO;
        strongSelf.bAllListLoaded = NO;
        
        // check load all
        NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
        NSString* savedNextToken = [dataContainer.dicYoutubeVideoListNextTokenInfo objectForKey:_defaultPlayListID];
        if (!savedNextToken) {
            strongSelf.bAllListLoaded = YES;
        }
    });
}

-(void)reqeustVideoListWithPlayListInfoFailed:(NSString*)playListID
{
    _bNextRequestSent = NO;
}


#pragma mark - UITableViewDataSource
//@required

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayDataList.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"NCVideoItemCell";
    NCVideoItemCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell prepareForReuse];
    
    // ui automation support
    cell.isAccessibilityElement = YES;
    cell.accessibilityLabel = @"NCVideoItemCell";
    
    // set data
    {
        NSDictionary* dicUserInfo = [NSDictionary dictionaryWithDictionary:_arrayDataList[indexPath.row]];
        cell.dicInfo = dicUserInfo;
        if (indexPath.row + 1 >= _arrayDataList.count) {
            cell.bIsLastItem = YES;
        }
        [cell initialize];
    }
    
    return cell;
}

//@optional
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented
//
//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
//- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
//
//// Editing
//
//// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
//
//// Moving/reordering
//
//// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
//
//// Index
//
//- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView __TVOS_PROHIBITED;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index __TVOS_PROHIBITED;  // tell table which section corresponds to section title/index (e.g. "B",1))
//
//// Data manipulation - insert and delete support
//
//// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
//// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
//
//// Data manipulation - reorder / moving support
//
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

#pragma mark - UITableViewDelegate
//@optional
//
//// Display customization
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
//- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0);
//- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
//- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
//
//// Variable height support
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
//
//// Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
//// If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0);
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0);
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0);
//
//// Section header & footer information. Views are preferred over title should you decide to provide both
//
//- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
//- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;   // custom view for footer. will be adjusted to default or specified footer height
//
//// Accessories (disclosures).
//
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath NS_DEPRECATED_IOS(2_0, 3_0) __TVOS_PROHIBITED;
//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
//
//// Selection
//
//// -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
//// Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
//- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
//- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
//
//// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
//- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);
//// Called after the user changes the selection.
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);
//
//// Editing
//
//// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
//- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED;
//- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED; // supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
//
//// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;
//
//// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
//- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED;
//- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED;
//
//// Moving/reordering
//
//// Allows customization of the target row for a particular row as it is being moved/reordered
//- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
//
//// Indentation
//
//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath; // return 'depth' of row for hierarchies
//
//// Copy/Paste.  All three methods must be implemented by the delegate.
//
//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(5_0);
//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0);
//- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender NS_AVAILABLE_IOS(5_0);
//
//#ifndef SDK_HIDE_TIDE
//// Focus
//
//- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0);
//- (BOOL)tableView:(UITableView *)tableView shouldUpdateFocusInContext:(UITableViewFocusUpdateContext *)context NS_AVAILABLE_IOS(9_0);
//- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator NS_AVAILABLE_IOS(9_0);
//- (nullable NSIndexPath *)indexPathForPreferredFocusedViewInTableView:(UITableView *)tableView NS_AVAILABLE_IOS(9_0);
//#endif

#pragma mark - UIScrollViewDelegate
//@optional

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_arrayDataList.count <= 0) {
        return;
    }
    
    // load more
    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height) {
        DLog(@"contents size = %f", scrollView.contentSize.height);
        if (!_bNextRequestSent && !_bAllListLoaded) {
            [_tableVideoList setContentOffset:CGPointMake(_tableVideoList.contentOffset.x, _tableVideoList.frame.origin.y + _tableVideoList.contentSize.height-self.view.frame.size.height + 40)
                                     animated:YES];
            _bNextRequestSent = YES;
            if ([self privateRequestList]) {
                [self privateAddLoadingView];
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
