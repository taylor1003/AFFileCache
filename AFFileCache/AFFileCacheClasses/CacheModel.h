//
//  CacheModel.h
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFFileCacheClient.h" // AFNetworking Framework

@protocol CacheModelDelegate;

@interface CacheModel : NSObject
{
@public
    id<CacheModelDelegate> __unsafe_unretained delegate;
    NSString *remoteURL;
@private
    BOOL isDownloading;
}

@property (nonatomic, assign) id<CacheModelDelegate> delegate;
@property (nonatomic, copy) NSString *remoteURL;
@property (nonatomic, assign) BOOL isDownloading;

- (void)Method:(kAFNetworkingMethod)method
     URLString:(NSString *)URLString
    parameters:(id)parameters;

- (void)startCachedObject:(id)cacheObject withRemoteURL:(NSString *)url;

@end

@protocol CacheModelDelegate <NSObject>

- (void) cacheModelDelegateSucceeded:(CacheModel *)paramSender
                       withRemoteURL:(NSURL *)paramRemoteURL
                      responseObject:(id)responseObject;

- (void) cacheModelDelegateFailed:(CacheModel *)paramSender
                        remoteURL:(NSURL *)paramRemoteURL
                        withError:(NSError *)paramError;

@end
