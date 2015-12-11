//
//  NCURLManager.m
//  SocialSearcher
//
//  Created by NakCheonJung on 10/31/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCURLManager.h"

#pragma mark - Definition

@interface NCURLManager(PrivateMethods)
+(BOOL)privateCheckDirectoryExistence:(NSString*)path;
+(BOOL)privateAddSkipBackupAttributeToItemAtURL:(NSURL*)url;
@end

#pragma mark - Implementation

@implementation NCURLManager

#pragma mark - base path information

+(NSString*)libraryCachesPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* basePath = (paths.count > 0) ? paths[0] : nil;
    return basePath;
}

+(void)checkPath:(NSString*)path
{
    [NCURLManager privateCheckDirectoryExistence:path];
}

#pragma mark - User Data Caching path

+(NSString*)userImageSavePath
{
    NSString* path = [[NCURLManager libraryCachesPath] stringByAppendingPathComponent:@"/SocialSearcherDocuments/Images/"];
    [NCURLManager privateCheckDirectoryExistence:path];
    return path;
}

+(NSString*)userRawImageDataSaveFullPath:(NSString*)key
{
    NSString* path = [self userImageSavePath];
    NSString* fileName = [NSString stringWithFormat:@"%@.dat", key];
    NSString* fullPath = [path stringByAppendingPathComponent:fileName];
    return fullPath;
}

#pragma mark - key

+(NSString*)rawImageDataKey:(NSString*)imageUrl
{
    NSString* strKey = [imageUrl stringByReplacingOccurrencesOfString:@"/" withString:@""];
    strKey = [strKey stringByReplacingOccurrencesOfString:@"." withString:@""];
    strKey = [strKey stringByReplacingOccurrencesOfString:@"http:" withString:@""];
    strKey = [strKey stringByReplacingOccurrencesOfString:@":" withString:@""];
    return strKey;
}

#pragma mark - private methods

+(BOOL)privateCheckDirectoryExistence:(NSString*)path
{
    NSString* strNull = [NSString stringWithFormat:@"%@", nil];
    if ([path rangeOfString:strNull].location != NSNotFound) {
        DLog(@"invalid directory creation!!!:%@", path);
        return NO;
    }
    if ([path hasPrefix:@"http:/"]) {
        DLog(@"invalid directory creation!!!:%@", path);
        return NO;
    }
    BOOL isDir;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL]) {
            DLog(@"Error: Create folder failed %@", path);
            return NO;
        }
        else {
            DLog(@"Create folder succeeded %@", path);
        }
    }
    [NCURLManager privateAddSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    return YES;
}

+(BOOL)privateAddSkipBackupAttributeToItemAtURL:(NSURL*)url
{
    NSError* error = nil;
    BOOL success = [url setResourceValue:@YES
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if (!success) {
        DLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    
    return success;
}

@end
