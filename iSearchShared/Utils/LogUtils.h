//
//  LogUtils.h
//  WebView-1
//
//  Created by lijunjie on 15/6/12.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_LogUtils_h
#define iSearch_LogUtils_h

// NSLog扩展，显示__FILE__:__LINE__等信息
#define DEBUG 1
#import "ExtendNSLogFunctionality.h"
#define DEBUG_CHECKER NSLog(@"%s#%d", __FILE__, __LINE__);

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 *  LogUtils
 */
@interface LogUtils : NSObject
/**
 *  调试使用
 *
 *  @param error error
 *  @param info  调试说明信息
 */
+ (void)printError:(NSError *)error Info:(NSString *) info;
@end


#endif
