//
//  NCYoutubeDataManagerTests.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NCYoutubeDataManager.h"
#import "NCYoutubeDataContainer.h"
#import <NSTimeZone-CountryCode/NSTimeZone+CountryCode.h>

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
#define GUIDE_CHANNEL_ID @"UCBR8-60-B28hp2BmDPdntcQ"
#define PLAY_LIST_ID @"PLbpi6ZahtOH518Bih5oLor2AwWEuXmMsI"
#define VIDEO_ID @"8zqdo_Umd5c"
#define SEARCH_QUERY @"list"

/******************************************************************************
 * Function Definition
 *****************************************************************************/
@interface NCYoutubeDataManagerTests : XCTestCase <NCYoutubeDataManagerDelegate>
{
    XCTestExpectation* _expectationReqeustGuideCategoriesList;
    XCTestExpectation* _expectationReqeustPlayListWithChannelInfo;
    XCTestExpectation* _expectationReqeustVideoListWithPlayListInfo;
    XCTestExpectation* _expectationReqeustVideoDetailInfo;
    XCTestExpectation* _expectationReqeustSearch;
}

@end

/******************************************************************************
 * Type Definition
 *****************************************************************************/

@interface NCYoutubeDataManagerTests()
{
    NCYoutubeDataManager* _youtubeDataManager;
}
@end

@interface NCYoutubeDataManagerTests(TestMethods)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation NCYoutubeDataManagerTests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.

    _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
    _youtubeDataManager.delegate = self;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [_youtubeDataManager prepareForRelease];
    _youtubeDataManager.delegate = nil;
    _youtubeDataManager = nil;
}

- (void)testReqeustGuideCategoriesList {
    _expectationReqeustGuideCategoriesList = [self expectationWithDescription:@"reqeustGuideCategoriesList"];
    
    [_youtubeDataManager reqeustGuideCategoriesList];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        NSLog(@"reqeustGuideCategoriesList success");
        _expectationReqeustGuideCategoriesList = nil;
    }];
}

- (void)testReqeustReqeustPlayListWithChannelInfo {
    _expectationReqeustPlayListWithChannelInfo = [self expectationWithDescription:@"reqeustPlayListWithChannelInfo:"];
    
    [_youtubeDataManager reqeustPlayListWithChannelInfo:GUIDE_CHANNEL_ID];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        DLog(@"reqeustPlayListWithChannelInfo: success");
        _expectationReqeustPlayListWithChannelInfo = nil;
    }];
}

- (void)testReqeustVideoListWithPlayListInfo {
    _expectationReqeustVideoListWithPlayListInfo = [self expectationWithDescription:@"reqeustVideoListWithPlayListInfo:"];
    
    [_youtubeDataManager reqeustVideoListWithPlayListInfo:PLAY_LIST_ID];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        DLog(@"reqeustVideoListWithPlayListInfo: success");
        _expectationReqeustVideoListWithPlayListInfo = nil;
    }];
}

- (void)testReqeustVideoDetailInfo {
    _expectationReqeustVideoDetailInfo = [self expectationWithDescription:@"reqeustVideoDetailInfo:"];
    
    [_youtubeDataManager reqeustVideoDetailInfo:VIDEO_ID];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        DLog(@"reqeustVideoDetailInfo: success");
        _expectationReqeustVideoDetailInfo = nil;
    }];
}

- (void)testReqeustSearch {
    _expectationReqeustSearch = [self expectationWithDescription:@"reqeustSearch:"];
    
    [_youtubeDataManager reqeustSearch:SEARCH_QUERY];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        DLog(@"testReqeustSearch: success");
        _expectationReqeustSearch = nil;
    }];
}

#pragma mark - NCYoutubeDataManagerDelegate

// reqeustguideCategoriesList
-(void)reqeustGuideCategoriesListFinished
{
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSString* keyToFetch = [NSTimeZone countryCodeFromLocalizedName];
    NSArray* arrayList = [dataContainer.dicYoutubeGuideInfoResult objectForKey:keyToFetch];
    
    XCTAssert(arrayList && arrayList.count > 0);
    
    if (_expectationReqeustGuideCategoriesList) {
        [_expectationReqeustGuideCategoriesList fulfill];
    }
}

-(void)reqeustGuideCategoriesListNoData
{
    if (_expectationReqeustGuideCategoriesList) {
        [_expectationReqeustGuideCategoriesList fulfill];
    }
}

-(void)reqeustGuideCategoriesListFailed
{
    XCTAssert(FALSE);
    if (_expectationReqeustGuideCategoriesList) {
        [_expectationReqeustGuideCategoriesList fulfill];
    }
}

