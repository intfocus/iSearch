//
//  HttpUtils.h
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  说明:
//  处理网络相关的代码合集.

#ifndef iLogin_HttpUtils_h
#define iLogin_HttpUtils_h

#import <UIKit/UIKit.h>
#import "sys/utsname.h"

////https://github.com/tonymillion/Reachability
//#import "Reachability.h"


@interface HttpUtils : NSObject

+ (NSString *) httpGet: (NSString *) path;
+ (NSString *) httpPost: (NSString *) path Data: (NSString *) data;
+ (NSString *) login: (NSString *) data;


+ (BOOL) isNetworkAvailable;
+ (NSString *) networkType;
+ (NSString*) devicePlatform;

@end

#endif
