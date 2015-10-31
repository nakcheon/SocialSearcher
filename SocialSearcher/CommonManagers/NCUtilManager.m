//
//  NCUtilManager.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCUtilManager.h"

#pragma mark - enum Definition

/******************************************************************************
 * enum Definition
 *****************************************************************************/


/******************************************************************************
 * String Definition
 *****************************************************************************/


/******************************************************************************
 * Constant Definition
 *****************************************************************************/


/******************************************************************************
 * Function Definition
 *****************************************************************************/


/******************************************************************************
 * Type Definition
 *****************************************************************************/

@interface NCUtilManager()
@end

@interface NCUtilManager(CreateMethods)
@end

@interface NCUtilManager(PrivateMethods)
+(UIImage*)privateCropImage:(UIImage*)originalImage
                     bounds:(CGRect)bounds;
@end

@interface NCUtilManager(PrivateServerCommunications)
@end

@interface NCUtilManager(selectors)
@end

@interface NCUtilManager(IBActions)
@end

@interface NCUtilManager(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation NCUtilManager

#pragma mark - color

+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString* cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor grayColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    
    // delete '#'even if it begins with '#'
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    
    if ([cString length] != 6) {
        return  [UIColor grayColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString* rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString* gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString* bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

#pragma mark - font

+(UIFont*)getAppleNeoThin:(CGFloat)size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:size];
}

+(UIFont*)getAppleNeoLight:(CGFloat)size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:size];
}

+(UIFont*)getAppleNeoRegular:(CGFloat)size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:size];
}

+(UIFont*)getAppleNeoMedium:(CGFloat)size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:size];
}

+(UIFont*)getAppleNeoSemiBold:(CGFloat)size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:size];
}

+(UIFont*)getAppleNeoBold:(CGFloat)size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:size];
}

#pragma mark - image

+(UIImage*)pngImageWithMainBundle:(NSString*)file
{
    NSString* path = [[NSBundle mainBundle] pathForResource:file ofType:@"png"];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

+(UIImage*)imageCenterCropFitToWidth:(UIImage*)originalImage
                          insertRect:(CGRect)insertRect
{
    UIImage* croppedImageToReturn = nil;
    if (insertRect.size.width > originalImage.size.width && insertRect.size.height > originalImage.size.height) {
        return originalImage;
    }
    float ratio = 1.0;
    ratio = insertRect.size.width/originalImage.size.width;
    CGRect rectCrop = CGRectMake(0,
                                 (originalImage.size.height-(insertRect.size.height/ratio))/2,
                                 originalImage.size.width,
                                 insertRect.size.height/ratio);
    croppedImageToReturn = [NCUtilManager privateCropImage:originalImage bounds:rectCrop];
    
    return croppedImageToReturn;
}

#pragma mark - private methods

+(UIImage*)privateCropImage:(UIImage*)originalImage
                     bounds:(CGRect)bounds
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], bounds);
    UIImage* croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end
