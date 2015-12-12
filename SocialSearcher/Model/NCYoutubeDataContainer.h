//
//  NCYoutubeDataContainer.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCYoutubeDataContainer : NSObject
@property (nonatomic, readwrite) NSDictionary* dicDataYoutubeGuideInfoResult;
@property (nonatomic, readwrite) NSDictionary* dicDataYoutubePlayListResult;
@property (nonatomic, readwrite) NSDictionary* dicDataYoutubePlayListNextTokenInfo;
@property (nonatomic, readwrite) NSDictionary* dicDataYoutubeVideoListResult;
@property (nonatomic, readwrite) NSDictionary* dicDataYoutubeVideoListNextTokenInfo;
@property (nonatomic, readwrite) NSDictionary* dicDataYoutubeVideoDetailResult;
@property (nonatomic, readwrite) NSDictionary* dicDataYoutubeSearchResult;
@property (nonatomic, readwrite) NSDictionary* dicDataYoutubeSearchNextTokenInfo;

+(NCYoutubeDataContainer*)sharedInstance;

-(void)addYoutubeGuideInfoResult:(NSArray*)arrayList forKey:(NSString*)regionCode;

-(void)addYoutubePlayListResult:(NSArray*)arrayList forKey:(NSString*)channelID;
-(void)addYoutubePlayListNextTokenInfo:(NSString*)nextToken forKey:(NSString*)channelID;
-(void)removeYoutubePlayListNextTokenInfoForKey:(NSString*)channelID;

-(void)addYoutubeVideoListResult:(NSArray*)arrayList forKey:(NSString*)playListID;
-(void)addYoutubeVideoListNextTokenInfo:(NSString*)nextToken forKey:(NSString*)playListID;
-(void)removeYoutubeVideoListNextTokenInfoForKey:(NSString*)playListID;

-(void)addYoutubeVideoDetailResult:(NSDictionary*)dicDetail forKey:(NSString*)videoID;

-(void)addYoutubeSearchResult:(NSArray*)arrayList forKey:(NSString*)query;
-(void)addYoutubeSearchNextTokenInfo:(NSString*)nextToken forKey:(NSString*)query;
-(void)removeYoutubeSearchNextTokenInfoForKey:(NSString*)query;

-(void)RemoveYoutubePlayList:(NSString*)channelID;
-(void)RemoveYoutubeSearchResult:(NSString*)query;
-(void)RemoveYoutubeVideoList:(NSString*)playListID;

@end
