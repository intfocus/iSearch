//
//  Url+Param.h
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Url.h"
/**
 *  api链接传递参数，约束统一在此
 */
@interface Url (Param)

/**
 *  用户登录经第三方验证成功，会通过UIWebView返回cookie值
 *
 *  @param UID user ID
 *
 *  @return urlString
 */
+ (NSString *)login:(NSString *)UID;

/**
 *  目录同步,获取某分类下的文档列表
 *
 *  @return urlString
 */
+ (NSString *)slides:(NSString *)categoryID DeptID:(NSString *)deptID;

/**
 *  目录同步,获取某分类下的分类列表
 *
 *  @return urlString
 */
+ (NSString *)categories:(NSString *)categoryID DeptID:(NSString *)deptID;

/**
 *  目录同步界面，点击文档进入下载
 *
 *  @return urlString
 */
+ (NSString *)slideDownload:(NSString *)slideID;

/**
 *  批量下载时，获取该用户有权限看到的所有文档列表
 *
 *  @return urlString
 */
+ (NSString *)slideList:(NSString *)deptID;

/**
 *  通知公告列表
 *
 *  @return urlString
 */
+ (NSString *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID;

/**
 *  行为记录
 *
 *  @return urlString
 */
+ (NSString *)actionLog;
@end
