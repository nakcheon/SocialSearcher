//
//  NCSearchResultCell.h
//  SocialSearcher
//
//  Created by NakCheonJung on 11/1/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCVideoItemCell.h"

@interface NCSearchResultCell : NCVideoItemCell
@property (nonatomic, readonly) BOOL bIsList;
@property (nonatomic, readonly) BOOL bIsChannel;

@end
