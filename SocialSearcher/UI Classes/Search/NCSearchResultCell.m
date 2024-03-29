//
//  NCSearchResultCell.m
//  SocialSearcher
//
//  Created by NakCheonJung on 11/1/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCSearchResultCell.h"

@implementation NCSearchResultCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)prepareForReuse
{
    [super prepareForReuse];
    _bIsList = NO;
}

-(BOOL)privateInitializeSetting
{
    // request
    if (!_youtubeDataManager) {
        _youtubeDataManager = [[NCYoutubeDataManager alloc] init];
        _youtubeDataManager.delegate = self;
    }
    NSString* videoID = [super.dicInfo valueForKeyPath:@"id.videoId"];
    _defaultVideoID = videoID;
    [_youtubeDataManager reqeustVideoDetailInfo:videoID];
    
    // flags
    super.bIsFinish = NO;
    
    // title
    super.strTitle = [super.dicInfo valueForKeyPath:@"snippet.title"];
    
    // thumbnail url
    {
        NSDictionary* dicThumbnail = [super.dicInfo valueForKeyPath:@"snippet.thumbnails"];
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
            strUrl = [super.dicInfo valueForKeyPath:@"snippet.thumbnails.standard.url"];
        }
        if (!strUrl) {
            strUrl = [super.dicInfo valueForKeyPath:@"snippet.thumbnails.high.url"];
        }
        if (!strUrl) {
            strUrl = [super.dicInfo valueForKeyPath:@"snippet.thumbnails.default.url"];
        }
        super.strThumbnailUrl = strUrl;
    }
    
    // check list
    if (!_defaultVideoID && [super.dicInfo valueForKeyPath:@"id.playlistId"]) {
        _bIsList = YES;
    }
    if (!_defaultVideoID && [super.dicInfo valueForKeyPath:@"id.channelId"]) {
        _bIsChannel = YES;
    }
    return YES;
}

@end
