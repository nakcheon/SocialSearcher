//
//  NCYoutubeDataManager.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/30/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCYoutubeDataManager.h"
#import "RequestDefine.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <NSTimeZone-CountryCode/NSTimeZone+CountryCode.h>
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

@interface NCYoutubeDataManager()
{
    BOOL _bIsFinish;
}
@end

@interface NCYoutubeDataManager(CreateMethods)
@end

@interface NCYoutubeDataManager(PrivateMethods)
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
@end

@interface NCYoutubeDataManager(PrivateServerCommunications)
@end

@interface NCYoutubeDataManager(selectors)
@end

@interface NCYoutubeDataManager(IBActions)
@end

@interface NCYoutubeDataManager(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation NCYoutubeDataManager

#pragma mark - class life cycle

-(id)init
{
    self = [super init];
    if (self) {
        DLog(@"NCYoutubeDataManager::INIT");
    }
    return self;
}

-(void)prepareForRelease
{
    _bIsFinish = YES;
}

-(void)dealloc
{
    DLog(@"NCYoutubeDataManager::DEALLOC");
}

#pragma mark - operations

-(void)initialize
{
    [self privateInitializeSetting];
    [self privateInitializeUI];
}

#pragma mark - private methods

-(BOOL)privateInitializeSetting
{
    return YES;
}

-(BOOL)privateInitializeUI
{
    return YES;
}

#pragma mark - request operations


-(BOOL)reqeustGuideCategoriesList
{
    __block AFHTTPRequestOperation* _reqeustGuideCategoriesList = nil;
    if (_reqeustGuideCategoriesList) {
        [_reqeustGuideCategoriesList cancel];
    }
    _reqeustGuideCategoriesList = nil;
    
    // make parameters
    NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"ko"]) {
        language = LANGUAGE_CODE_KOREA;
    }
    else {
        language = LANGUAGE_CODE_ENGLISH;
    }
    NSString* regionCode = [NSTimeZone countryCodeFromLocalizedName];
    
    NSString* strFullURL = [NSString stringWithFormat:YOUTUBE_GUIDED_CHANNEL_LIST, language, regionCode, GOOGLE_API_KEY];
    strFullURL = [strFullURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strFullURL]];
    
    _reqeustGuideCategoriesList = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _reqeustGuideCategoriesList.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // success block
    void(^ completionBlock) (AFHTTPRequestOperation *operation, id responseObject);
    NCYoutubeDataManager* __weak weakSelf = self;
    completionBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (_bIsFinish) {
            return;
        }
        NSArray* arrayList = [responseObject objectForKey:@"items"];
        
        // success
        if (arrayList.count > 0) {
            DLog(@"Get reqeustGuideCategoriesList Success");
            
            NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
            if (!dataContainer.dicYoutubeGuideInfoResult) {
                dataContainer.dicYoutubeGuideInfoResult = [[NSMutableDictionary alloc] init];
            }
            [dataContainer.dicYoutubeGuideInfoResult setObject:arrayList forKey:regionCode];
            [strongSelf.delegate reqeustguideCategoriesListFinished];
        }
        else {
            [strongSelf.delegate reqeustguideCategoriesListNoData];
        }
        
        [_reqeustGuideCategoriesList cancel];
        _reqeustGuideCategoriesList = nil;
        strongSelf = nil;
    };
    
    // fail block
    void(^ failBlock) (AFHTTPRequestOperation *operation, NSError *error);
    failBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_bIsFinish) {
            return;
        }
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        DLog(@"Get reqeustGuideCategoriesList FAIL: %@", error.localizedDescription);
        
        [strongSelf.delegate reqeustguideCategoriesListFailed];
        
        [_reqeustGuideCategoriesList cancel];
        _reqeustGuideCategoriesList = nil;
        strongSelf = nil;
    };
    
    [_reqeustGuideCategoriesList setCompletionBlockWithSuccess:completionBlock
                                                       failure:failBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_bIsFinish) {
            return;
        }
        [_reqeustGuideCategoriesList start];
    });
    return YES;
}

@end
