//
//  CachedDataManager.m
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import "CachedDataManager.h"
#import "CacheModel.h"
#import "AFFileCacheClient.h"
#import "NSString+FileCacheAddtions.h"
#import "FileCacheReachability.h"
#import "FileCache.h"

#define CACHEDICTNAME @"CacheDownloads.dic"
/**
 * The structure of cache dictionary
 * Main key - cache dictionary
 * The keys of cache dictionary
 * kCacheEndDate          The time that end of downloading for cache
 * kCacheStartDate        The time of starting cache
 * kCacheExpiresInSeconds The effective time of cache
 * kCacheExpiryDate       the expired time of cache
 * kLocalPath             local path, only file name
 */
#define kCacheEndDate          @"kCacheEndDate"
#define kCacheStartDate        @"kCacheStartDate"
#define kCacheExpiresInSeconds @"kCacheExpiresInSeconds"
#define kCacheExpiryDate       @"kCacheExpiryDate"
#define kLocalPath             @"kLocalPath"

typedef void (^CacheCompletionHandler)(id responseObject, BOOL isCached, NSError *error);

@interface CachedDataManager ()
{
    NSMutableDictionary *cacheDictionary;     // The dictionary of recording cache data
    NSString *cacheDictionaryPath;            // Cache path for managing dictionary
    
    dispatch_queue_t _cacheQueue;
    NSFileManager *fileManager;
}

@property (nonatomic, copy) CacheCompletionHandler completionHandler;
@property (nonatomic, strong) NSMutableDictionary *cacheDictionary;
@property (nonatomic, copy) NSString *cacheDictionaryPath;

#pragma mark - private method

/* Saving the dictionary of cache */
- (BOOL)saveCacheDictionary;
/* Remove the cache that expired or failed to download  */
- (void)removeCorruptedCachedItems;

@end

@implementation CachedDataManager
@synthesize cacheDictionary = cacheDictionary, cacheDictionaryPath = cacheDictionaryPath;

+ (instancetype)sharedInstance
{
    static CachedDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self == [super init]) {
        _cacheQueue = dispatch_queue_create("com.afnetworking.filecache", DISPATCH_QUEUE_CONCURRENT);
        
        NSString *documentsDirectory = [NSString documentsDirectoryWithTrailingSlash:YES];
        self.cacheDictionaryPath = [documentsDirectory stringByAppendingString:CACHEDICTNAME];
        
        fileManager = [NSFileManager new];
        if ([fileManager fileExistsAtPath:self.cacheDictionaryPath]) {
            
            NSMutableDictionary *dictionary = [FileCache readPath:self.cacheDictionaryPath];
            self.cacheDictionary = dictionary;
            
            dispatch_async(_cacheQueue, ^{
                [self removeCorruptedCachedItems];
            });
            
        } else {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            self.cacheDictionary = dictionary;
            
        }
    }
    return self;
}

#pragma mark - private

- (void)removeCorruptedCachedItems
{
    if (self.cacheDictionary == nil || ![FileCacheReachability canConnectNetwork]) {
        return;
    }
    
    NSMutableArray *delKeys = [NSMutableArray array];
    @synchronized(self.cacheDictionary) {
        for (id key in self.cacheDictionary) {
            NSMutableDictionary *dict = [self.cacheDictionary objectForKey:key];
            NSDate *now = [NSDate date];
            NSDate *cacheEndDate = [dict objectForKey:kCacheEndDate];
            NSDate *expiryDate = [dict objectForKey:kCacheExpiryDate];
            NSString *localPath = [[NSString documentsDirectoryWithTrailingSlash:NO] stringByAppendingPathComponent:[dict objectForKey:kLocalPath]];
            
            if (cacheEndDate == nil || (expiryDate != nil && [now timeIntervalSinceDate:expiryDate] > 0.0)) {
                if (localPath != nil && localPath.length > 0) {
                    if ([fileManager fileExistsAtPath:localPath]) {
                        [fileManager removeItemAtPath:localPath error:nil];
                    }
                }
                
                [delKeys addObject:key];
            }
        }
        
        for (int i = 0; i < [delKeys count]; i++) {
            [self.cacheDictionary removeObjectForKey:[delKeys objectAtIndex:i]];
            
        }
        
    }
    [self saveCacheDictionary];
}

#pragma mark - public

