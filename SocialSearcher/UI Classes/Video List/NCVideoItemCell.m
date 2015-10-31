//
//  NCVideoItemCell.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCVideoItemCell.h"
#import "NCYoutubeDataManager.h"
#import "NCYoutubeDataContainer.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "NCURLManager.h"
#import "NCImageCachingManager.h"
#import "NCUtilManager.h"

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

@interface NCVideoItemCell() <NCYoutubeDataManagerDelegate>
{
    NCYoutubeDataManager* _youtubeDataManager;
    NSString* _defaultVideoID;
    NSString* _strFormattedDuration;
    
    // duration mark
    UIView* _viewDurationBackgound;
    UILabel* _lblDuration;
    UIImageView* _viewDurationIcon;
    UIView* _viewDrawingDurationIcon;
}
// ui
@property (strong, nonatomic) IBOutlet UIImageView *viewImage;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
// datas
@property (strong, nonatomic) AFHTTPRequestOperation* requestThumbnailImage;
@property (assign, nonatomic) int nRetryCount;
@property (copy, nonatomic) NSString* strThumbnailUrl;
@property (copy, nonatomic) NSString* strTitle;
// flags
@property (assign, nonatomic) BOOL bIsFinish;
@end

@interface NCVideoItemCell(CreateMethods)
-(BOOL)createThumbnailView;
-(BOOL)createLabels;
-(BOOL)createDurationInfoView;
@end

@interface NCVideoItemCell(PrivateMethods)
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
-(NSString*)privateParseISO8601Time:(NSString*)duration;
@end

@interface NCVideoItemCell(PrivateServerCommunications)
@end

@interface NCVideoItemCell(selectors)
@end

@interface NCVideoItemCell(IBActions)
@end

@interface NCVideoItemCell(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation NCVideoItemCell

#pragma mark - class life cycle

-(id)init
{
    self = [super init];
    if (self) {
        NSLog(@"NCVideoItemCell::INIT");
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)prepareForRelease
{
    
}

-(void)dealloc
{
    NSLog(@"NCVideoItemCell::DEALLOC");
}

#pragma mark - UICollectionViewCell

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    _viewImage.image = nil;
    _lblTitle.text = @"";
    _lblDate.text = @"";
    _lblDescription.text = @"";
    _viewImage.hidden = NO;
    
    // duration
    {
        [_viewDurationBackgound removeFromSuperview];
        _viewDurationBackgound = nil;
        [_lblDuration removeFromSuperview];
        _lblDuration = nil;
        [_viewDurationIcon removeFromSuperview];
        _viewDurationIcon = nil;
        [_viewDrawingDurationIcon removeFromSuperview];
        _viewDrawingDurationIcon = nil;
    }
}

#pragma mark - create methods

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
    return YES;
}

-(BOOL)createLabels
{
    _lblTitle.text = [_dicInfo valueForKeyPath:@"snippet.title"];
    _lblDate.text = [NCUtilManager convertAWSTime:[_dicInfo valueForKeyPath:@"snippet.publishedAt"]];
    _lblDescription.text = [_dicInfo valueForKeyPath:@"snippet.description"];
    
    return YES;
}

