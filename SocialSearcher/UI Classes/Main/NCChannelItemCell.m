//
//  NCChannelItemCell.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCChannelItemCell.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "NCUIConstantsManager.h"
#import "NCURLManager.h"
#import "NCImageCachingManager.h"

#pragma mark - Definition

@interface NCChannelItemCell()
// ui
@property (strong, nonatomic) IBOutlet UIImageView *viewImage;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
// datas
@property (strong, nonatomic) AFHTTPRequestOperation* requestThumbnailImage;
@property (assign, nonatomic) int nRetryCount;
@property (copy, nonatomic) NSString* strThumbnailUrl;
@property (copy, nonatomic) NSString* strTitle;
// flags
@property (assign, nonatomic) BOOL bIsFinish;
@end

@interface NCChannelItemCell(CreateMethods)
-(BOOL)createRoundedCorner;
-(BOOL)createThumbnailView;
-(BOOL)createTitle;
@end

@interface NCChannelItemCell(PrivateMethods)
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
@end

@interface NCChannelItemCell(PrivateServerCommunications)
-(BOOL)privateRequestThumbnailImage;
@end


#pragma mark - Implementation

@implementation NCChannelItemCell

#pragma mark - class life cycle

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"NCChannelItemCell::INIT");
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"NCChannelItemCell::DEALLOC");
}

#pragma mark - UICollectionViewCell

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    _bIsFinish = YES;
    _nRetryCount = 0;
    _viewImage.image = nil;
    _lblTitle.text = @"";
}

#pragma mark - create methods

-(BOOL)createRoundedCorner
{
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [NCUIConstantsManager MAIN_CELL_BRODER_COLOR].CGColor;
    self.layer.cornerRadius = 3.0;
    self.layer.masksToBounds = YES;
    return YES;
}

-(BOOL)createThumbnailView
{
    // search saved image
    {
        NSString* strKey = [NCURLManager rawImageDataKey:_strThumbnailUrl];
        NCImageCachingManager* imageSaver = [NCImageCachingManager sharedInstance];
        UIImage* imageSaved = [imageSaver getRawDataWithKey:strKey];
        
        // has saved image
        if (imageSaved) {
            _viewImage.image = [NCUtilManager imageCenterCropFitToWidth:imageSaved
                                                             insertRect:_viewImage.frame];
        }
        // request
        else {
            _nRetryCount = 0;
            [self privateRequestThumbnailImage];
        }
    }
    return YES;
}

-(BOOL)createTitle
{
    NCChannelItemCell* __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong NCChannelItemCell* strongSelf = weakSelf;
        float labelHeight = self.frame.size.height - (strongSelf.viewImage.frame.origin.y + strongSelf.viewImage.frame.size.height + 5) - 5;
        strongSelf.lblTitle.font = [NCUtilManager getAppleNeoRegular:labelHeight/3];
        
        // data
        strongSelf.lblTitle.text = strongSelf.strTitle;
    });
    
    return YES;
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
    // flags
    _bIsFinish = NO;
    
    // title
    _strTitle = [_dicInfo valueForKeyPath:@"snippet.title"];
    
    // thumbnail url
    {
        NSDictionary* dicThumbnail = [_dicInfo valueForKeyPath:@"snippet.thumbnails"];
        NSString* strUrl = nil;
        for (NSString* key in dicThumbnail.keyEnumerator) {
            NSDictionary* dicType = dicThumbnail[key];
            float height = [dicType[@"height"] floatValue];
            float width = [dicType[@"width"] floatValue];
            
            if (width >= self.frame.size.width && height >= self.frame.size.width/16*9) {
                strUrl = dicType[@"url"];
                break;
            }
        }
        if (!strUrl) {
            strUrl = [_dicInfo valueForKeyPath:@"snippet.thumbnails.standard.url"];
        }
        _strThumbnailUrl = strUrl;
    }
    
    return YES;
}

-(BOOL)privateInitializeUI
{
    [self createRoundedCorner];
    [self createThumbnailView];
    [self createTitle];
    return YES;
}

#pragma mark - request methods

-(BOOL)privateRequestThumbnailImage
{
    if (!_strThumbnailUrl) {
        return NO;
    }
    
    NSURL* url = [NSURL URLWithString:_strThumbnailUrl];
    _requestThumbnailImage = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
    
    // success block
    NCChannelItemCell* __weak weakSelf = self;
    void(^ completionBlock) (AFHTTPRequestOperation *operation, id responseObject);
    completionBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong NCChannelItemCell* strongSelf = weakSelf;
        
        UIImage* responseImage = [UIImage imageWithData:responseObject];
        
        NCImageCachingManager* imageSaver = [NCImageCachingManager sharedInstance];
        NSString* strKey = [NCURLManager rawImageDataKey:strongSelf.strThumbnailUrl];
        [imageSaver addFullDataWithKey:strKey
                                  data:responseObject];
        
        strongSelf.viewImage.image = [NCUtilManager imageCenterCropFitToWidth:responseImage
                                                         insertRect:strongSelf.viewImage.frame];
        responseImage = nil;
        
        [strongSelf.requestThumbnailImage cancel];
        strongSelf.requestThumbnailImage = nil;
        strongSelf = nil;
    };
    
    // fail block
    void(^ failBlock) (AFHTTPRequestOperation *operation, NSError *error);
    failBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"privateRequestThumbnailImage ERROR: %d", (int)error.code);
        if ([error.localizedDescription isEqualToString:@"Request failed: forbidden (403)"]) {
            DLog(@"NCChannelItemCell::thumbnail image is not exits on server");
            return;
        }
        
        __strong NCChannelItemCell* strongSelf = weakSelf;
        ++strongSelf.nRetryCount;
        if (strongSelf.nRetryCount > 10) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong NCChannelItemCell* strongSelf = weakSelf;
            if (strongSelf.bIsFinish) {
                [strongSelf.requestThumbnailImage cancel];
                strongSelf.requestThumbnailImage = nil;
                return;
            }
            [self privateRequestThumbnailImage];
        });
        strongSelf = nil;
    };
    
    [_requestThumbnailImage setDownloadProgressBlock:nil];
    [_requestThumbnailImage setCompletionBlockWithSuccess:completionBlock
                                                  failure:failBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong NCChannelItemCell* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        [strongSelf.requestThumbnailImage start];
    });
    
    return YES;
}


@end
