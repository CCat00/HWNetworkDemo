//
//  HWNetworkManager.m
//  HWNetworkDemo
//
//  Created by HanWei on 15/12/25.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "HWNetworkManager.h"
#import "HWNetworkDataCacheManager.h"
#import <AFNetworking/AFNetworking.h>

@interface HWNetworkManager ()

@property (nonatomic, strong) HWNetworkDataCacheManager *dataCache;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

/// [key:<NSString *> value:<NSURLSessionTask *>]
@property (nonatomic, strong) NSMutableDictionary *tasks;

@end

@implementation HWNetworkManager

+ (HWNetworkManager *)sharedManager
{
    static HWNetworkManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tasks = [NSMutableDictionary new];
    }
    return self;
}

- (void)sendWebRequest:(NSString *)url param:(id)param
{
    NSString *key = [self sessionTaskHashKeyRequestURL:url];
    
    NSURLSessionTask *task = self.tasks[key];
    
    if (task && task.state == NSURLSessionTaskStateRunning) {
        
        NSLog(@"这个任务正在执行");
    }
    else {
        

    
        task = [self.sessionManager GET:@"" parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    }
    
    [self addTask:task URL:url];
}

#pragma mark - private
- (NSString *)sessionTaskHashKeyRequestURL:(NSString *)url
{
    return [NSString stringWithFormat:@"%lu", [url hash]];
}

- (void)addTask:(NSURLSessionTask *)task URL:(NSString *)url
{
    NSString *key = [self sessionTaskHashKeyRequestURL:url];
    @synchronized(self) {
        self.tasks[key] = task;
    }
}

- (void)removeTask:(NSURLSessionTask *)task URL:(NSString *)url
{
    NSString *key = [self sessionTaskHashKeyRequestURL:url];
    @synchronized(self) {
        [self.tasks removeObjectForKey:key];
    }
}

- (void)handleSessionTaskResult:(NSURLSessionTask *)task
{
    
}

#pragma mark - public
- (void)cancleTaskWithURL:(NSString *)url
{
    NSString *key = [self sessionTaskHashKeyRequestURL:url];
    NSURLSessionTask *task = _tasks[key];
    [task cancel];
}

- (void)cancleAllTask
{
    NSDictionary *allTask = [_tasks copy];
    [allTask enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSURLSessionTask * _Nonnull task, BOOL * _Nonnull stop) {
      
        [task cancel];
    }];
}


#pragma mark - getter
- (HWNetworkDataCacheManager *)dataCache
{
    return [HWNetworkDataCacheManager sharedDataCacheManager];
}

@end
