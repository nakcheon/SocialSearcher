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
#import <NSTimeZone_CountryCode/NSTimeZone-CountryCode-umbrella.h>
#import "NCVideoListViewController.h"
#import "RequestDefine.h"

#pragma mark - Implementation

@implementation NCMainGuidedChannelListViewController

#pragma mark - class life cycle

-(instancetype)init
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
    
    [self privateInitializeSetting];
}

-(void)dealloc
{
    NSLog(@"NCMainGuidedChannelListViewController::DEALLOC");
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
    
    if ([segue.identifier isEqualToString:@"MoveToVideoList"]) {
        // fetch slected data
        NSArray* arraySelected = [_collectionChannelList indexPathsForSelectedItems];
        NSIndexPath* indexPathSelected = arraySelected.firstObject;
        NSDictionary* dicInfo = _arrayDataList[indexPathSelected.row];
        DLog(@"selected dic=%@", dicInfo);
        
        // set data
        NCVideoListViewController *vc = segue.destinationViewController;
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
            
            _collectionChannelListLayout.itemSize = sizeCell;
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

-(BOOL)privateRequestList
{
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    
    [_youtubeDataManager reqeustPlayListWithChannelInfo:_defaultChannelID];
    return YES;
}

#pragma mark - NCYoutubeDataManagerDelegate

// reqeustguideCategoriesList
-(void)reqeustGuideCategoriesListFinished
{
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSString* keyToFetch = [NSTimeZone countryCodeFromLocalizedName];
    NSArray* arrayList = (dataContainer.dicDataYoutubeGuideInfoResult)[keyToFetch];
    
    NSDictionary* dicInfo = arrayList.firstObject;
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
    _arrayDataList = [NSArray arrayWithArray:(dataContainer.dicDataYoutubePlayListResult)[channelID]];
    [_collectionChannelList reloadData];
    
    // check load all
    NSString* savedNextToken = (dataContainer.dicDataYoutubePlayListNextTokenInfo)[channelID];
    if (_arrayDataList.count < (DEFAULT_MAXRESULTS).intValue && !savedNextToken) {
        _bAllListLoaded = YES;
    }
}

-(void)reqeustPlayListWithChannelInfoNoData:(NSString*)channelID
{
    NCMainGuidedChannelListViewController* __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong NCMainGuidedChannelListViewController* strongSelf = weakSelf;
        strongSelf.bNextRequestSent = NO;
        strongSelf.bAllListLoaded = NO;
        
        // check load all
        NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
        NSString* savedNextToken = (dataContainer.dicDataYoutubePlayListNextTokenInfo)[channelID];
        if (!savedNextToken) {
            strongSelf.bAllListLoaded = YES;
        }
    });
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

#pragma mark - UICollectionViewDataSource

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

#pragma mark - UIScrollViewDelegate

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
                    [self privateRequestList];
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
                    [self privateRequestList];
                }
            }
        }
    } // load more
}

@end
