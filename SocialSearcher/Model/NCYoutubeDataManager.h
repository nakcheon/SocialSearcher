//
//  NCYoutubeDataManager.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/30/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NCYoutubeDataManagerDelegate <NSObject>
@optional

// reqeustguideCategoriesList
-(void)reqeustGuideCategoriesListFinished;
-(void)reqeustGuideCategoriesListNoData;
-(void)reqeustGuideCategoriesListFailed;

// reqeustPlayListWithChannelInfo
-(void)reqeustPlayListWithChannelInfoFinished:(NSString*)channelID;
-(void)reqeustPlayListWithChannelInfoNoData:(NSString*)channelID;
-(void)reqeustPlayListWithChannelInfoFailed:(NSString*)channelID;

// reqeustVideoListWithPlayListInfo
-(void)reqeustVideoListWithPlayListInfoFinished:(NSString*)playListID;
-(void)reqeustVideoListWithPlayListInfoNoData:(NSString*)playListID;
-(void)reqeustVideoListWithPlayListInfoFailed:(NSString*)playListID;

// reqeustVideoDetailInfo
-(void)reqeustVideoDetailInfoFinished:(NSString*)videoID;
-(void)reqeustVideoDetailInfoNoData:(NSString*)videoID;
-(void)reqeustVideoDetailInfoFailed:(NSString*)videoID;

@end

@interface NCYoutubeDataManager : NSObject
@property (nonatomic, weak) id<NCYoutubeDataManagerDelegate> delegate;

-(void)initialize;
-(void)prepareForRelease;

-(BOOL)reqeustGuideCategoriesList;
-(BOOL)reqeustPlayListWithChannelInfo:(NSString*)channelID;
-(BOOL)reqeustVideoListWithPlayListInfo:(NSString*)playListID;
-(BOOL)reqeustVideoDetailInfo:(NSString*)videoID;

@end
