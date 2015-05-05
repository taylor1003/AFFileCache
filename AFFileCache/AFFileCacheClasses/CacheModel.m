//
//  CacheModel.m
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import "CacheModel.h"
#import "NSString+FileCacheAddtions.h"

@implementation CacheModel

@synthesize delegate = delegate, remoteURL = remoteURL, isDownloading = isDownloading;

- (instancetype)init
{
    if (self = [super init]) {
        isDownloading = YES;
    }
    return self;
}

- (void)Method:(kAFNetworkingMethod)method
     URLString:(NSString *)URLString
    parameters:(id)parameters
{
    NSString *query = [[NSString parameterToString:parameters] md5];
    NSString *cacheKey = [[NSString stringWithFormat:@"%@%@", URLString, query] lowercaseString];
    self.remoteURL = cacheKey;
    
    if ([AFFileCacheClient clientManager].baseURL != nil) {
        self.remoteURL = [NSString stringWithFormat:@"%@%@", [[AFFileCacheClient clientManager].baseURL absoluteString], cacheKey];
    }
    
    [[AFFileCacheClient clientManager] Method:method URLString:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        isDownloading = NO;
        
        if ([self.delegate respondsToSelector:@selector(cacheModelDelegateSucceeded:withRemoteURL:responseObject:)]) {
            [self.delegate cacheModelDelegateSucceeded:self withRemoteURL:[NSURL URLWithString:self.remoteURL] responseObject:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        isDownloading = NO;
        if ([self.delegate respondsToSelector:@selector(cacheModelDelegateFailed:remoteURL:withError:)]) {
            [self.delegate cacheModelDelegateFailed:self remoteURL:[NSURL URLWithString:self.remoteURL] withError:error];
        }
    }];
}

- (void)startCachedObject:(id)cacheObject withRemoteURL:(NSString *)url
{
    isDownloading = NO;
    self.remoteURL = url;
    if ([self.delegate respondsToSelector:@selector(cacheModelDelegateSucceeded:withRemoteURL:responseObject:)]) {
        [self.delegate cacheModelDelegateSucceeded:self withRemoteURL:[NSURL URLWithString:remoteURL] responseObject:cacheObject];
    }
}

@end
