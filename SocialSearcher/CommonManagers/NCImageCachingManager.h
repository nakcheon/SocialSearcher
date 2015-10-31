//
//  NCImageCachingManager.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCImageCachingManager : NSObject

#pragma mark - class life cycle

+(NCImageCachingManager*)sharedInstance;
-(void)initialize;
-(void)prepareForRelease;

#pragma mark - operations

-(void)addFullDataWithKey:(NSString*)key data:(NSData*)data;
-(UIImage*)getRawDataWithKey:(NSString*)key;

@end
