//
//  CachedDataManager.h
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheModel.h"
#import "FileCacheDefines.h"

@interface CachedDataManager : NSObject <CacheModelDelegate>

+ (instancetype)sharedInstance;

///-------------------
/// @name Create Cache
///-------------------

/**
 Create cache, this method will generate an unique key for cache url to managing dictionary
 @param NSString url The url for cache
 @param id parameter The parameter for url
 @param id object Cache data
 @param NSInteger expireInSeconds The validity of the cache, In seconds
 @param block completion The block executed when completion a cache. This block has no returned value and takes three arguments - the response object, if used cache and error info.
 @see -createCacheWithURL:parameter:cacheObject:expireInSeconds:updateCache:completion
 */
- (void)createCacheWithURL:(NSString *)url
                 parameter:(id)parameter
               cacheObject:(id)cacheObject
           expireInSeconds:(CGFloat)expireInSeconds
                completion:(void (^)(id responseObject, BOOL isCached, NSError *error))completion;

/**
 Create cache, this method will generate an unique key for cache url to managing dictionary
 @param NSString url The url for cache
 @param id parameter The parameter for url
 @param id object Cache data
 @param NSInteger expireInSeconds The validity of the cache, In seconds
 @param BOOL updateCache If refreshing the validity of the cache
 @param block completion The block executed when completion a cache. This block has no returned value and takes three arguments - the response object, if used cache and error info.
 */
- (void)createCacheWithURL:(NSString *)url
                 parameter:(id)parameter
               cacheObject:(id)cacheObject
           expireInSeconds:(CGFloat)expireInSeconds
               updateCache:(BOOL)updateCache
                completion:(void (^)(id responseObject, BOOL isCached, NSError *error))completion;

/**
 Create cache, this method will generate an unique key for cache url to managing dictionary
 @param kAFNetworkingMethod Calling method in AFNetworking Framework
 @param NSString url The url for cache
 @param id parameters The parameter for url
 @param NSInteger expireInSeconds The validity of the cache, In seconds
 @param BOOL updateCache If refreshing the validity of the cache
 @param BOOL forceRequest If using cache
 @param block completion The block executed when completion a cache. This block has no returned value and takes three arguments - the response object, if used cache and error info.
 */
- (void)downloadWithMethod:(kAFNetworkingMethod)method
                 URLString:(NSString *)URLString
                parameters:(id)parameters
       mustExpireInSeconds:(CGFloat)mustExpireInSeconds
               updateCache:(BOOL)updateCache
              forceRequest:(BOOL)forceRequest
                completion:(void (^)(id responseObject, BOOL isCached, NSError *error))completion;


///----------------
/// @name Get Cache
///----------------

/**
 Get cache, this method will generate an unique key for cache url to managing dictionary.
 @param NSString url The url for cache
 @param NSString query The parameter for url
 @param BOOL updateExpiryDate If refreshing the validity of the cache
 */
- (id)getCacheWithURL:(NSString *)url
            parameter:(NSDictionary *)parameter
     updateExpiryDate:(BOOL)updateExpiryDate;

///------------------
/// @name clear cache
///------------------

/**
 clear all cache
 */
- (BOOL)clear;

@end