- (BOOL)saveCacheDictionary
{
    return [FileCache cacheObject:cacheDictionary path:cacheDictionaryPath];
}

- (void)createCacheWithURL:(NSString *)url
                 parameter:(id)parameter
               cacheObject:(id)cacheObject
           expireInSeconds:(CGFloat)expireInSeconds
                completion:(void (^)(id, BOOL, NSError *))completion
{
    [self createCacheWithURL:url parameter:parameter cacheObject:cacheObject expireInSeconds:expireInSeconds updateCache:YES completion:completion];
}

- (void)createCacheWithURL:(NSString *)url
                 parameter:(id)parameter
               cacheObject:(id)cacheObject
           expireInSeconds:(CGFloat)expireInSeconds
               updateCache:(BOOL)updateCache
                completion:(void (^)(id, BOOL, NSError *))completion
{
    [self downloadWithMethod:kAFNetworkingMethodGET URLString:url parameters:parameter cacheObject:cacheObject mustExpireInSeconds:expireInSeconds updateCache:updateCache forceRequest:NO completion:completion];
}

- (void)downloadWithMethod:(kAFNetworkingMethod)method
                 URLString:(NSString *)URLString
                parameters:(id)parameters
       mustExpireInSeconds:(CGFloat)mustExpireInSeconds
               updateCache:(BOOL)updateCache
              forceRequest:(BOOL)forceRequest
                completion:(void (^)(id, BOOL, NSError *))completion
{
    [self downloadWithMethod:method URLString:URLString parameters:parameters cacheObject:nil mustExpireInSeconds:mustExpireInSeconds updateCache:updateCache forceRequest:forceRequest completion:completion];
}

