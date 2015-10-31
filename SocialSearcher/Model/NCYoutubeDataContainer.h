//
//  NCYoutubeDataContainer.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCYoutubeDataContainer : NSObject
@property (nonatomic, retain) NSMutableDictionary* dicYoutubeGuideInfoResult;
@property (nonatomic, retain) NSMutableDictionary* dicYoutubePlayListResult;
@property (nonatomic, retain) NSMutableDictionary* dicYoutubePlayListNextTokenInfo;

+(NCYoutubeDataContainer*)sharedInstance;
-(void)initialize;
-(void)prepareForRelease;

@end
