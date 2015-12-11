//
//  NCSearchViewController.m
//  SocialSearcher
//
//  Created by NakCheonJung on 11/1/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCSearchViewController.h"
#import "NCYoutubeDataManager.h"
#import "NCSearchResultCell.h"
#import "NCYoutubeDataContainer.h"
#import "NCVideoPlayerViewController.h"
#import "NCVideoListViewController.h"
#import "NCChannelListViewController.h"
#import "RequestDefine.h"

#pragma mark - Definition

@interface NCSearchViewController() <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NCYoutubeDataManagerDelegate>
{
    NSArray* _arrayDataList;
    UIDeviceOrientation _deviceOrientation;
    
    // flags
    BOOL _bIsSearchBarInitiallyFocused;
    
    // load more
    NCYoutubeDataManager* _youtubeDataManager;
}
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *videoSearchDisplayController;
// load more
@property (assign, nonatomic) BOOL bNextRequestSent;
@property (assign, nonatomic) BOOL bAllListLoaded;
@end

@interface NCSearchViewController(PrivateMethods)
// load more
-(BOOL)privateRequestList;
@end

#pragma mark - Implementation

@implementation NCSearchViewController

#pragma mark - class life cycle

-(id)init
{
    self = [super init];
    if (self) {
        NSLog(@"NCSearchViewController::INIT");
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
}

-(void)dealloc
{
    NSLog(@"NCSearchViewController::DEALLOC");
}

#pragma mark - view controller

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //// remove view - apples recommendation
    //if (![self.navigationController.topViewController isEqual:self]) {
    //    [self.view removeFromSuperview];
    //    self.view = nil;
    //}
    //else {
    //    DLog(@"NOT REMOVE VIEW::top viewcontoller::%@", [self class]);
    //}
    DLog(@"NOT REMOVE VIEW::top viewcontoller::%@", [self class]);
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DLog(@"prepareForSegue");
    
    if ([[segue identifier] isEqualToString:@"ShowSearchViewFromSearchView"]) {
        // fetch slected data
        NSIndexPath* indexPathSelected = [_videoSearchDisplayController.searchResultsTableView indexPathForSelectedRow];
        NSDictionary* dicInfo = _arrayDataList[indexPathSelected.row];
        DLog(@"selected dic=%@", dicInfo);
        
        // set data
        NCVideoPlayerViewController *vc = [segue destinationViewController];
        vc.dicInfo = dicInfo;
    }
    else if ([[segue identifier] isEqualToString:@"ShowVideoListViewFromSearchView"]) {
        // fetch slected data
        NSIndexPath* indexPathSelected = [_videoSearchDisplayController.searchResultsTableView indexPathForSelectedRow];
        NSDictionary* dicInfo = _arrayDataList[indexPathSelected.row];
        DLog(@"selected dic=%@", dicInfo);
        
        // set data
        NCVideoListViewController *vc = [segue destinationViewController];
        vc.dicInfo = dicInfo;
    }
    else if ([[segue identifier] isEqualToString:@"ShowChannelViewFromSearchView"]) {
        // fetch slected data
        NSIndexPath* indexPathSelected = [_videoSearchDisplayController.searchResultsTableView indexPathForSelectedRow];
        NSDictionary* dicInfo = _arrayDataList[indexPathSelected.row];
        DLog(@"selected dic=%@", dicInfo);
        
        // set data
        NCChannelListViewController *vc = [segue destinationViewController];
        vc.dicInfo = dicInfo;
    }
}

-(void)viewDidLayoutSubviews
{
    if (![_searchBar isFocused] && !_bIsSearchBarInitiallyFocused) {
        _bIsSearchBarInitiallyFocused = YES;
        [_searchBar becomeFirstResponder];
    }
    // table setting
    {
        [_videoSearchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"NCSearchResultCell" bundle:nil] forCellReuseIdentifier:@"NCSearchResultCell"];
        _videoSearchDisplayController.searchResultsTableView.estimatedRowHeight = 100.0;
        _videoSearchDisplayController.searchResultsTableView.rowHeight = UITableViewAutomaticDimension;
        _videoSearchDisplayController.searchResultsTableView.separatorColor = [UIColor clearColor];
        _videoSearchDisplayController.searchResultsTableView.delegate = self;
    }
    // refresh
    [_videoSearchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - operations

-(void)initialize
{
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
}

#pragma mark - private methods

-(BOOL)privateRequestList
{
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    
    [_youtubeDataManager reqeustSearch:_searchBar.text];
    return YES;
}

#pragma mark - NCYoutubeDataManagerDelegate

// reqeustSearch
-(void)reqeustSearchFinished:(NSString*)query
{
    _bNextRequestSent = NO;
    _bAllListLoaded = NO;
    
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    _arrayDataList = [NSArray arrayWithArray:[dataContainer.dicYoutubeSearchResult objectForKey:query]];
    [_videoSearchDisplayController.searchResultsTableView reloadData];
    
    // check load all
    NSString* savedNextToken = [dataContainer.dicYoutubeSearchNextTokenInfo objectForKey:query];
    if (_arrayDataList.count < [DEFAULT_MAXRESULTS intValue] && !savedNextToken) {
        _bAllListLoaded = YES;
    }
}

-(void)reqeustSearchNoData:(NSString*)query
{
    NCSearchViewController* __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong NCSearchViewController* strongSelf = weakSelf;
        strongSelf.bNextRequestSent = NO;
        strongSelf.bAllListLoaded = NO;
        
        // check load all
        NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
        NSString* savedNextToken = [dataContainer.dicYoutubeSearchNextTokenInfo objectForKey:query];
        if (!savedNextToken) {
            strongSelf.bAllListLoaded = YES;
        }
    });
}

-(void)reqeustSearchFailed:(NSString*)query
{
    _bNextRequestSent = NO;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    DLog(@"searchBar.text=%@, searchText=%@", searchBar.text, searchText);
    if ([searchBar.text isEqualToString:@""] || [searchText isEqualToString:@""]) {
        _arrayDataList = nil;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    DLog(@"SEARCH TEXT=%@", searchBar.text);

    // reset data
    [[NCYoutubeDataContainer sharedInstance] RemoveYoutubeSearchResult:_searchBar.text];
    
    // request
    [_youtubeDataManager reqeustSearch:_searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar                     // called when cancel button pressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"NCSearchResultCell";
    NCSearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell prepareForReuse];
    
    // ui automation support
    cell.isAccessibilityElement = YES;
    cell.accessibilityLabel = @"NCSearchResultCell";
    
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NCSearchResultCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell.bIsList && !cell.bIsChannel) {
        [self performSegueWithIdentifier:@"ShowSearchViewFromSearchView" sender:cell];
    }
    else if (cell.bIsList) {
        [self performSegueWithIdentifier:@"ShowVideoListViewFromSearchView" sender:cell];
    }
    else if (cell.bIsChannel) {
        [self performSegueWithIdentifier:@"ShowChannelViewFromSearchView" sender:cell];
    }
    
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
            [_videoSearchDisplayController.searchResultsTableView setContentOffset:CGPointMake(_videoSearchDisplayController.searchResultsTableView.contentOffset.x, _videoSearchDisplayController.searchResultsTableView.frame.origin.y + _videoSearchDisplayController.searchResultsTableView.contentSize.height-self.view.frame.size.height + 40)
                                     animated:YES];
            _bNextRequestSent = YES;
            [self privateRequestList];
        }
    }
}

@end
