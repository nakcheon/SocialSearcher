//
//  NCYoutubeDataContainer.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCYoutubeDataContainer.h"

#pragma mark - Definition

@interface NCYoutubeDataContainer ()
@property (atomic, strong) NSMutableDictionary* dicYoutubeGuideInfoResult;
@property (atomic, strong) NSMutableDictionary* dicYoutubePlayListResult;
@property (atomic, strong) NSMutableDictionary* dicYoutubePlayListNextTokenInfo;
@property (atomic, strong) NSMutableDictionary* dicYoutubeVideoListResult;
@property (atomic, strong) NSMutableDictionary* dicYoutubeVideoListNextTokenInfo;
@property (atomic, strong) NSMutableDictionary* dicYoutubeVideoDetailResult;
@property (atomic, strong) NSMutableDictionary* dicYoutubeSearchResult;
@property (atomic, strong) NSMutableDictionary* dicYoutubeSearchNextTokenInfo;
@end

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

-(instancetype)init
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

-(void)addYoutubeGuideInfoResult:(NSArray*)arrayList forKey:(NSString*)regionCode
{
    _dicYoutubeGuideInfoResult[regionCode] = arrayList;
    _dicDataYoutubeGuideInfoResult = [[NSDictionary alloc] initWithDictionary:_dicYoutubeGuideInfoResult];
}

-(void)addYoutubePlayListResult:(NSArray*)arrayList forKey:(NSString*)channelID
{
    _dicYoutubePlayListResult[channelID] = arrayList;
    _dicDataYoutubePlayListResult = [[NSDictionary alloc] initWithDictionary:_dicYoutubePlayListResult];
}

-(void)addYoutubePlayListNextTokenInfo:(NSString*)nextToken forKey:(NSString*)channelID
{
    _dicYoutubePlayListNextTokenInfo[channelID] = nextToken;
    _dicDataYoutubePlayListNextTokenInfo = [[NSDictionary alloc] initWithDictionary:_dicYoutubePlayListNextTokenInfo];
}

-(void)removeYoutubePlayListNextTokenInfoForKey:(NSString*)channelID
{
    [_dicYoutubePlayListNextTokenInfo removeObjectForKey:channelID];
    _dicDataYoutubePlayListNextTokenInfo = [[NSDictionary alloc] initWithDictionary:_dicYoutubePlayListNextTokenInfo];
}

-(void)addYoutubeVideoListResult:(NSArray*)arrayList forKey:(NSString*)playListID
{
    _dicYoutubeVideoListResult[playListID] = arrayList;
    _dicDataYoutubeVideoListResult = [[NSDictionary alloc] initWithDictionary:_dicYoutubeVideoListResult];
}

-(void)addYoutubeVideoListNextTokenInfo:(NSString*)nextToken forKey:(NSString*)playListID
{
    _dicYoutubeVideoListNextTokenInfo[playListID] = nextToken;
    _dicDataYoutubeVideoListNextTokenInfo = [[NSDictionary alloc] initWithDictionary:_dicYoutubeVideoListNextTokenInfo];
}

-(void)removeYoutubeVideoListNextTokenInfoForKey:(NSString*)playListID
{
    [_dicYoutubeVideoListNextTokenInfo removeObjectForKey:playListID];
    _dicDataYoutubeVideoListNextTokenInfo = [[NSDictionary alloc] initWithDictionary:_dicYoutubeVideoListNextTokenInfo];
}

-(void)addYoutubeVideoDetailResult:(NSDictionary*)dicDetail forKey:(NSString*)videoID
{
    _dicYoutubeVideoDetailResult[videoID] = dicDetail;
    _dicDataYoutubeVideoDetailResult = [[NSDictionary alloc] initWithDictionary:_dicYoutubeVideoDetailResult];
}

-(void)addYoutubeSearchResult:(NSArray*)arrayList forKey:(NSString*)query
{
    _dicYoutubeSearchResult[query] = arrayList;
    _dicDataYoutubeSearchResult = [[NSDictionary alloc] initWithDictionary:_dicYoutubeSearchResult];
}

