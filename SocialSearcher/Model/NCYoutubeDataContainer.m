//
//  NCYoutubeDataContainer.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCYoutubeDataContainer.h"

#pragma mark - Implementation

@implementation NCYoutubeDataContainer

#pragma mark - class life cycle

static NCYoutubeDataContainer* sharedInstance = nil;
+(NCYoutubeDataContainer*)sharedInstance
{
    @synchronized(self){
        if(!sharedInstance) {
            sharedInstance = [[NCYoutubeDataContainer alloc] init];
        }
    }
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        DLog(@"NCYoutubeDataContainer::INIT");
    }
    return self;
}

-(void)dealloc
{
    DLog(@"NCYoutubeDataContainer::DEALLOC");
}

#pragma mark - operations

-(void)RemoveYoutubePlayList:(NSString*)channelID
{
    [_dicYoutubePlayListNextTokenInfo removeObjectForKey:channelID];
    [_dicYoutubePlayListResult removeObjectForKey:channelID];
}

-(void)RemoveYoutubeSearchResult:(NSString*)query
{
    [_dicYoutubeSearchResult removeObjectForKey:query];
    [_dicYoutubeSearchNextTokenInfo removeObjectForKey:query];
}

-(void)RemoveYoutubeVideoList:(NSString*)playListID
{
    [_dicYoutubeVideoListResult removeObjectForKey:playListID];
    [_dicYoutubeVideoListNextTokenInfo removeObjectForKey:playListID];
}


@end
