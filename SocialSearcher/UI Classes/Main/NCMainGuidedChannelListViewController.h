//
//  NCMainGuidedChannelListViewController.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCYoutubeDataManager.h"

@interface NCMainGuidedChannelListViewController : UIViewController

-(void)initialize;
-(void)prepareForRelease;

@end


/******************************************************************************
 * Type Definition
 *****************************************************************************/

@interface NCMainGuidedChannelListViewController() <UICollectionViewDataSource,
                                                    UICollectionViewDelegate,
                                                    UICollectionViewDelegateFlowLayout,
                                                    NCYoutubeDataManagerDelegate,
                                                    UIScrollViewDelegate>
{
@protected
    NSArray* _arrayDataList;
    
    // load more
    NCYoutubeDataManager* _youtubeDataManager;
    NSString* _defaultChannelID;
    BOOL _bNextRequestSent;
    BOOL _bAllListLoaded;
}
@property (strong, nonatomic) IBOutlet UICollectionView *collectionChannelList;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionChannelListLayout;
@end

@interface NCMainGuidedChannelListViewController(CreateMethods)
@end

@interface NCMainGuidedChannelListViewController(PrivateMethods)
// life cycle
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
// load more
-(BOOL)privateRequestList;
-(BOOL)privateAddLoadingView;
-(BOOL)privateRemoveLoadingView;
@end

@interface NCMainGuidedChannelListViewController(PrivateServerCommunications)
@end

@interface NCMainGuidedChannelListViewController(selectors)
@end

@interface NCMainGuidedChannelListViewController(IBActions)
@end

@interface NCMainGuidedChannelListViewController(ProcessMethod)
@end