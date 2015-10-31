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

#pragma mark - time

+(NSString*)convertAWSTime:(NSString*)time
{
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    
    // convert server date
    NSDateFormatter* serverFormatter = [[NSDateFormatter alloc] init];
    [serverFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [serverFormatter setLocale:[NSLocale currentLocale]];
    [serverFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000'Z'"];
    
    // server's Date
    NSDate* serverDate = [serverFormatter dateFromString:time];
    
    // current Date
    NSDate* curDate = [NSDate date];
    NSString* strCurDate = [serverFormatter stringFromDate:curDate];
    curDate = [serverFormatter dateFromString: strCurDate];
    
    NSCalendar* carlendar = [NSCalendar currentCalendar];
    NSUInteger unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    if (!serverDate) {
        serverDate = [NSDate date];
        DLog(@"serverDate is nil");
    }
    NSDateComponents* components = [carlendar components:unit
                                                fromDate:serverDate
                                                  toDate:curDate
                                                 options:0];
    
    // calculate cmpare pivot (day, hour, minute)
    NSInteger day = components.day - (int)(timeZoneSeconds/(24*60*60));
    NSInteger hour = components.hour - (int)(timeZoneSeconds/(60*60));
    NSInteger min = components.minute;
    NSInteger month = components.month;
    NSInteger year = components.year;
    
    NSDateFormatter* displayFormatter = [[NSDateFormatter alloc] init];
    [displayFormatter setTimeZone: [NSTimeZone localTimeZone]];
    [displayFormatter setLocale: [NSLocale currentLocale]];
    [displayFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000'Z'"];
    NSString* strServerDate = [displayFormatter stringFromDate: serverDate];
    
    displayFormatter = [[NSDateFormatter alloc] init];
    [displayFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [displayFormatter setLocale: [NSLocale currentLocale]];
    [displayFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000'Z'"];
    
    NSDate* serverDisplayDate = [displayFormatter dateFromString: strServerDate];
    
    //=========================================================
    // bevore a day
    //=========================================================
    if (day <= 0 && month <= 0 && year <= 0) {
        // today
        if (hour <= 0) {
            // less than 1 hour
            if (min <= 5) {
                // 5분전
                return NSLocalizedString(@"Just now", @"");
            }
            else {
                // 6 ~ 59 minuts
                return [NSString stringWithFormat: @"%li %@", min, NSLocalizedString(@"mins", @"")];
            }
        }
        else {
            // under 23 hours
            if (hour <= 1) {
                return [NSString stringWithFormat: @"%li %@", hour, NSLocalizedString(@"hr", @"")];
            }
            else {
                return [NSString stringWithFormat: @"%li %@", hour, NSLocalizedString(@"hrs", @"")];
            }
        }
    }
    
    //=========================================================
    // after a day
    //=========================================================
    else {
        // 1 day ~ 48 hours
        if (day <= 1 && month <= 0 && year <= 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormatter setLocale: [NSLocale currentLocale]];
            [dateFormatter setDateFormat:@"h:mm"];
            NSString* timeString = [dateFormatter stringFromDate:[serverDisplayDate dateByAddingTimeInterval:timeZoneSeconds]];
            [dateFormatter setDateFormat:@"a"];
            NSString* periodString = [[dateFormatter stringFromDate:[serverDisplayDate dateByAddingTimeInterval:timeZoneSeconds]] lowercaseString];
            
            return [NSString stringWithFormat: @"%@ %@%@", NSLocalizedString(@"yesterday at", @""), timeString, periodString];
        }
        else {
            // 48 hours ~ 1 year before a day
            if (day <= 365) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                [dateFormatter setLocale: [NSLocale currentLocale]];
                [dateFormatter setDateFormat:@"MMMM d"];
                NSString *monthDayString = [dateFormatter stringFromDate:[serverDisplayDate dateByAddingTimeInterval:timeZoneSeconds]];
                [dateFormatter setDateFormat:@"h:mm"];
                NSString *timeString = [dateFormatter stringFromDate:[serverDisplayDate dateByAddingTimeInterval:timeZoneSeconds]];
                [dateFormatter setDateFormat:@"a"];
                NSString *periodString = [[dateFormatter stringFromDate:[serverDisplayDate dateByAddingTimeInterval:timeZoneSeconds]] lowercaseString];
                
                return [NSString stringWithFormat: @"%@%@ %@%@", monthDayString, NSLocalizedString(@" at", @""), timeString, periodString];
            }
            else {
                // 1 year ~
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone: [NSTimeZone localTimeZone]];
                [dateFormatter setLocale: [NSLocale currentLocale]];
                [dateFormatter setDateFormat:@"MMMM d, y"];
                NSString *monthDayYearString = [dateFormatter stringFromDate:[serverDisplayDate dateByAddingTimeInterval:timeZoneSeconds]];
                [dateFormatter setDateFormat:@"h:mm"];
                NSString *timeString = [dateFormatter stringFromDate:[serverDisplayDate dateByAddingTimeInterval:timeZoneSeconds]];
                [dateFormatter setDateFormat:@"a"];
                NSString *periodString = [[dateFormatter stringFromDate:[serverDisplayDate dateByAddingTimeInterval:timeZoneSeconds]] lowercaseString];
                
                return [NSString stringWithFormat: @"%@%@ %@%@", monthDayYearString, NSLocalizedString(@" at", @""), timeString, periodString];
            } // if (day <= 365) {
        } // if(day <= 1)
    } // if (day <= 0) {
}

@end
