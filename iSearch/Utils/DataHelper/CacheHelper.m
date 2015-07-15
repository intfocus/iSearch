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
    NSString *cacheName = @"notifiction.cache";
    return [FileUtils getPathName:CACHE_DIRNAME FileName:cacheName];
}


/**
 *  目录本地缓存数据
 *
 *  @param type category,slide
 *  @param ID   ID
 *
 *  @return 缓存数据
 */
+ (NSMutableArray *)readContents:(NSString *)type ID:(NSString *)ID {
    NSString *cachePath = [self contentCachePath:type ID:ID];
    
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
    NSString *cachePath = [self contentCachePath:type ID:ID];
    [FileUtils writeJSON:contentDatas Into:cachePath];
}
/**
 *  目录信息缓存文件文件路径;
 *  同一个分类ID,下载它的子分类集与子文档集通过两个不同的api链接，所以会有两个缓存文件。
 *
 *  @param type   category,slide
 *  @param ID     ID
 *
 *  @return cacheName
 */
+ (NSString *)contentCachePath:(NSString *)type ID:(NSString *)ID {
    NSString *cacheName = [NSString stringWithFormat:@"content-%@-%@.cache",type, ID];
    NSString *cachePath = [FileUtils getPathName:CACHE_DIRNAME FileName:cacheName];
    return cachePath;
}
@end
