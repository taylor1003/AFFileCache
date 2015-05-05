//
//  AFAppDotNetAPIClient.m
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import "AFAppDotNetAPIClient.h"
#import "AFFileCacheClient.h"

@implementation AFAppCacheAPIClient

+ (instancetype)sharedClient
{
    static AFAppCacheAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFAppCacheAPIClient alloc] init];
//        [[AFFileCacheClient clientManager] configBaseURL:@""]; // If need
    });
    
    return _sharedClient;
}

@end
