//
//  HWNetworkManager.m
//  HWNetworkDemo
//
//  Created by HanWei on 15/12/25.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "HWNetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonCrypto.h>
@implementation HWUtils

+ (NSString *)md5StringFromString:(NSString *)string {
    if(string == nil || [string length] == 0)
        return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

+ (NSString *)appVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


@end

@interface HWNetworkManager () {
//    NSString *_requestURL;
//    RequestMethod _requestMethod;
}

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

//开始请求
- (void)sendRequest:(NSString *)url
      requestMethod:(RequestMethod)method
         parameters:(id)para
      needLoadCache:(BOOL)isLoadCache
  requestSucceedBlk:(RequestSucceedBlk)requestSucceedBlk
    requestFaildBlk:(RequestFaildBlk)requestFaildBlk

{
    NSString *key = [self sessionTaskHashKey:url];
    NSURLSessionTask *task = self.tasks[key];
    if (task && task.state == NSURLSessionTaskStateRunning) {
        
        NSLog(@"这个任务正在执行");
        return;
    }
    
    NSString *pxURL = [NSString stringWithFormat:@"%@%@",_baseURL,url];
    
    //开启菊花
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    switch (method) {
        case RequestMethodGET:
        {
            task = [self.sessionManager GET:pxURL parameters:para progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self handleRequestResult:method url:url needLoadCache:isLoadCache result:responseObject error:nil requestSucceedBlk:requestFaildBlk requestFaildBlk:nil];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self handleRequestResult:method url:url needLoadCache:isLoadCache result:nil error:error requestSucceedBlk:nil requestFaildBlk:requestFaildBlk];
            }];
        }
            break;
            
        case RequestMethodPOST:
        {
            task = [self.sessionManager POST:pxURL parameters:para progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
               [self handleRequestResult:method url:url needLoadCache:isLoadCache result:responseObject error:nil requestSucceedBlk:requestFaildBlk requestFaildBlk:nil];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self handleRequestResult:method url:url needLoadCache:isLoadCache result:nil error:error requestSucceedBlk:nil requestFaildBlk:requestFaildBlk];
            }];
        }
            break;
        default:
            break;
    }
    
    [self addTask:task url:url];
}


#pragma mark - private
- (NSString *)sessionTaskHashKey:(NSString *)url
{
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[url hash]];
    return key;
}

- (void)addTask:(NSURLSessionTask *)task url:(NSString *)url
{
    NSString *key = [self sessionTaskHashKey:url];
    @synchronized(self) {
        self.tasks[key] = task;
    }
}

- (void)removeTask:(NSString *)url
{
    NSString *key = [self sessionTaskHashKey:url];
    @synchronized(self) {
        [self.tasks removeObjectForKey:key];
    }
}

- (void)handleRequestResult:(RequestMethod)requestMethod
                        url:(NSString *)url
              needLoadCache:(BOOL)isLoadCach
                     result:(id)result
                      error:(NSError *)error
          requestSucceedBlk:(RequestSucceedBlk)requestSuccedBlk
            requestFaildBlk:(RequestFaildBlk)requestFaildBlk
{
    NSString *cacheName = [self cacheFileName:requestMethod url:url];
    NSString *path = [self cacheFilePath:cacheName];
    
    if (requestSuccedBlk) {
        //请求成功
        //1.缓存数据
        if (result) {
            [NSKeyedArchiver archiveRootObject:result toFile:path];
        }
        //2.回调
        requestSuccedBlk(result);
    }
    
    if (requestFaildBlk) {
        //请求失败
        //1.如果需要加载缓存就回调缓存
        if (isLoadCach) {
            id cacheData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            if (cacheData) {
                requestSuccedBlk(cacheData);
            }
        }
        requestFaildBlk(error);
    }
    
    [self removeTask:url];
    //关闭菊花
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}


#pragma mark - public
- (void)cancleTaskWithURL:(NSString *)url
{
    NSString *key = [self sessionTaskHashKey:url];
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


#pragma mark - 缓存相关
- (void)checkFilePath:(NSString *)path
{
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        [self createFilePath:path];
    }
    else {
        if (!isDir) {
            __autoreleasing NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            if (error) {
                NSLog(@"remove file failed. error == %@", error);
            }
            [self createFilePath:path];
        }
    }
}

- (void)createFilePath:(NSString *)path
{
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
        NSLog(@"create filePath failed. error == %@", error);
    }
}

- (NSString *)cacheFileName:(RequestMethod)requestMethod url:(NSString *)url
{
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ AppVersion:%@", (long)requestMethod, _baseURL, url, [HWUtils appVersionString]];
    NSString *cacheFileName = [HWUtils md5StringFromString:requestInfo];
    return cacheFileName;
}

- (NSString *)cacheFilePath:(NSString *)cacheName
{
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [cachesPath stringByAppendingPathComponent:@"HWNetworkCache"];
    [path stringByAppendingPathComponent:cacheName];
    [self checkFilePath:path];
    return path;
}

//- (void)cacheResponseToFile:(id)response
//{
//    if (response) {
////        [NSKeyedArchiver archiveRootObject:response toFile:[self cacheFilePath]];
//    }
//}

#pragma mark - getter
- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
    }
    return _sessionManager;
}

@end
