//
//  NCVideoListViewControllerTests.m
//  SocialSearcher
//
//  Created by NakCheonJung on 11/1/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NCVideoListViewControllerTests : XCTestCase

@end

@implementation NCVideoListViewControllerTests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testLandScape
{
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [[[[[[XCUIApplication alloc] init].collectionViews childrenMatchingType:XCUIElementTypeCell] matchingIdentifier:@"NCChannelItemCell"] elementBoundByIndex:2] tap];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeRight;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortraitUpsideDown;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortraitUpsideDown;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeRight;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
}

-(void)testLoadingMore
{
    // TODO: need to chane the vale of "DEFAULT_MAXRESULTS" to 10
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    // main view
    [[[[app.collectionViews childrenMatchingType:XCUIElementTypeCell] matchingIdentifier:@"NCChannelItemCell"] elementBoundByIndex:3] tap];
    
    // video list view
    XCUIElementQuery *tablesQuery = app.tables;
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"02:52"].element swipeUp];
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"00:54"].element swipeUp];
    
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"00:54"].element swipeDown];
}

-(void)testVideoPlay
{
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    // main view
    [[[[app.collectionViews childrenMatchingType:XCUIElementTypeCell] matchingIdentifier:@"NCChannelItemCell"] elementBoundByIndex:3] tap];
    
    // video list view
    [[app.tables.cells containingType:XCUIElementTypeStaticText identifier:@"06:36"].element tap];
    [app.buttons[@"Watch Sadness Tutorial from Inside Out! Makeup, Wig & DIY Costume for Halloween"] tap];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    [app.buttons[@"icon cross white"] tap];
    
}

@end
