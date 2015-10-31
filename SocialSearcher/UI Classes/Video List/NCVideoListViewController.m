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
    
    // load more
    NCYoutubeDataManager* _youtubeDataManager;
    BOOL _bNextRequestSent;
    BOOL _bAllListLoaded;
}
@property (strong, nonatomic) IBOutlet UITableView *tableVideoList;
@end

@interface NCVideoListViewController(CreateMethods)
-(BOOL)createTalbeListView;
@end

@interface NCVideoListViewController(PrivateMethods)
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
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
    [self initialize];
}

-(void)prepareForRelease
{
    
}

-(void)dealloc
{
    NSLog(@"NCVideoListViewController::DEALLOC");
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
    _defaultPlayListID = _dicInfo[@"id"];
    [_youtubeDataManager reqeustVideoListWithPlayListInfo:_defaultPlayListID];
    return YES;
}

-(BOOL)privateInitializeUI
{
    self.title = [_dicInfo valueForKeyPath:@"snippet.title"];
    [self createTalbeListView];
    
    return YES;
}

#pragma mark - NCYoutubeDataManagerDelegate

// reqeustVideoListWithPlayListInfo
-(void)reqeustVideoListWithPlayListInfoFinished:(NSString*)playListID
{
    if (![_defaultPlayListID isEqualToString:playListID]) {
        return;
    }
    
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    _arrayDataList = [NSArray arrayWithArray:[dataContainer.dicYoutubeVideoListResult objectForKey:_defaultPlayListID]];
    [_tableVideoList reloadData];
}

-(void)reqeustVideoListWithPlayListInfoNoData:(NSString*)playListID
{
    
}

-(void)reqeustVideoListWithPlayListInfoFailed:(NSString*)playListID
{
    
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

@end
