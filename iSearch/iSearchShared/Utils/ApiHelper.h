//
//  ApiHelper.h
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  仅处理与服务器获取信息交互
 *  服务器获取失败或无网络时，交给CacheHelper
 */
@interface ApiHelper : NSObject
/**
 *  用户登录难
 *
 *  @param UID user ID
 *
 *  @return 用户信息
 */
+ (NSMutableDictionary *)login:(NSString *)UID;

/**
 *  目录同步,获取某分类下的文档列表
 *
 *  @return 数据列表
 */
+ (NSMutableDictionary *)slides:(NSString *)categoryID DeptID:(NSString *)deptID;

/**
 *  目录同步,获取某分类下的分类列表
 *
 *  @return 数据列表
 */
+ (NSMutableDictionary *)categories:(NSString *)categoryID DeptID:(NSString *)deptID;

/**
 *  通知公告列表
 *
 *  @return 数据列表
 */
+ (NSMutableDictionary *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID;
@end
