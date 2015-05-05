//
//  AFAppDotNetAPIClient.h
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CachedDataManager.h"

@interface AFAppCacheAPIClient : CachedDataManager

+ (instancetype)sharedClient;

@end