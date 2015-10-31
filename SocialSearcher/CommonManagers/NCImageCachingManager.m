//
//  NCImageCachingManager.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCImageCachingManager.h"
#import "NCURLManager.h"

#pragma mark - enum Definition

/******************************************************************************
 * enum Definition
 *****************************************************************************/


/******************************************************************************
 * String Definition
 *****************************************************************************/


/******************************************************************************
 * Constant Definition
 *****************************************************************************/


/******************************************************************************
 * Function Definition
 *****************************************************************************/


/******************************************************************************
 * Type Definition
 *****************************************************************************/

@interface NCImageCachingManager()
@end

@interface NCImageCachingManager(CreateMethods)
@end

@interface NCImageCachingManager(PrivateMethods)
@end

@interface NCImageCachingManager(PrivateServerCommunications)
@end

@interface NCImageCachingManager(selectors)
@end

@interface NCImageCachingManager(IBActions)
@end

@interface NCImageCachingManager(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation NCImageCachingManager

#pragma mark - class life cycle

static NCImageCachingManager* sharedInstance = nil;
+(NCImageCachingManager*)sharedInstance
{
    @synchronized(self){
        if(!sharedInstance) {
            sharedInstance = [[NCImageCachingManager alloc] init];
            [sharedInstance initialize];
        }
    }
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        DLog(@"NCImageCachingManager::INIT");
    }
    return self;
}

-(void)prepareForRelease
{
    
}

-(void)dealloc
{
    DLog(@"NCImageCachingManager::DEALLOC");
}

#pragma mark - operations

-(void)initialize
{
    // do nothing
}

-(void)addFullDataWithKey:(NSString*)key data:(NSData*)data
{
    NSString* imagePath = [NCURLManager userRawImageDataSaveFullPath:key];
    if (data) {
        [data writeToFile:imagePath atomically:YES];
        DLog(@"WRITE FILE %@", imagePath);
    }
    else {
        DLog(@"EMPTY DATA");
    }
}

-(UIImage*)getRawDataWithKey:(NSString*)key
{
    if (!key) {
        return nil;
    }
    NSString* imagePath = [NCURLManager userRawImageDataSaveFullPath:key];
    NSData* loadImageData = [NSData dataWithContentsOfFile:imagePath];
    return [UIImage imageWithData:loadImageData];
}

@end
