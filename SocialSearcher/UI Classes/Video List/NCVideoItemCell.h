//
//  NCVideoItemCell.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCVideoItemCell : UITableViewCell
@property (nonatomic, retain) NSDictionary* dicInfo;
@property (nonatomic, assign) BOOL bIsLastItem;

-(void)initialize;
-(void)prepareForRelease;

@end
