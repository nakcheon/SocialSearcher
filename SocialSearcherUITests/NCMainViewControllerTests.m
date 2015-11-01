//
//  NCMainViewControllerTests.m
//  SocialSearcher
//
//  Created by NakCheonJung on 11/1/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NCMainViewControllerTests : XCTestCase

@end

@implementation NCMainViewControllerTests

-(void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

-(void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testLandScape
{
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeRight;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortraitUpsideDown;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeRight;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
}

-(void)testShowingSearchView
{
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    XCUIElement *iconSearchButton = app.navigationBars[@"Recommanded Channels"].buttons[@"icon search"];
    [iconSearchButton tap];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    XCUIElement *element = [[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1];
    [element tap];
    
}

-(void)testShowingVideoListView
{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *collectionViewsQuery = app.collectionViews;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [[[[collectionViewsQuery childrenMatchingType:XCUIElementTypeCell] matchingIdentifier:@"NCChannelItemCell"] elementBoundByIndex:1] tap];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
}

-(void)testPlayVideo
{
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [[[[app.collectionViews childrenMatchingType:XCUIElementTypeCell] matchingIdentifier:@"NCChannelItemCell"] elementBoundByIndex:5] tap];

    // video1
    XCUIElementQuery *tablesQuery = app.tables;
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"00:31"].element tap];
    
    XCUIApplication *app2 = app;
    [app2.buttons[@"Watch #IAmAWitness Animated Video | Bullying Prevention | Ad Council"] tap];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    XCUIElement *iconCrossWhiteButton = app.buttons[@"icon cross white"];
    
    // viode 2
    [iconCrossWhiteButton tap];
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"EMOJI MAKEUP TUTORIAL // Grace Helbig"].element tap];
    [app2.buttons[@"Watch EMOJI MAKEUP TUTORIAL // Grace Helbig"] tap];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    [iconCrossWhiteButton tap];
}

@end
