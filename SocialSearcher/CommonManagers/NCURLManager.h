//
//  NCURLManager.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCURLManager : NSObject

// basic path
+(NSString*)libraryCachesPath;
+(void)checkPath:(NSString*)path;

// User Data Caching path
+(NSString*)userImageSavePath;
+(NSString*)userRawImageDataSaveFullPath:(NSString*)key;

// key
+(NSString*)rawImageDataKey:(NSString*)imageUrl;

@end
