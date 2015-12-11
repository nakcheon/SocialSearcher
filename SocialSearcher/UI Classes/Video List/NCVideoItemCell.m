//
//  NCVideoItemCell.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCVideoItemCell.h"
#import "NCYoutubeDataContainer.h"
#import "NCURLManager.h"
#import "NCImageCachingManager.h"
#import "NCUtilManager.h"

#pragma mark - Implementation

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
    _bIsLastItem = NO;
    _viewSeperator.hidden = NO;
    _strFormattedDuration = nil;
    
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

#pragma mark - overrides

-(void)layoutSubviews
{
    if (_strFormattedDuration && ![_strFormattedDuration isEqualToString:@""]) {
        [self createDurationInfoView];
    }
}

#pragma mark - create methods

-(BOOL)createThumbnailView
{
    if (!_strThumbnailUrl || [_strThumbnailUrl isEqualToString:@""]) {
        _viewImage.hidden = YES;
        return NO;
    }
    
    // search saved image
    {
        NSString* strKey = [NCURLManager rawImageDataKey:_strThumbnailUrl];
        NCImageCachingManager* imageSaver = [NCImageCachingManager sharedInstance];
        UIImage* imageSaved = [imageSaver getRawDataWithKey:strKey];
        
        // has saved image
        if (imageSaved) {
            _viewImage.image = [NCUtilManager imageCenterCropFitToWidth:imageSaved
                                                             insertRect:_viewImage.frame];;
            NCVideoItemCell* __weak weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong NCVideoItemCell* strongSelf = weakSelf;
                strongSelf.viewImage.image = [NCUtilManager imageCenterCropFitToWidth:imageSaved
                                                                 insertRect:strongSelf.viewImage.frame];
            });
        }
        // request
        else {
            _nRetryCount = 0;
            [self privateRequestThumbnailImage];
        }
    }
    return YES;
}

-(BOOL)createLabels
{
    _lblTitle.text = [_dicInfo valueForKeyPath:@"snippet.title"];
    _lblDate.text = [NCUtilManager convertAWSTime:[_dicInfo valueForKeyPath:@"snippet.publishedAt"]];
    _lblDescription.text = [_dicInfo valueForKeyPath:@"snippet.description"];
    
    return YES;
}

-(BOOL)createSeperator
{
    if (_bIsLastItem) {
        _viewSeperator.hidden = YES;
    }
    return YES;
}

-(BOOL)createDurationInfoView
{
    // custom view
    if (!_viewDurationBackgound) {
        _viewDurationBackgound = [[UIView alloc] init];
        _viewDurationBackgound.backgroundColor = [UIColor blackColor];
        
        [self addSubview:_viewDurationBackgound];
    }
    
    // icon
    {
        if (!_viewDurationIcon) {
            _viewDurationIcon = [[UIImageView alloc] init];
            [_viewDurationBackgound addSubview:_viewDurationIcon];
        }
        _viewDurationIcon.backgroundColor = [UIColor clearColor];
        _viewDurationIcon.image = [NCUtilManager pngImageWithMainBundle:@"icon_play"];;
    }
    
    // duration
    {
        if (!_lblDuration) {
            _lblDuration = [[UILabel alloc] init];
            _lblDuration.font = [NCUtilManager getAppleNeoSemiBold:10];
            _lblDuration.textColor = [UIColor whiteColor];
            _lblDuration.numberOfLines = 1;
            [_viewDurationBackgound addSubview:_lblDuration];
        }
        _lblDuration.text = _strFormattedDuration;
        _lblDuration.frame = CGRectMake(0,
                                        0,
                                        100,
                                        100);
        [_lblDuration sizeToFit];
    }
    
    _viewDurationIcon.frame = CGRectMake(0,
                                         0,
                                         _lblDuration.frame.size.height + 6,
                                         _lblDuration.frame.size.height + 6);
    _lblDuration.frame = CGRectMake(_viewDurationIcon.frame.origin.x + _viewDurationIcon.frame.size.width,
                                    4,
                                    _lblDuration.frame.size.width,
                                    _lblDuration.frame.size.height);
    _viewDurationBackgound.frame = CGRectMake(_viewImage.frame.origin.x + _viewImage.frame.size.width - (_lblDuration.frame.origin.x + _lblDuration.frame.size.width + 0) - 0,
                                              _viewImage.frame.origin.y + _viewImage.frame.size.height - (_lblDuration.frame.origin.y + _lblDuration.frame.size.height + 0) - 0,
                                              _lblDuration.frame.origin.x + _lblDuration.frame.size.width + 3,
                                              _lblDuration.frame.origin.y + _lblDuration.frame.size.height + 3);
    
    _viewDurationBackgound.layer.cornerRadius = 3.0;
    _viewDurationBackgound.layer.masksToBounds = YES;
    _viewDurationBackgound.layer.borderWidth = 1.0;
    _viewDurationBackgound.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
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
        if (!strUrl) {
            strUrl = [_dicInfo valueForKeyPath:@"snippet.thumbnails.high.url"];
        }
        if (!strUrl) {
            strUrl = [_dicInfo valueForKeyPath:@"snippet.thumbnails.default.url"];
        }
        _strThumbnailUrl = strUrl;
    }
    return YES;
}

-(BOOL)privateInitializeUI
{
    [self createThumbnailView];
    [self createLabels];
    [self createSeperator];
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