// reqeustPlayListWithChannelInfo
-(void)reqeustPlayListWithChannelInfoFinished:(NSString*)channelID
{
    XCTAssert([channelID isEqualToString:GUIDE_CHANNEL_ID]);
    
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSArray* arrayList = [dataContainer.dicYoutubePlayListResult objectForKey:channelID];
    
    XCTAssert(arrayList && arrayList.count > 0);
    
    if (_expectationReqeustPlayListWithChannelInfo) {
        [_expectationReqeustPlayListWithChannelInfo fulfill];
    }
}

-(void)reqeustPlayListWithChannelInfoNoData:(NSString*)channelID
{
    XCTAssert([channelID isEqualToString:GUIDE_CHANNEL_ID]);
    
    if (_expectationReqeustPlayListWithChannelInfo) {
        [_expectationReqeustPlayListWithChannelInfo fulfill];
    }
}

-(void)reqeustPlayListWithChannelInfoFailed:(NSString*)channelID
{
    XCTAssert([channelID isEqualToString:GUIDE_CHANNEL_ID]);
    
    if (_expectationReqeustPlayListWithChannelInfo) {
        [_expectationReqeustPlayListWithChannelInfo fulfill];
    }
}

// reqeustVideoListWithPlayListInfo
-(void)reqeustVideoListWithPlayListInfoFinished:(NSString*)playListID
{
    XCTAssert([playListID isEqualToString:PLAY_LIST_ID]);
    
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSArray* arrayList = [dataContainer.dicYoutubeVideoListResult objectForKey:playListID];
    
    XCTAssert(arrayList && arrayList.count > 0);
    
    if (_expectationReqeustVideoListWithPlayListInfo) {
        [_expectationReqeustVideoListWithPlayListInfo fulfill];
    }
}

-(void)reqeustVideoListWithPlayListInfoNoData:(NSString*)playListID
{
    XCTAssert([playListID isEqualToString:PLAY_LIST_ID]);
    
    if (_expectationReqeustVideoListWithPlayListInfo) {
        [_expectationReqeustVideoListWithPlayListInfo fulfill];
    }
}

-(void)reqeustVideoListWithPlayListInfoFailed:(NSString*)playListID
{
    XCTAssert([playListID isEqualToString:PLAY_LIST_ID]);
    
    if (_expectationReqeustVideoListWithPlayListInfo) {
        [_expectationReqeustVideoListWithPlayListInfo fulfill];
    }
}

// reqeustVideoDetailInfo
-(void)reqeustVideoDetailInfoFinished:(NSString*)videoID
{
    XCTAssert([videoID isEqualToString:VIDEO_ID]);
    
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSDictionary* dicDetail = [dataContainer.dicYoutubeVideoDetailResult objectForKey:videoID];
    
    XCTAssert(dicDetail);
    
    if (_expectationReqeustVideoDetailInfo) {
        [_expectationReqeustVideoDetailInfo fulfill];
    }
}

-(void)reqeustVideoDetailInfoNoData:(NSString*)videoID
{
    XCTAssert([videoID isEqualToString:VIDEO_ID]);
    
    if (_expectationReqeustVideoDetailInfo) {
        [_expectationReqeustVideoDetailInfo fulfill];
    }
}

-(void)reqeustVideoDetailInfoFailed:(NSString*)videoID
{
    XCTAssert([videoID isEqualToString:VIDEO_ID]);
    
    if (_expectationReqeustVideoDetailInfo) {
        [_expectationReqeustVideoDetailInfo fulfill];
    }
}

// reqeustSearch
-(void)reqeustSearchFinished:(NSString*)query
{
    XCTAssert([query isEqualToString:SEARCH_QUERY]);
    
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSArray* arrayList = [dataContainer.dicYoutubeSearchResult objectForKey:query];
    
    XCTAssert(arrayList && arrayList.count > 0);
    
    if (_expectationReqeustSearch) {
        [_expectationReqeustSearch fulfill];
    }
}

-(void)reqeustSearchNoData:(NSString*)query
{
    XCTAssert([query isEqualToString:SEARCH_QUERY]);
    
    if (_expectationReqeustSearch) {
        [_expectationReqeustSearch fulfill];
    }
}

-(void)reqeustSearchFailed:(NSString*)query
{
    XCTAssert([query isEqualToString:SEARCH_QUERY]);
    
    if (_expectationReqeustSearch) {
        [_expectationReqeustSearch fulfill];
    }
}

@end
