//
//  NCChannelListViewController.m
//  SocialSearcher
//
//  Created by NakCheonJung on 11/1/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCChannelListViewController.h"
#import "NCYoutubeDataContainer.h"
#import "NCVideoListViewController.h"

#pragma mark - Implementation

@implementation NCChannelListViewController

#pragma mark - class life cycle

-(instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"NCChannelListViewController::INIT");
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)dealloc
{
    NSLog(@"NCChannelListViewController::DEALLOC");
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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark - private methods

-(BOOL)privateInitializeSetting
{
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    _defaultChannelID = [_dicInfo valueForKeyPath:@"snippet.channelId"];
    
    // reset data
    [[NCYoutubeDataContainer sharedInstance] RemoveYoutubePlayList:_defaultChannelID];
    
    // request
    [_youtubeDataManager reqeustPlayListWithChannelInfo:_defaultChannelID];
    
    return YES;
}

-(BOOL)privateInitializeUI
{
    self.title = [_dicInfo valueForKeyPath:@"snippet.title"];
    
    return YES;
}

@end
