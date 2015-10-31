//
//  NCVideoItemCell.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCYoutubeDataManager.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface NCVideoItemCell : UITableViewCell
@property (nonatomic, retain) NSDictionary* dicInfo;
@property (nonatomic, assign) BOOL bIsLastItem;

-(void)initialize;
-(void)prepareForRelease;

@end

/******************************************************************************
 * Type Definition
 *****************************************************************************/

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
-(BOOL)createSeperator;
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