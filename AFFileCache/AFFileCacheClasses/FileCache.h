//
//  FileCacheUtils.h
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject

+ (BOOL)cacheObject:(id)obj path:(NSString *)path;

+ (id)readPath:(NSString *)path;

@end
