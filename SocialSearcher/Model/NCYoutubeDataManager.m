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
        if (strongSelf.bIsFinish) {
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
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
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
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        NSArray* arrayList = [responseObject objectForKey:@"items"];
        NSString* nextToken = [responseObject objectForKey:@"nextPageToken"];
        if ([nextToken isEqualToString:@""]) {
            nextToken = nil;
        }
        
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
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
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

-(BOOL)reqeustVideoListWithPlayListInfo:(NSString*)playListID
{
    __block AFHTTPRequestOperation* _reqeustVideoListWithPlayListInfo = nil;
    if (_reqeustVideoListWithPlayListInfo) {
        [_reqeustVideoListWithPlayListInfo cancel];
    }
    _reqeustVideoListWithPlayListInfo = nil;
    
    // check saved next token
    NSString* strFullURL = nil;
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSString* savedNextToken = [dataContainer.dicYoutubeVideoListNextTokenInfo objectForKey:playListID];
    if (savedNextToken) {
        strFullURL = [NSString stringWithFormat:YOUTUBE_VIDEO_MORE_LIST, playListID, savedNextToken, DEFAULT_MAXRESULTS, GOOGLE_API_KEY];
    }
    else {
        strFullURL = [NSString stringWithFormat:YOUTUBE_VIDEO_LIST, playListID, DEFAULT_MAXRESULTS, GOOGLE_API_KEY];
    }
    strFullURL = [strFullURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // check loaded all list
    {
        NSArray* arrayOld = [dataContainer.dicYoutubeVideoListResult objectForKey:playListID];
        if (arrayOld.count > 0 && !savedNextToken) {
            [_delegate reqeustVideoListWithPlayListInfoNoData:playListID];
            return NO;
        }
    }
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strFullURL]];
    
    _reqeustVideoListWithPlayListInfo = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _reqeustVideoListWithPlayListInfo.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // success block
    void(^ completionBlock) (AFHTTPRequestOperation *operation, id responseObject);
    NCYoutubeDataManager* __weak weakSelf = self;
    completionBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        NSArray* arrayList = [responseObject objectForKey:@"items"];
        NSString* nextToken = [responseObject objectForKey:@"nextPageToken"];
        if ([nextToken isEqualToString:@""]) {
            nextToken = nil;
        }
        
        // success
        if (arrayList.count > 0) {
            DLog(@"Get reqeustPlayListWithChannelInfo Success");
            
            if (!dataContainer.dicYoutubeVideoListResult) {
                dataContainer.dicYoutubeVideoListResult = [[NSMutableDictionary alloc] init];
            }
            
            // check saved next token
            if (savedNextToken && ![savedNextToken isEqualToString:@""]) {
                NSMutableArray* arrayOld = [NSMutableArray arrayWithArray:[dataContainer.dicYoutubeVideoListResult objectForKey:playListID]];
                [arrayOld addObjectsFromArray:arrayList];
                [dataContainer.dicYoutubeVideoListResult setObject:arrayOld forKey:playListID];
            }
            else {
                [dataContainer.dicYoutubeVideoListResult setObject:arrayList forKey:playListID];
            }
            
            // save next token info
            {
                if (!dataContainer.dicYoutubeVideoListNextTokenInfo) {
                    dataContainer.dicYoutubeVideoListNextTokenInfo = [[NSMutableDictionary alloc] init];
                }
                if (nextToken && ![nextToken isEqualToString:@""]) {
                    [dataContainer.dicYoutubeVideoListNextTokenInfo setObject:nextToken forKey:playListID];
                }
                else {
                    [dataContainer.dicYoutubeVideoListNextTokenInfo removeObjectForKey:playListID];
                }
            }
            
            [strongSelf.delegate reqeustVideoListWithPlayListInfoFinished:playListID];
        }
        else {
            [strongSelf.delegate reqeustVideoListWithPlayListInfoNoData:playListID];
        }
        
        [_reqeustVideoListWithPlayListInfo cancel];
        _reqeustVideoListWithPlayListInfo = nil;
    };
    
    // fail block
    void(^ failBlock) (AFHTTPRequestOperation *operation, NSError *error);
    failBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        DLog(@"Get reqeustPlayListWithChannelInfo FAIL: %@", error.localizedDescription);
        
        [strongSelf.delegate reqeustVideoListWithPlayListInfoFailed:playListID];
        
        [_reqeustVideoListWithPlayListInfo cancel];
        _reqeustVideoListWithPlayListInfo = nil;
    };
    
    [_reqeustVideoListWithPlayListInfo setCompletionBlockWithSuccess:completionBlock
                                                             failure:failBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        [_reqeustVideoListWithPlayListInfo start];
    });
    return YES;
}

-(BOOL)reqeustVideoDetailInfo:(NSString*)videoID
{
    __block AFHTTPRequestOperation* _reqeustVideoDetailInfo = nil;
    if (_reqeustVideoDetailInfo) {
        [_reqeustVideoDetailInfo cancel];
    }
    _reqeustVideoDetailInfo = nil;
    
    // make parameters
    NSString* strFullURL = [NSString stringWithFormat:YOUTUBE_VIDEO_DETAIL, videoID, GOOGLE_API_KEY];
    strFullURL = [strFullURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strFullURL]];
    
    _reqeustVideoDetailInfo = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _reqeustVideoDetailInfo.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // success block
    void(^ completionBlock) (AFHTTPRequestOperation *operation, id responseObject);
    NCYoutubeDataManager* __weak weakSelf = self;
    completionBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        NSArray* arrayList = [responseObject objectForKey:@"items"];
        NSDictionary* dicDetail = arrayList.firstObject;
        
        // success
        if (dicDetail) {
            DLog(@"Get reqeustVideoDetailInfo Success");
            
            NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
            if (!dataContainer.dicYoutubeVideoDetailResult) {
                dataContainer.dicYoutubeVideoDetailResult = [[NSMutableDictionary alloc] init];
            }
            [dataContainer.dicYoutubeVideoDetailResult setObject:dicDetail forKey:videoID];
            [strongSelf.delegate reqeustVideoDetailInfoFinished:videoID];
        }
        else {
            [strongSelf.delegate reqeustVideoDetailInfoNoData:videoID];
        }
        
        [_reqeustVideoDetailInfo cancel];
        _reqeustVideoDetailInfo = nil;
    };
    
    // fail block
    void(^ failBlock) (AFHTTPRequestOperation *operation, NSError *error);
    failBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        DLog(@"Get reqeustVideoDetailInfo FAIL: %@", error.localizedDescription);
        
        [strongSelf.delegate reqeustVideoListWithPlayListInfoFailed:videoID];
        
        [_reqeustVideoDetailInfo cancel];
        _reqeustVideoDetailInfo = nil;
    };
    
    [_reqeustVideoDetailInfo setCompletionBlockWithSuccess:completionBlock
                                                   failure:failBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        [_reqeustVideoDetailInfo start];
    });
    return YES;
}

@end
