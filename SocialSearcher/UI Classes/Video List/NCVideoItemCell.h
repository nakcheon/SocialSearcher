//
//  NCVideoItemCell.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCYoutubeDataManager.h"
#import <AFNetworking/AFNetworking.h>

@interface NCVideoItemCell : UITableViewCell
@property (nonatomic, strong) NSDictionary* dicInfo;
@property BOOL bIsLastItem;

-(void)initialize;

@end

#pragma mark - Definition

@interface NCVideoItemCell() <NCYoutubeDataManagerDelegate>
{
@protected
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
@property (strong, nonatomic) IBOutlet UIView *viewSeperator;
// datas
@property (strong, nonatomic) AFHTTPRequestOperation* requestThumbnailImage;
@property (copy, nonatomic) NSString* strThumbnailUrl;
@property (copy, nonatomic) NSString* strTitle;
// flags
@property int nRetryCount;
@property BOOL bIsFinish;
@end

@interface NCVideoItemCell(CreateMethods)
-(BOOL)createThumbnailView;
-(BOOL)createLabels;
-(BOOL)createDurationInfoView;
-(BOOL)createSeperator;
@end

@interface NCVideoItemCell(PrivateMethods)
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
-(NSString*)privateParseISO8601Time:(NSString*)duration;
@end

