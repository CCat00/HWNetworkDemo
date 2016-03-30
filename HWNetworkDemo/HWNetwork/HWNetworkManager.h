//
//  HWNetworkManager.h
//  HWNetworkDemo
//
//  Created by HanWei on 15/12/25.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWNetworkDefine.h"

typedef NS_ENUM(NSInteger, RequestMethod) {
    RequestMethodGET = 0,
    RequestMethodPOST,
//    RequestMethodHEAD,
//    RequestMethodPUT,
//    RequestMethodDELETE,
//    RequestMethodPATCH
};


typedef void(^RequestSucceedBlk)(id result);
typedef void(^RequestFaildBlk)(NSError *error);


@interface HWUtils : NSObject

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)appVersionString;

@end

@interface HWNetworkManager : NSObject

//@property (readonly, nonatomic, strong) NSString *baseURL;
//@property (nonatomic, copy) RequestSucceedBlk requestSucceedBlk;
//@property (nonatomic, copy) RequestFaildBlk requestFaildBlk;

+ (HWNetworkManager *)sharedManager;

- (void)sendRequest:(NSString *)url
      requestMethod:(RequestMethod)method
         parameters:(id)para
      needLoadCache:(BOOL)isLoadCache
  requestSucceedBlk:(RequestSucceedBlk)requestSucceedBlk
    requestFaildBlk:(RequestFaildBlk)requestFaildBlk;

- (void)cancleTaskWithURL:(NSString *)url;

- (void)cancleAllTask;

@end
