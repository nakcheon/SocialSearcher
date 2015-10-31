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

@end

@interface NCYoutubeDataManager : NSObject
@property (nonatomic, weak) id<NCYoutubeDataManagerDelegate> delegate;

-(void)initialize;
-(void)prepareForRelease;

-(BOOL)reqeustGuideCategoriesList;
-(BOOL)reqeustPlayListWithChannelInfo:(NSString*)channelID;

@end
