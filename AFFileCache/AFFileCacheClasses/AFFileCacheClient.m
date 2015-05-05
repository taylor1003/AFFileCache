//
//  AFFileCacheClient.m
//  AFFileCache
//
//  Created by TaoPing on 15-4-17.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import "AFFileCacheClient.h"

@interface AFFileCacheClient ()

@property (readwrite, nonatomic, strong) NSURL *baseURL;

@end

@implementation AFFileCacheClient

@synthesize baseURL = _baseURL;

+ (instancetype)clientManager {
    static AFFileCacheClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFFileCacheClient alloc] init];
        //        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@""]];
        //        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    });
    
    return _sharedClient;
}

- (void)configBaseURL:(NSString *)baseURL
{
    if (self.baseURL == nil) {
        self.baseURL = [NSURL URLWithString:baseURL];
    }
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(dataTask, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    return dataTask;
}

- (NSURLSessionDataTask *)Method:(kAFNetworkingMethod)method
                       URLString:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask *, id))success
                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSURLSessionDataTask *dataTask;
    switch (method) {
        case kAFNetworkingMethodGET:
            dataTask = [self GET:URLString parameters:parameters success:success failure:failure];
            break;
        case kAFNetworkingMethodPOST:
            dataTask = [self POST:URLString parameters:parameters success:success failure:failure];
            break;
        case kAFNetworkingMethodPUT:
            dataTask = [self PUT:URLString parameters:parameters success:success failure:failure];
            break;
        case kAFNetworkingMethodPATCH:
            dataTask = [self PATCH:URLString parameters:parameters success:success failure:failure];
            break;
        case kAFNetworkingMethodDELETE:
            dataTask = [self DELETE:URLString parameters:parameters success:success failure:failure];
            break;
        default:
            break;
    }
    
    return dataTask;
}

@end
