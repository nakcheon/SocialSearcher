//
//  NCChannelItemCell.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCChannelItemCell : UICollectionViewCell
@property (nonatomic, retain) NSDictionary* dicInfo;

-(void)initialize;
-(void)prepareForRelease;

@end
