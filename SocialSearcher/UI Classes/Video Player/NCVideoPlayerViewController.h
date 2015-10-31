//
//  NCVideoPlayerViewController.h
//  SocialSearcher
//
//  Created by NakCheonJung on 11/1/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCVideoPlayerViewController : UIViewController
@property (nonatomic, retain) NSDictionary* dicInfo;

-(void)initialize;
-(void)prepareForRelease;

@end
