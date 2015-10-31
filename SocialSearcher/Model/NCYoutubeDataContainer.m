//
//  NCYoutubeDataContainer.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCYoutubeDataContainer.h"

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

@interface NCYoutubeDataContainer()
@end

@interface NCYoutubeDataContainer(CreateMethods)
@end

@interface NCYoutubeDataContainer(PrivateMethods)
@end

@interface NCYoutubeDataContainer(PrivateServerCommunications)
@end

@interface NCYoutubeDataContainer(selectors)
@end

@interface NCYoutubeDataContainer(IBActions)
@end

@interface NCYoutubeDataContainer(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation NCYoutubeDataContainer

#pragma mark - class life cycle

static NCYoutubeDataContainer* sharedInstance = nil;
+(NCYoutubeDataContainer*)sharedInstance
{
    @synchronized(self){
        if(!sharedInstance) {
            sharedInstance = [[NCYoutubeDataContainer alloc] init];
            [sharedInstance initialize];
        }
    }
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        DLog(@"NCYoutubeDataContainer::INIT");
    }
    return self;
}

-(void)prepareForRelease
{
    
}

-(void)dealloc
{
    DLog(@"NCYoutubeDataContainer::DEALLOC");
}

#pragma mark - operations

-(void)initialize
{
    // do nothing
}

@end
