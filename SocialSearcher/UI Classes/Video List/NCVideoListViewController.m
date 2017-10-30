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

#pragma mark - Definition

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
@property BOOL bNextRequestSent;
@property BOOL bAllListLoaded;
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

#pragma mark - Implementation

@implementation NCVideoListViewController

#pragma mark - class life cycle

-(instancetype)init
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
    
    [self privateInitializeSetting];
    [self privateInitializeUI];
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
    
    if ([segue.identifier isEqualToString:@"ShowVideoPlayer"]) {
        // fetch slected data
        NSIndexPath* indexPathSelected = _tableVideoList.indexPathForSelectedRow;
        NSDictionary* dicInfo = _arrayDataList[indexPathSelected.row];
        DLog(@"selected dic=%@", dicInfo);
        
        // set data
        NCVideoPlayerViewController *vc = segue.destinationViewController;
        vc.dicInfo = dicInfo;
    }
}

-(void)viewDidLayoutSubviews
{
    // check refresh
    BOOL bNeedToRefresh = NO;
    {
        // portrait -> scroll vertical
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) || (UIDeviceOrientationFaceUp == [UIDevice currentDevice].orientation)) {
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
            if (UIDeviceOrientationIsPortrait(_deviceOrientation) || (UIDeviceOrientationFaceUp == _deviceOrientation)) {
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
    _arrayDataList = [NSArray arrayWithArray:(dataContainer.dicDataYoutubeVideoListResult)[_defaultPlayListID]];
    [_tableVideoList reloadData];
    
    // check load all
    NSString* savedNextToken = (dataContainer.dicDataYoutubeVideoListNextTokenInfo)[_defaultPlayListID];
    if (_arrayDataList.count < (DEFAULT_MAXRESULTS).intValue && !savedNextToken) {
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
        NSString* savedNextToken = (dataContainer.dicDataYoutubeVideoListNextTokenInfo)[_defaultPlayListID];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayDataList.count;
}

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

#pragma mark - UIScrollViewDelegate

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

@end
