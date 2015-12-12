//
//  NCYoutubeDataContainer.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCYoutubeDataContainer : NSObject
@property (nonatomic, strong) NSMutableDictionary* dicYoutubeGuideInfoResult;
@property (nonatomic, strong) NSMutableDictionary* dicYoutubePlayListResult;
@property (nonatomic, strong) NSMutableDictionary* dicYoutubePlayListNextTokenInfo;
@property (nonatomic, strong) NSMutableDictionary* dicYoutubeVideoListResult;
@property (nonatomic, strong) NSMutableDictionary* dicYoutubeVideoListNextTokenInfo;
@property (nonatomic, strong) NSMutableDictionary* dicYoutubeVideoDetailResult;
@property (nonatomic, strong) NSMutableDictionary* dicYoutubeSearchResult;
@property (nonatomic, strong) NSMutableDictionary* dicYoutubeSearchNextTokenInfo;

+(NCYoutubeDataContainer*)sharedInstance;

-(void)RemoveYoutubePlayList:(NSString*)channelID;
-(void)RemoveYoutubeSearchResult:(NSString*)query;
-(void)RemoveYoutubeVideoList:(NSString*)playListID;

@end
