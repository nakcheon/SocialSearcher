//
//  NCSearchViewControlerTests.m
//  SocialSearcher
//
//  Created by NakCheonJung on 11/1/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NCSearchViewControlerTests : XCTestCase

@end

@implementation NCSearchViewControlerTests

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
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"Recommanded Channels"].buttons[@"icon search"] tap];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeRight;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortraitUpsideDown;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    XCUIElement *searchSearchField = app.searchFields[@"Search"];
    [searchSearchField typeText:@"List"];
    
    XCUIElement *searchButton = app.buttons[@"Search"];
    [searchButton tap];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeRight;
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortraitUpsideDown;
}

-(void)testSearchAndView
{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [app.navigationBars[@"Recommanded Channels"].buttons[@"icon search"] tap];
    [app.searchFields[@"Search"] typeText:@"Fitness"];
    
    XCUIApplication *app2 = app;
    [app2.buttons[@"Search"] tap];
    [[app2.cells containingType:XCUIElementTypeStaticText identifier:@"02:33"].element tap];
    [app2.buttons[@"Watch Female Fitness Motivation - \"Push Yourself\" 2015"] tap];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    [app.buttons[@"icon cross white"] tap];
}

-(void)testSearchAndAnotherSearch
{
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"Recommanded Channels"].buttons[@"icon search"] tap];
    
    XCUIElement *searchSearchField = app.searchFields[@"Search"];
    [searchSearchField typeText:@"List"];
    
    XCUIElement *searchButton = app.buttons[@"Search"];
    [searchButton tap];
    
    XCUIElement *topTracksPopMusicCell = [app.cells containingType:XCUIElementTypeStaticText identifier:@"Top Tracks - Pop Music"].element;
    [topTracksPopMusicCell tap];
    
    XCUIElement *searchVideosButton = app.navigationBars[@"Top Tracks - Pop Music"].buttons[@"Search Videos"];
    [searchVideosButton tap];
    [topTracksPopMusicCell tap];
    [searchVideosButton tap];
}

@end
