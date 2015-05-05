//
//  FileCacheUtils.m
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import "FileCache.h"

@implementation FileCache

+ (BOOL)cacheObject:(id)obj path:(NSString *)path
{
    NSParameterAssert(obj);
    NSParameterAssert(path);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    return [data writeToFile:path atomically:YES];
}

+ (id)readPath:(NSString *)path
{
    NSParameterAssert(path);
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
