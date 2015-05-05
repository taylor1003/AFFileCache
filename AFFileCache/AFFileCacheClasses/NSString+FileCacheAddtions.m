//
//  NSString+FileCacheAddtions.m
//  AFFileCache
//
//  Created by TaoPing on 15-4-20.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import "NSString+FileCacheAddtions.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (FileCacheAddtions)

+ (NSString *)parameterToString:(id)parameter
{
    if (parameter == nil) {
        return nil;
    }
    
    NSString *result = @"";
    if ([parameter isKindOfClass:[NSString class]]) {
        result = (NSString *)parameter;
    } else if ([parameter isKindOfClass:[NSDictionary class]]) {
        NSArray *allKeys = [parameter allKeys];
        result = [allKeys count] > 0 ? @"?" : @"";
        for (NSInteger i = 0; i < [allKeys count]; i++) {
            id key = [allKeys objectAtIndex:i];
            if (([key isKindOfClass:[NSString class]] || [key isKindOfClass:[NSNumber class]]) && ([[parameter objectForKey:key] isKindOfClass:[NSString class]] || [[parameter objectForKey:key] isKindOfClass:[NSNumber class]])) {
                if (i != 0) {
                    result = [result stringByAppendingString:@"&"];
                }
                result = [result stringByAppendingFormat:@"%@=%@", key, [parameter objectForKey:key]];
            }
        }
    } else if ([parameter isKindOfClass:[NSData class]]) {
        result = [[NSString alloc] initWithData:parameter encoding:NSUTF8StringEncoding];
    }
    return result;
}

+ (NSString *)documentsDirectoryWithTrailingSlash:(BOOL)value
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (value) {
        path = [path stringByAppendingString:@"/"];
    }
    return path;
}

- (NSString *)md5
{
    if (self == nil) return nil;
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *md5Str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5Str appendFormat:@"%02x", digest[i]];
    }
    return md5Str;
}

@end
