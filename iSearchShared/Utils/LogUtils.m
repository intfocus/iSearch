//
//  LogUtils.m
//  WebView-1
//
//  Created by lijunjie on 15/6/12.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "LogUtils.h"

@implementation LogUtils

/**
 *  调试使用
 *
 *  @param error error
 *  @param info  调试说明信息
 */
+ (void)printError:(NSError *)error Info:(NSString *) info {
    if(error)
        NSLog(@"%@ when %@", info, [error localizedDescription]);
}


@end