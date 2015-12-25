//
//  HWNetworkDataCache.m
//  HWNetworkDemo
//
//  Created by HanWei on 15/12/25.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "HWNetworkDataCacheManager.h"

@interface HWNetworkDataCacheManager ()

@end

@implementation HWNetworkDataCacheManager

+ (HWNetworkDataCacheManager *)sharedDataCacheManager
{
    static HWNetworkDataCacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

@end