- (void)downloadWithMethod:(kAFNetworkingMethod)method
                 URLString:(NSString *)URLString
                parameters:(id)parameters
               cacheObject:(id)cacheObject
       mustExpireInSeconds:(CGFloat)mustExpireInSeconds
               updateCache:(BOOL)updateCache
              forceRequest:(BOOL)forceRequest
                completion:(void (^)(id, BOOL, NSError *))completion
{
    dispatch_async(_cacheQueue, ^{
        self.completionHandler = completion;
        
        NSString *urlKey = @"";
        if ([AFFileCacheClient clientManager].baseURL != nil) {
            urlKey = [[NSString stringWithFormat:@"%@%@", [[AFFileCacheClient clientManager].baseURL absoluteString], URLString] lowercaseString];
        } else {
            urlKey = URLString;
        }
        
        NSString *query = [[NSString parameterToString:parameters] md5];
        
        NSString *cacheKey = [NSString stringWithFormat:@"%@%@", urlKey, query];
        
        if (self.cacheDictionary == nil || [cacheKey length] == 0) {
            return;
        }
        cacheKey = [cacheKey lowercaseString];
        NSMutableDictionary *modelDict = [cacheDictionary objectForKey:cacheKey];
        
        // The logic varible of cache
        BOOL fileHasBeenCached = NO;
        BOOL cachedFileHasExpired = NO;
        BOOL cachedFileExists = NO;
        BOOL cachedFileDataCanbenLoaded = NO;
        id cachedFileData;
        BOOL cachedFileIsFullyDownloaded = NO;
        BOOL cachedFileIsBeingDownloaded = NO;
        NSDate *expiryDate              = nil;
        NSDate *cacheEndDate            = nil;
        NSDate *cacheStartDate          = nil;
        NSString *localPath             = nil;
        NSNumber *expiresInSeconds      = nil;
        
        NSDate *now = [NSDate date];
        if (modelDict != nil) {
            if (forceRequest && [FileCacheReachability canConnectNetwork]) {
                fileHasBeenCached = NO;
                localPath = [[NSString documentsDirectoryWithTrailingSlash:NO] stringByAppendingPathComponent:[modelDict objectForKey:kLocalPath]];
                if ([fileManager fileExistsAtPath:localPath]) {
                    [fileManager removeItemAtPath:localPath error:nil];
                }
                
                @synchronized(cacheDictionary) {
                    [cacheDictionary removeObjectForKey:cacheKey];
                    
                    
                    /* remove similar url cache */
                    if ([[NSString parameterToString:parameters] hasPrefix:@"?"]) { // make sure `query` parameter is the condition of url condition
                        NSArray *cacheKeys = [cacheDictionary allKeys];
                        for (int i = 0; i < [cacheKeys count]; i++) {
                            NSString *tmpKey = [cacheKeys objectAtIndex:i];
                            if ([tmpKey hasPrefix:urlKey]) {
                                NSString *tmpPath = [[NSString documentsDirectoryWithTrailingSlash:NO] stringByAppendingPathComponent:[modelDict objectForKey:kLocalPath]];
                                if ([fileManager fileExistsAtPath:tmpPath]) {
                                    [fileManager removeItemAtPath:tmpPath error:nil];
                                }
                                [cacheDictionary removeObjectForKey:tmpKey];
                            }
                        }
                    }
                    
                }
                [self saveCacheDictionary];
                
            } else {
                fileHasBeenCached = YES;
            }
            
        }
        
        if (fileHasBeenCached) {
            expiryDate = [modelDict objectForKey:kCacheExpiryDate];
            cacheEndDate = [modelDict objectForKey:kCacheEndDate];
            cacheStartDate = [modelDict objectForKey:kCacheStartDate];
            localPath = [[NSString documentsDirectoryWithTrailingSlash:NO] stringByAppendingPathComponent:[modelDict objectForKey:kLocalPath]];
            expiresInSeconds = [modelDict objectForKey:kCacheExpiresInSeconds];
            
            if (cacheStartDate != nil && cacheEndDate != nil) {
                cachedFileIsFullyDownloaded = YES;
            }
            
            if (expiresInSeconds != nil && cacheEndDate == nil) {
                cachedFileIsBeingDownloaded = YES;
            }
            
            if (expiryDate != nil &&
                [now timeIntervalSinceDate:expiryDate] > 0.0 && [FileCacheReachability canConnectNetwork]) {
                cachedFileHasExpired = YES;
            }
            
            if (cachedFileHasExpired == NO) {
                if ([fileManager fileExistsAtPath:localPath]) {
                    cachedFileExists = YES;
                    cachedFileData = [FileCache readPath:localPath];
                    if (cachedFileData != nil) {
                        cachedFileDataCanbenLoaded = YES;
                    }
                }
                
                if (updateCache) {
                    
                    NSDate *newExpiryDate = [NSDate dateWithTimeIntervalSinceNow:mustExpireInSeconds];
                    
                    NSLog(@"Updating the expiry date from %@ to %@.", expiryDate, newExpiryDate);
                    
                    [modelDict setObject:newExpiryDate
                                  forKey:kCacheExpiryDate];
                    NSNumber *expires = [NSNumber numberWithFloat:mustExpireInSeconds];
                    [modelDict setObject:expires
                                  forKey:kCacheExpiresInSeconds];
                }
            }
        }
        
        if (cachedFileIsBeingDownloaded == YES) {
            NSLog(@"cacheing...");
            return;
        }
        
        if (fileHasBeenCached) {
            
            if (cachedFileHasExpired == NO &&
                cachedFileExists == YES &&
                cachedFileDataCanbenLoaded == YES &&
                cachedFileData != nil &&
                cachedFileIsFullyDownloaded == YES) {
                
                if (self.completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.completionHandler([cachedFileData mutableCopy], YES, nil);
                    });
                }
                
                return;
            } else {
                @synchronized(self.cacheDictionary) {
                    [self.cacheDictionary removeObjectForKey:cacheKey];
                }
                
                [self saveCacheDictionary];
            }
        }
        
        /* downloading */
        NSNumber *expires = [NSNumber numberWithFloat:mustExpireInSeconds];
        
        NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
        [newDictionary setObject:expires forKey:kCacheExpiresInSeconds];
        
        localPath = [cacheKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        localPath = [localPath stringByReplacingOccurrencesOfString:@"://"
                                                         withString:@""];
        localPath = [localPath stringByReplacingOccurrencesOfString:@"/"
                                                         withString:@"{1}"];
        localPath = [localPath stringByAppendingPathExtension:@"cache"];
        
        [newDictionary setObject:localPath
                          forKey:kLocalPath];
        [newDictionary setObject:now
                          forKey:kCacheStartDate];
        @synchronized(self.cacheDictionary) {
            [self.cacheDictionary setObject:newDictionary
                                     forKey:cacheKey];
        }
        
        [self saveCacheDictionary];
        
        CacheModel *model = [[CacheModel alloc] init];
        model.delegate = self;
        if (cacheObject && !forceRequest) {
            [model startCachedObject:cacheObject withRemoteURL:cacheKey];
        } else {
            [model Method:method URLString:URLString parameters:parameters];
        }
    });
    
    
}

