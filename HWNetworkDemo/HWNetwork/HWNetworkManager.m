//
//  HWNetworkManager.m
//  HWNetworkDemo
//
//  Created by HanWei on 15/12/25.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "HWNetworkManager.h"
#import "HWNetworkDataCacheManager.h"

@interface HWNetworkManager ()

@property (nonatomic, strong) HWNetworkDataCacheManager *dataCache;

@end

@implementation HWNetworkManager



#pragma mark - getter
- (HWNetworkDataCacheManager *)dataCache
{
    return [HWNetworkDataCacheManager sharedDataCacheManager];
}

@end
