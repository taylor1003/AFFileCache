//
//  NSString+FileCacheAddtions.h
//  AFFileCache
//
//  Created by TaoPing on 15-4-20.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileCacheAddtions)

/* parameter convert to string */
+ (NSString *)parameterToString:(id)parameter;

/* Getting documents path, value means if return value with "/" */
+ (NSString *)documentsDirectoryWithTrailingSlash:(BOOL)value;

/* Encrypt string with md5 algorithm */
- (NSString *)md5;

@end
