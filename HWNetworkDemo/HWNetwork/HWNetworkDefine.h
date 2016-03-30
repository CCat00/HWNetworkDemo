//
//  HWNetworkDefine.h
//  HWNetworkDemo
//
//  Created by 韩威 on 16/3/30.
//  Copyright © 2016年 AndLiSoft. All rights reserved.
//

#ifndef HWNetworkDefine_h
#define HWNetworkDefine_h

#ifdef DEBUG
#define DEBUGLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DEBUGLog(...)
#endif

#define kWebRequestTimeOut 30
#define kWebBaseURLString @"https://api.douban.com"


#endif /* HWNetworkDefine_h */