-(BOOL)createDurationInfoView
{
//    if (!_viewDurationBackgound) {
//        _viewDurationBackgound = [[UIView alloc] init];
//        _viewDurationBackgound.backgroundColor = [UIColor blackColor];
//        
//        [self addSubview:_viewDurationBackgound];
//    }
//    
//    // icon
//    {
//        if (!_viewDurationIcon) {
//            _viewDurationIcon = [[UIImageView alloc] init];
//            [_viewDurationBackgound addSubview:_viewDurationIcon];
//        }
//        _viewDurationIcon.backgroundColor = [UIColor clearColor];
//        _viewDurationIcon.image = [NCUtilManager pngImageWithMainBundle:@"icon_play"];;
//    }
//    
//    // duration
//    {
//        if (!_lblDuration) {
//            _lblDuration = [[UILabel alloc] init];
//            _lblDuration.font = [NCUtilManager getAppleNeoSemiBold:10];
//            _lblDuration.textColor = [UIColor whiteColor];
//            _lblDuration.numberOfLines = 1;
//            [_viewDurationBackgound addSubview:_lblDuration];
//        }
//        _lblDuration.text = _strFormattedDuration;
//        _lblDuration.frame = CGRectMake(0,
//                                        0,
//                                        100,
//                                        100);
//        [_lblDuration sizeToFit];
//    }
//    
//    _viewDurationIcon.frame = CGRectMake(0,
//                                         0,
//                                         _lblDuration.frame.size.height + 6,
//                                         _lblDuration.frame.size.height + 6);
//    _lblDuration.frame = CGRectMake(_viewDurationIcon.frame.origin.x + _viewDurationIcon.frame.size.width,
//                                    4,
//                                    _lblDuration.frame.size.width,
//                                    _lblDuration.frame.size.height);
//    _viewDurationBackgound.frame = CGRectMake(_viewImage.frame.size.width - (_lblDuration.frame.origin.x + _lblDuration.frame.size.width + 3) - 5,
//                                              _viewImage.frame.size.height - (_lblDuration.frame.origin.y + _lblDuration.frame.size.height + 3) - 5,
//                                              _lblDuration.frame.origin.x + _lblDuration.frame.size.width + 3,
//                                              _lblDuration.frame.origin.y + _lblDuration.frame.size.height + 3);
//    
//    _viewDurationBackgound.layer.cornerRadius = 3.0;
//    _viewDurationBackgound.layer.masksToBounds = YES;
    
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
    // request
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    NSString* videoID = [_dicInfo valueForKeyPath:@"snippet.resourceId.videoId"];
    _defaultVideoID = videoID;
    [_youtubeDataManager reqeustVideoDetailInfo:videoID];
    
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
    [self createThumbnailView];
    [self createLabels];
    return YES;
}

-(NSString*)privateParseISO8601Time:(NSString*)duration
{
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    //Get Time part from ISO 8601 formatted duration http://en.wikipedia.org/wiki/ISO_8601#Durations
    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];
    
    while ([duration length] > 1) { //only one letter remains after parsing
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];
        
        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];
        
        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];
        
        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];
        
        if ([[duration substringToIndex:1] isEqualToString:@"H"]) {
            hours = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"]) {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"]) {
            seconds = [durationPart intValue];
        }
    }
    
    return [NSString stringWithFormat:@"%02d:%02d", (int)minutes, (int)seconds];
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
    NCVideoItemCell* __weak weakSelf = self;
    void(^ completionBlock) (AFHTTPRequestOperation *operation, id responseObject);
    completionBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong NCVideoItemCell* strongSelf = weakSelf;
        
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
            DLog(@"NCVideoItemCell::thumbnail image is not exits on server");
            _viewImage.hidden = YES;
            [self setNeedsUpdateConstraints];
            return;
        }
        
        __strong NCVideoItemCell* strongSelf = weakSelf;
        ++strongSelf.nRetryCount;
        if (strongSelf.nRetryCount > 10) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong NCVideoItemCell* strongSelf = weakSelf;
            if (strongSelf.bIsFinish) {
                [strongSelf.requestThumbnailImage cancel];
                strongSelf.requestThumbnailImage = nil;
                return;
            }
            [self requestThumbnailImage];
        });
        strongSelf = nil;
    };
    
    [_requestThumbnailImage setDownloadProgressBlock:nil];
    [_requestThumbnailImage setCompletionBlockWithSuccess:completionBlock
                                                  failure:failBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong NCVideoItemCell* strongSelf = weakSelf;
        if (strongSelf.bIsFinish) {
            return;
        }
        [strongSelf.requestThumbnailImage start];
    });
    
    return YES;
}


#pragma mark - NCYoutubeDataManagerDelegate

// reqeustVideoDetailInfo
-(void)reqeustVideoDetailInfoFinished:(NSString*)videoID
{
    if (![_defaultVideoID isEqualToString:videoID]) {
        return;
    }
    
    // get data
    NCYoutubeDataContainer* dataContainer = [NCYoutubeDataContainer sharedInstance];
    NSDictionary* dicDetail = dataContainer.dicYoutubeVideoDetailResult[videoID];
    NSString* strDuration = [dicDetail valueForKeyPath:@"contentDetails.duration"];
    _strFormattedDuration = [self privateParseISO8601Time:strDuration];
    
    // draw
    [self createDurationInfoView];
}

-(void)reqeustVideoDetailInfoNoData:(NSString*)videoID
{
    
}

-(void)reqeustVideoDetailInfoFailed:(NSString*)videoID
{
    
}

@end