- (id)getCacheWithURL:(NSString *)url
            parameter:(id)parameter
     updateExpiryDate:(BOOL)updateExpiryDate
{
    NSString *query = [[NSString parameterToString:parameter] md5];
    
    NSString *cacheKey = [[NSString stringWithFormat:@"%@%@", url, query] lowercaseString];
    NSMutableDictionary *dict = [cacheDictionary objectForKey:cacheKey];
    NSString *localPath = [[NSString documentsDirectoryWithTrailingSlash:NO] stringByAppendingPathComponent:[dict objectForKey:kLocalPath]];
    NSDate *now = [NSDate date];
    NSDate *cacheEndDate = [dict objectForKey:kCacheEndDate];
    NSDate *expiryDate = [dict objectForKey:kCacheExpiryDate];
    if (cacheEndDate != nil && ([now timeIntervalSinceDate:expiryDate] <= 0.0)) {
        NSNumber *expiresInSeconds = [dict objectForKey:kCacheExpiresInSeconds];
        NSTimeInterval expireSeconds = [expiresInSeconds floatValue];
        [dict setObject:[NSDate dateWithTimeIntervalSinceNow:expireSeconds] forKey:kCacheExpiryDate];
        if ([fileManager fileExistsAtPath:localPath]) {
            return [FileCache readPath:localPath];
        }
    }
    
    return nil;
}

// remove all cache
- (BOOL)clear
{
    @synchronized(self) {
        NSMutableArray *delKeys = [NSMutableArray array];
        for (id key in cacheDictionary) {
            if ([key isKindOfClass:[NSString class]]) {
                
                NSMutableDictionary *dict = [cacheDictionary objectForKey:key];
                NSString *localPath = [[NSString documentsDirectoryWithTrailingSlash:NO] stringByAppendingPathComponent:[dict objectForKey:kLocalPath]];
                
                if (localPath != nil && localPath.length > 0) {
                    if ([fileManager fileExistsAtPath:localPath]) {
                        [fileManager removeItemAtPath:localPath error:nil];
                    }
                }
                
                [delKeys addObject:key];
            }
        }
        
        for (NSInteger i = 0; i < [delKeys count]; i++) {
            [cacheDictionary removeObjectForKey:[delKeys objectAtIndex:i]];
        }
    }
    
    return [self saveCacheDictionary];
}

#pragma mark - CacheModelDelegate
- (void)cacheModelDelegateSucceeded:(CacheModel *)paramSender
                      withRemoteURL:(NSURL *)paramRemoteURL
                     responseObject:(id)responseObject
{
    dispatch_async(_cacheQueue, ^{
        NSMutableDictionary *dictionary = [self.cacheDictionary objectForKey:[paramRemoteURL absoluteString]];
        if (dictionary == nil) return;
        
        NSDate *now = [NSDate date];
        NSNumber *expiresInSeconds = [dictionary objectForKey:kCacheExpiresInSeconds];
        NSTimeInterval expirySeconds = [expiresInSeconds floatValue];
        [dictionary setObject:[NSDate date] forKey:kCacheEndDate];
        [dictionary setObject:[now dateByAddingTimeInterval:expirySeconds] forKey:kCacheExpiryDate];
        
        [self saveCacheDictionary];
        
        NSString *localURL = [[NSString documentsDirectoryWithTrailingSlash:NO] stringByAppendingPathComponent:[dictionary objectForKey:kLocalPath]];
        
        if ([FileCache cacheObject:responseObject path:localURL]) {
            NSLog(@"succeeded to cache response");
        } else {
            NSLog(@"failed to cache response");
        }
    });
    
    if (self.completionHandler) {
        self.completionHandler(responseObject, NO, nil);
    }
    
}

- (void)cacheModelDelegateFailed:(CacheModel *)paramSender
                       remoteURL:(NSURL *)paramRemoteURL
                       withError:(NSError *)paramError
{
    if (self.completionHandler) {
        self.completionHandler(nil, NO, paramError);
    }
    dispatch_async(_cacheQueue, ^{
        [self.cacheDictionary removeObjectForKey:[paramRemoteURL absoluteString]];
        [self saveCacheDictionary];
    });
}

@end
