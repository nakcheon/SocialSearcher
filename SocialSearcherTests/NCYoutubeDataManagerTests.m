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

/******************************************************************************
 * Function Definition
 *****************************************************************************/
@interface NCYoutubeDataManagerTests : XCTestCase <NCYoutubeDataManagerDelegate>
{
    XCTestExpectation* _expectationReqeustGuideCategoriesList;
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

@end
