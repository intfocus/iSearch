//
//  ApiUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiUtils.h"

#import "const.h"
#import "User.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "HttpUtils.h"
#import "ExtendNSLogFunctionality.h"

@interface ApiUtils()

@end
@implementation ApiUtils



+ (NSMutableDictionary *)notifications {
    User *user = [[User alloc] init];
    
    // 服务器获取成功则写入cache,否则读取cache
    NSString *cachePath = [FileUtils getPathName:NOTIFICATION_DIRNAME FileName:NOTIFICATION_CACHE];
    
    // 从服务器端获取[公告通知], 不判断网络环境，获取不到则取本地cache
    NSString *currentDate = [DateUtils dateToStr:[NSDate date] Format:DATE_SIMPLE_FORMAT];
    NSString *notifiction_url = [NSString stringWithFormat:@"%@?%@=%@&%@=%@", NOTIFICATION_URL_PATH, NOTIFICATION_PARAM_DEPTID, user.deptID, NOTIFICATION_PARAM_DATESTR, currentDate];
    
    NSString *response = [HttpUtils httpGet: notifiction_url];
    NSError *error;
    // 确保该实例可以被读取
    NSMutableDictionary *notificationDatas = [[NSMutableDictionary alloc] init];
    notificationDatas = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSErrorPrint(error, @"http get notifications and convert into json.");
    
    // 情况一: 服务器获取公告通知成功
    if(!error) {
        // 有时文件属性原因，能写入但无法读取
        // 先删除文件再写入
        if([FileUtils checkFileExist:cachePath isDir:false])
            [FileUtils removeFile:cachePath];
        
        // 写入本地作为cache
        [response writeToFile:cachePath atomically:true encoding:NSUTF8StringEncoding error:&error];
        NSErrorPrint(error, @"notifications cache write");
        
        // 情况二: 如果缓存文件存在则读取
    } else if([FileUtils checkFileExist:cachePath isDir:false]) {
        NSErrorPrint(error, @"http get notifications list");
        
        // 读取本地cache
        NSLog(@"%@", cachePath);
        NSString *cacheContent = [NSString stringWithContentsOfFile:cachePath usedEncoding:NULL error:&error];
        NSErrorPrint(error, @"notifications cache read");
        if(!error) {
            // 解析为json数组
            notificationDatas = [NSJSONSerialization JSONObjectWithData:[cacheContent dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            NSErrorPrint(error, @"notifications cache parse into json");
        }
        // 情况三:
    } else {
        NSLog(@"<# HttpGET and cache all failed!>");
    }
    return notificationDatas;
}

@end