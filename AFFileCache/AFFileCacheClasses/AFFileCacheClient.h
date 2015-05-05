//
//  AFFileCacheClient.h
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "FileCacheDefines.h"

@interface AFFileCacheClient : AFHTTPSessionManager

+ (instancetype)clientManager;

- (void)configBaseURL:(NSString *)baseURL;

/**
 Creates and runs an `NSURLSessionDataTask` with a `Method` request.
 
 @param kAFNetworkingMethod The method for request URL.
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (NSURLSessionDataTask *)Method:(kAFNetworkingMethod)method
                       URLString:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
