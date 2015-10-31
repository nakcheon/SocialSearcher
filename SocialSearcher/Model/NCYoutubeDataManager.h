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
-(void)reqeustguideCategoriesListFinished;
-(void)reqeustguideCategoriesListNoData;
-(void)reqeustguideCategoriesListFailed;
@end

@interface NCYoutubeDataManager : NSObject
@property (nonatomic, weak) id<NCYoutubeDataManagerDelegate> delegate;

-(void)initialize;
-(void)prepareForRelease;

-(BOOL)reqeustGuideCategoriesList;

@end
