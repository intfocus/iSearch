//
//  CacheHelper.h
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  处理本地缓存信息，与ApiHelper对应
 */
@interface CacheHelper : NSObject
/**
 *  读取本地缓存通知公告数据
 *
 *  @return 数据列表
 */
+ (NSMutableDictionary *)readNotifications;
/**
 *  缓存服务器获取到的数据
 *
 *  @param notificationDatas 服务器获取到的数据
 */
+ (void)writeNotifications:(NSMutableDictionary *)notificationDatas;
/**
 *  目录信息缓存文件文件路径
 *
 *  @param type   category,slide
 *  @param ID     ID
 *
 *  @return cacheName
 */
+ (NSString *)contentCachePath:(NSString *)type
                            ID:(NSString *)ID;
/**
 *  目录本地缓存数据
 *
 *  @param type category,slide
 *  @param ID   ID
 *
 *  @return 缓存数据
 */
+ (NSMutableArray *) readContents:(NSString *)type ID:(NSString *)ID;
/**
 *  服务器获取的目录数据写入本地缓存文件
 *
 *  @param data 服务器获取数据
 *  @param type category,slide
 *  @param ID   ID
 */
+ (void)writeContents:(NSMutableDictionary *)contentDatas Type:(NSString *)type ID:(NSString *)ID;
@end
