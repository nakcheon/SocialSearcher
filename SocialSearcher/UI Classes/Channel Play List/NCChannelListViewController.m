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

@interface NCChannelListViewController()
@end

@interface NCChannelListViewController(CreateMethods)
@end

@interface NCChannelListViewController(PrivateMethods)
@end

@interface NCChannelListViewController(PrivateServerCommunications)
@end

@interface NCChannelListViewController(selectors)
@end

@interface NCChannelListViewController(IBActions)
@end

@interface NCChannelListViewController(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation NCChannelListViewController

#pragma mark - class life cycle

-(id)init
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

-(void)prepareForRelease
{
    
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


#pragma mark - operations



#pragma mark - private methods

-(BOOL)privateInitializeSetting
{
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    _defaultChannelID = [_dicInfo valueForKeyPath:@"snippet.channelId"];
    
    // reset data
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    [dataContainer.dicYoutubePlayListNextTokenInfo removeObjectForKey:_defaultChannelID];
    [dataContainer.dicYoutubePlayListResult removeObjectForKey:_defaultChannelID];
    
    [_youtubeDataManager reqeustPlayListWithChannelInfo:_defaultChannelID];
    
    return YES;
}

-(BOOL)privateInitializeUI
{
    self.title = [_dicInfo valueForKeyPath:@"snippet.title"];
    
    return YES;
}

@end