-(void)addYoutubeSearchNextTokenInfo:(NSString*)nextToken forKey:(NSString*)query
{
    _dicYoutubeSearchNextTokenInfo[query] = nextToken;
    _dicDataYoutubeSearchNextTokenInfo = [[NSDictionary alloc] initWithDictionary:_dicYoutubeSearchNextTokenInfo];
}

-(void)removeYoutubeSearchNextTokenInfoForKey:(NSString*)query
{
    [_dicYoutubeSearchNextTokenInfo removeObjectForKey:query];
    _dicDataYoutubeSearchNextTokenInfo = [[NSDictionary alloc] initWithDictionary:_dicYoutubeSearchNextTokenInfo];
}

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

#pragma mark getter/setter

-(void)setDicDataYoutubeGuideInfoResult:(NSDictionary*)dicDataYoutubeGuideInfoResult
{
    _dicYoutubeGuideInfoResult = [[NSMutableDictionary alloc] initWithDictionary:dicDataYoutubeGuideInfoResult];
    _dicDataYoutubeGuideInfoResult = [[NSDictionary alloc] initWithDictionary:dicDataYoutubeGuideInfoResult];
}

-(void)setDicDataYoutubePlayListResult:(NSDictionary*)dicDataYoutubePlayListResult
{
    _dicYoutubePlayListResult = [[NSMutableDictionary alloc] initWithDictionary:dicDataYoutubePlayListResult];
    _dicDataYoutubePlayListResult = [[NSDictionary alloc] initWithDictionary:dicDataYoutubePlayListResult];
}

-(void)setDicDataYoutubePlayListNextTokenInfo:(NSDictionary*)dicDataYoutubePlayListNextTokenInfo
{
    _dicYoutubePlayListNextTokenInfo = [[NSMutableDictionary alloc] initWithDictionary:dicDataYoutubePlayListNextTokenInfo];
    _dicDataYoutubePlayListNextTokenInfo = [[NSDictionary alloc] initWithDictionary:dicDataYoutubePlayListNextTokenInfo];
}

-(void)setDicDataYoutubeVideoListResult:(NSDictionary*)dicDataYoutubeVideoListResult
{
    _dicYoutubeVideoListResult = [[NSMutableDictionary alloc] initWithDictionary:dicDataYoutubeVideoListResult];
    _dicDataYoutubeVideoListResult = [[NSDictionary alloc] initWithDictionary:dicDataYoutubeVideoListResult];
}

-(void)setDicDataYoutubeVideoListNextTokenInfo:(NSDictionary*)dicDataYoutubeVideoListNextTokenInfo
{
    _dicYoutubeVideoListNextTokenInfo = [[NSMutableDictionary alloc] initWithDictionary:dicDataYoutubeVideoListNextTokenInfo];
    _dicDataYoutubeVideoListNextTokenInfo = [[NSDictionary alloc] initWithDictionary:dicDataYoutubeVideoListNextTokenInfo];
}

-(void)setDicDataYoutubeVideoDetailResult:(NSDictionary*)dicDataYoutubeVideoDetailResult
{
    _dicYoutubeVideoDetailResult = [[NSMutableDictionary alloc] initWithDictionary:dicDataYoutubeVideoDetailResult];
    _dicDataYoutubeVideoDetailResult = [[NSDictionary alloc] initWithDictionary:dicDataYoutubeVideoDetailResult];
}

-(void)setDicDataYoutubeSearchResult:(NSDictionary*)dicDataYoutubeSearchResult
{
    _dicYoutubeSearchResult = [[NSMutableDictionary alloc] initWithDictionary:dicDataYoutubeSearchResult];
    _dicDataYoutubeSearchResult = [[NSDictionary alloc] initWithDictionary:dicDataYoutubeSearchResult];
}

-(void)setDicDataYoutubeSearchNextTokenInfo:(NSDictionary*)dicDataYoutubeSearchNextTokenInfo
{
    _dicYoutubeSearchNextTokenInfo = [[NSMutableDictionary alloc] initWithDictionary:dicDataYoutubeSearchNextTokenInfo];
    _dicDataYoutubeSearchNextTokenInfo = [[NSDictionary alloc] initWithDictionary:dicDataYoutubeSearchNextTokenInfo];
}


@end
