//
//  NCUtilManager.h
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCUtilManager : NSObject

#pragma mark - color

+(UIColor*)colorWithHexString:(NSString*)hex;

#pragma mark - font

+(UIFont*)getAppleNeoThin:(CGFloat)size;
+(UIFont*)getAppleNeoLight:(CGFloat)size;
+(UIFont*)getAppleNeoRegular:(CGFloat)size;
+(UIFont*)getAppleNeoMedium:(CGFloat)size;
+(UIFont*)getAppleNeoSemiBold:(CGFloat)size;
+(UIFont*)getAppleNeoBold:(CGFloat)size;

#pragma mark - image

+(UIImage*)pngImageWithMainBundle:(NSString*)file;
+(UIImage*)imageCenterCropFitToWidth:(UIImage*)originalImage
                          insertRect:(CGRect)insertRect;

@end
