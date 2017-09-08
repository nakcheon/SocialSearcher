//
//  NCYoutubeDataManager.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/30/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCYoutubeDataManager.h"
#import "RequestDefine.h"
#import <AFNetworking/AFNetworking.h>
#import <NSTimeZone_CountryCode/NSTimeZone-CountryCode-umbrella.h>
#import "NCYoutubeDataContainer.h"

#pragma mark - Definition

@interface NCYoutubeDataManager()
// flags
@property BOOL bIsFinish;
@end

#pragma mark - Implementation

@implementation NCYoutubeDataManager

#pragma mark - class life cycle

-(instancetype)init
{
    self = [super init];
    if (self) {
        DLog(@"NCYoutubeDataManager::INIT");
    }
    return self;
}

-(void)dealloc
{
    DLog(@"NCYoutubeDataManager::DEALLOC");
    _bIsFinish = YES;
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
    NSString* language = [NSLocale preferredLanguages][0];
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
        NSArray* arrayList = responseObject[@"items"];
        
        // success
        if (arrayList.count > 0) {
            DLog(@"Get reqeustGuideCategoriesList Success");
            
            NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
            if (!dataContainer.dicDataYoutubeGuideInfoResult) {
                dataContainer.dicDataYoutubeGuideInfoResult = [[NSMutableDictionary alloc] init];
            }
            [dataContainer addYoutubeGuideInfoResult:arrayList forKey:regionCode];
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
    NSString* language = [NSLocale preferredLanguages][0];
    if ([language isEqualToString:@"ko"]) {
        language = LANGUAGE_CODE_KOREA;
    }
    else {
        language = LANGUAGE_CODE_ENGLISH;
    }
    
    // check saved next token
    NSString* strFullURL = nil;
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSString* savedNextToken = (dataContainer.dicDataYoutubePlayListNextTokenInfo)[channelID];
    if (savedNextToken) {
        strFullURL = [NSString stringWithFormat:YOUTUBE_PLAY_MORE_LIST, language, channelID, DEFAULT_MAXRESULTS, savedNextToken, GOOGLE_API_KEY];
    }
    else {
        strFullURL = [NSString stringWithFormat:YOUTUBE_PLAY_LIST, language, channelID, DEFAULT_MAXRESULTS, GOOGLE_API_KEY];
    }
    strFullURL = [strFullURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // check loaded all list
    {
        NSArray* arrayOld = (dataContainer.dicDataYoutubePlayListResult)[channelID];
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
        NSArray* arrayList = responseObject[@"items"];
        NSString* nextToken = responseObject[@"nextPageToken"];
        if ([nextToken isEqualToString:@""]) {
            nextToken = nil;
        }
        
        // succss
        if (arrayList.count > 0) {
            DLog(@"Get reqeustPlayListWithChannelInfo Success");
            
            if (!dataContainer.dicDataYoutubePlayListResult) {
                dataContainer.dicDataYoutubePlayListResult = [[NSMutableDictionary alloc] init];
            }
            
            // check saved next token
            if (savedNextToken && ![savedNextToken isEqualToString:@""]) {
                NSMutableArray* arrayOld = [NSMutableArray arrayWithArray:(dataContainer.dicDataYoutubePlayListResult)[channelID]];
                [arrayOld addObjectsFromArray:arrayList];
                [dataContainer addYoutubePlayListResult:arrayOld forKey:channelID];
            }
            else {
                [dataContainer addYoutubePlayListResult:arrayList forKey:channelID];
            }
            
            // save next token info
            {
                if (!dataContainer.dicDataYoutubePlayListNextTokenInfo) {
                    dataContainer.dicDataYoutubePlayListNextTokenInfo = [[NSMutableDictionary alloc] init];
                }
                if (nextToken && ![nextToken isEqualToString:@""]) {
                    [dataContainer addYoutubePlayListNextTokenInfo:nextToken forKey:channelID];
                }
                else {
                    [dataContainer removeYoutubePlayListNextTokenInfoForKey:channelID];
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
    NSString* savedNextToken = (dataContainer.dicDataYoutubeVideoListNextTokenInfo)[playListID];
    if (savedNextToken) {
        strFullURL = [NSString stringWithFormat:YOUTUBE_VIDEO_MORE_LIST, playListID, DEFAULT_MAXRESULTS, savedNextToken, GOOGLE_API_KEY];
    }
    else {
        strFullURL = [NSString stringWithFormat:YOUTUBE_VIDEO_LIST, playListID, DEFAULT_MAXRESULTS, GOOGLE_API_KEY];
    }
    strFullURL = [strFullURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // check loaded all list
    {
        NSArray* arrayOld = (dataContainer.dicDataYoutubeVideoListResult)[playListID];
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
        NSArray* arrayList = responseObject[@"items"];
        NSString* nextToken = responseObject[@"nextPageToken"];
        if ([nextToken isEqualToString:@""]) {
            nextToken = nil;
        }
        
        // success
        if (arrayList.count > 0) {
            DLog(@"Get reqeustPlayListWithChannelInfo Success");
            
            if (!dataContainer.dicDataYoutubeVideoListResult) {
                dataContainer.dicDataYoutubeVideoListResult = [[NSMutableDictionary alloc] init];
            }
            
            // check saved next token
            if (savedNextToken && ![savedNextToken isEqualToString:@""]) {
                NSMutableArray* arrayOld = [NSMutableArray arrayWithArray:(dataContainer.dicDataYoutubeVideoListResult)[playListID]];
                [arrayOld addObjectsFromArray:arrayList];
                [dataContainer addYoutubeVideoListResult:arrayOld forKey:playListID];
            }
            else {
                [dataContainer addYoutubeVideoListResult:arrayList forKey:playListID];
            }
            
            // save next token info
            {
                if (!dataContainer.dicDataYoutubeVideoListNextTokenInfo) {
                    dataContainer.dicDataYoutubeVideoListNextTokenInfo = [[NSMutableDictionary alloc] init];
                }
                if (nextToken && ![nextToken isEqualToString:@""]) {
                    [dataContainer addYoutubeVideoListNextTokenInfo:nextToken forKey:playListID];
                }
                else {
                    [dataContainer removeYoutubeVideoListNextTokenInfoForKey:playListID];
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
        NSArray* arrayList = responseObject[@"items"];
        NSDictionary* dicDetail = arrayList.firstObject;
        
        // success
        if (dicDetail) {
            DLog(@"Get reqeustVideoDetailInfo Success");
            
            NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
            if (!dataContainer.dicDataYoutubeVideoDetailResult) {
                dataContainer.dicDataYoutubeVideoDetailResult = [[NSMutableDictionary alloc] init];
            }
            [dataContainer addYoutubeVideoDetailResult:dicDetail forKey:videoID];
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

-(BOOL)reqeustSearch:(NSString*)query
{
    __block AFHTTPRequestOperation* _reqeustSearch = nil;
    if (_reqeustSearch) {
        [_reqeustSearch cancel];
    }
    _reqeustSearch = nil;
    
    // check saved next token
    NSString* strFullURL = nil;
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSString* savedNextToken = (dataContainer.dicDataYoutubeSearchNextTokenInfo)[query];
    if (savedNextToken) {
        strFullURL = [NSString stringWithFormat:YOUTUBE_SEARCH_MORE_LIST, query, DEFAULT_MAXRESULTS, savedNextToken, GOOGLE_API_KEY];
    }
    else {
        strFullURL = [NSString stringWithFormat:YOUTUBE_SEARCH, query, DEFAULT_MAXRESULTS, GOOGLE_API_KEY];
    }
    strFullURL = [strFullURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // check loaded all list
    {
        NSArray* arrayOld = (dataContainer.dicDataYoutubeSearchResult)[query];
        if (arrayOld.count > 0 && !savedNextToken) {
            [_delegate reqeustVideoListWithPlayListInfoNoData:query];
            return NO;
        }
    }
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strFullURL]];
    
    _reqeustSearch = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _reqeustSearch.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // success block
    void(^ completionBlock) (AFHTTPRequestOperation *operation, id responseObject);
    NCYoutubeDataManager* __weak weakSelf = self;
    completionBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        NSArray* arrayList = responseObject[@"items"];
        NSString* nextToken = responseObject[@"nextPageToken"];
        if ([nextToken isEqualToString:@""]) {
            nextToken = nil;
        }
        
        // success
        if (arrayList.count > 0) {
            DLog(@"Get reqeustSearch Success");
            
            if (!dataContainer.dicDataYoutubeSearchResult) {
                dataContainer.dicDataYoutubeSearchResult = [[NSMutableDictionary alloc] init];
            }
            
            // check saved next token
            if (savedNextToken && ![savedNextToken isEqualToString:@""]) {
                NSMutableArray* arrayOld = [NSMutableArray arrayWithArray:(dataContainer.dicDataYoutubeSearchResult)[query]];
                [arrayOld addObjectsFromArray:arrayList];
                [dataContainer addYoutubeSearchResult:arrayOld forKey:query];
            }
            else {
                [dataContainer addYoutubeSearchResult:arrayList forKey:query];
            }
            
            // save next token info
            {
                if (!dataContainer.dicDataYoutubeSearchNextTokenInfo) {
                    dataContainer.dicDataYoutubeSearchNextTokenInfo = [[NSMutableDictionary alloc] init];
                }
                if (nextToken && ![nextToken isEqualToString:@""]) {
                    [dataContainer addYoutubeSearchNextTokenInfo:nextToken forKey:query];
                }
                else {
                    [dataContainer removeYoutubeSearchNextTokenInfoForKey:query];
                }
            }
            
            [strongSelf.delegate reqeustSearchFinished:query];
        }
        else {
            [strongSelf.delegate reqeustSearchNoData:query];
        }
        
        [_reqeustSearch cancel];
        _reqeustSearch = nil;
    };
    
    // fail block
    void(^ failBlock) (AFHTTPRequestOperation *operation, NSError *error);
    failBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        DLog(@"Get reqeustSearch FAIL: %@", error.localizedDescription);
        
        [strongSelf.delegate reqeustSearchFailed:query];
        
        [_reqeustSearch cancel];
        _reqeustSearch = nil;
    };
    
    [_reqeustSearch setCompletionBlockWithSuccess:completionBlock
                                                             failure:failBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong NCYoutubeDataManager* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        [_reqeustSearch start];
    });
    return YES;
}

@end
