//
//  ViewController.m
//  AFFileCache
//
//  Created by TaoPing on 15-4-10.
//  Copyright (c) 2015年 TaoPing. All rights reserved.
//

#import "ViewController.h"
#import "AFAppDotNetAPIClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSString *url = [[NSString stringWithFormat:@"%@", @"http://api.map.baidu.com/telematics/v3/weather?location=北京&output=json&ak=W69oaDTCfuGwzNwmtVvgWfGH"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[AFAppCacheAPIClient sharedClient] downloadWithMethod:kAFNetworkingMethodGET URLString:url parameters:nil mustExpireInSeconds:120 updateCache:NO forceRequest:NO completion:^(id responseObject, BOOL isCached, NSError *error) {
        NSLog(@"response object %@", responseObject);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
