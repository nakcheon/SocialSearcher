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
// flags
@property (assign, nonatomic) BOOL bIsFinish;
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
            [strongSelf.delegate reqeustGuideCategoriesListFinished];
        }
        else {
            [strongSelf.delegate reqeustGuideCategoriesListNoData];
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
        
        [strongSelf.delegate reqeustGuideCategoriesListFailed];
        
        [_reqeustGuideCategoriesList cancel];
        _reqeustGuideCategoriesList = nil;
        strongSelf = nil;
    };
    
    [_reqeustGuideCategoriesList setCompletionBlockWithSuccess:completionBlock
                                                       failure:failBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        [_reqeustGuideCategoriesList start];
    });
    return YES;
}

-(BOOL)reqeustPlayListWithChannelInfo:(NSString*)channelID
{
    __block AFHTTPRequestOperation* _reqeustPlayListWithChannelInfo = nil;
    if (_reqeustPlayListWithChannelInfo) {
        [_reqeustPlayListWithChannelInfo cancel];
    }
    _reqeustPlayListWithChannelInfo = nil;
    
    // make parameters
    NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"ko"]) {
        language = LANGUAGE_CODE_KOREA;
    }
    else {
        language = LANGUAGE_CODE_ENGLISH;
    }
    
    // check saved next token
    NSString* strFullURL = nil;
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSString* savedNextToken = [dataContainer.dicYoutubePlayListNextTokenInfo objectForKey:channelID];
    if (savedNextToken) {
        strFullURL = [NSString stringWithFormat:YOUTUBE_PLAY_MORE_LIST, language, channelID, DEFAULT_MAXRESULTS, savedNextToken, GOOGLE_API_KEY];
    }
    else {
        strFullURL = [NSString stringWithFormat:YOUTUBE_PLAY_LIST, language, channelID, DEFAULT_MAXRESULTS, GOOGLE_API_KEY];
    }
    strFullURL = [strFullURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // check loaded all list
    {
        NSArray* arrayOld = [dataContainer.dicYoutubePlayListResult objectForKey:channelID];
        if (arrayOld.count > 0 && !savedNextToken) {
            [_delegate reqeustPlayListWithChannelInfoNoData:channelID];
            return NO;
        }
    }
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strFullURL]];
    
    _reqeustPlayListWithChannelInfo = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _reqeustPlayListWithChannelInfo.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // success block
    void(^ completionBlock) (AFHTTPRequestOperation *operation, id responseObject);
    NCYoutubeDataManager* __weak weakSelf = self;
    completionBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_bIsFinish) {
            return;
        }
        NSArray* arrayList = [responseObject objectForKey:@"items"];
        NSString* nextToken = [responseObject objectForKey:@"nextPageToken"];
        if ([nextToken isEqualToString:@""]) {
            nextToken = nil;
        }
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        
        // succss
        if (arrayList.count > 0) {
            DLog(@"Get reqeustPlayListWithChannelInfo Success");
            
            if (!dataContainer.dicYoutubePlayListResult) {
                dataContainer.dicYoutubePlayListResult = [[NSMutableDictionary alloc] init];
            }
            
            // check saved next token
            if (savedNextToken && ![savedNextToken isEqualToString:@""]) {
                NSMutableArray* arrayOld = [NSMutableArray arrayWithArray:[dataContainer.dicYoutubePlayListResult objectForKey:channelID]];
                [arrayOld addObjectsFromArray:arrayList];
                [dataContainer.dicYoutubePlayListResult setObject:arrayOld forKey:channelID];
            }
            else {
                [dataContainer.dicYoutubePlayListResult setObject:arrayList forKey:channelID];
            }
            
            // save next token info
            {
                if (!dataContainer.dicYoutubePlayListNextTokenInfo) {
                    dataContainer.dicYoutubePlayListNextTokenInfo = [[NSMutableDictionary alloc] init];
                }
                if (nextToken && ![nextToken isEqualToString:@""]) {
                    [dataContainer.dicYoutubePlayListNextTokenInfo setObject:nextToken forKey:channelID];
                }
                else {
                    [dataContainer.dicYoutubePlayListNextTokenInfo removeObjectForKey:channelID];
                }
            }
            
            [strongSelf.delegate reqeustPlayListWithChannelInfoFinished:channelID];
        }
        else {
            [strongSelf.delegate reqeustPlayListWithChannelInfoNoData:channelID];
        }
        
        [_reqeustPlayListWithChannelInfo cancel];
        _reqeustPlayListWithChannelInfo = nil;
        strongSelf = nil;
    };
    
    // fail block
    void(^ failBlock) (AFHTTPRequestOperation *operation, NSError *error);
    failBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_bIsFinish) {
            return;
        }
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        DLog(@"Get reqeustPlayListWithChannelInfo FAIL: %@", error.localizedDescription);
        
        [strongSelf.delegate reqeustPlayListWithChannelInfoFailed:channelID];
        
        [_reqeustPlayListWithChannelInfo cancel];
        _reqeustPlayListWithChannelInfo = nil;
        strongSelf = nil;
    };
    
    [_reqeustPlayListWithChannelInfo setCompletionBlockWithSuccess:completionBlock
                                                           failure:failBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        [_reqeustPlayListWithChannelInfo start];
    });
    return YES;
}

@end
