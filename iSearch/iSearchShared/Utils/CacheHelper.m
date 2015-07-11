//
//  CacheHelper.m
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "CacheHelper.h"
#import "const.h"
#import "FileUtils.h"

@implementation CacheHelper
/**
 *  读取本地缓存通知公告数据
 *
 *  @return 数据列表
 */
+ (NSMutableDictionary *)readNotifications {
    NSString *cachePath = [self notificationCachePath];
    
    NSMutableDictionary *notificationDatas = [[NSMutableDictionary alloc] init];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        notificationDatas = [FileUtils readConfigFile:cachePath];
    }
    
    return notificationDatas;
}
/**
 *  缓存服务器获取到的数据
 *
 *  @param notificationDatas 服务器获取到的数据
 */
+ (void)writeNotifications:(NSMutableDictionary *)notificationDatas {
    if(!notificationDatas) { return; }
    [FileUtils writeJSON:notificationDatas Into:[self notificationCachePath]];
}

+ (NSString *)notificationCachePath {
    return [FileUtils getPathName:NOTIFICATION_DIRNAME FileName:NOTIFICATION_CACHE];
}



/**
 *  目录本地缓存数据
 *
 *  @param type category,slide
 *  @param ID   ID
 *
 *  @return 缓存数据
 */
+ (NSMutableArray *) readContents:(NSString *)type ID:(NSString *)ID {
    NSString *cacheName = [self contentCacheName:type ID:ID];
    NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        NSMutableDictionary *cacheJSON = [FileUtils readConfigFile:cachePath];
        mutableArray = cacheJSON[CONTENT_FIELD_DATA];
    }
    return mutableArray;
}

/**
 *  服务器获取的目录数据写入本地缓存文件
 *
 *  @param data 服务器获取数据
 *  @param type category,slide
 *  @param ID   ID
 */
+ (void)writeContents:(NSMutableDictionary *)contentDatas Type:(NSString *)type ID:(NSString *)ID {
    if(!contentDatas) { return; }
    NSString *cacheName = [CacheHelper contentCacheName:type ID:ID];
    NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
    [FileUtils writeJSON:contentDatas Into:cachePath];
}
/**
 *  目录信息缓存文件名称
 *
 *  @param type   category,slide
 *  @param ID     ID
 *
 *  @return cacheName
 */
+ (NSString *)contentCacheName:(NSString *)type
                            ID:(NSString *)ID {
    return [NSString stringWithFormat:@"%@-%@.cache",type, ID];
}
@end
