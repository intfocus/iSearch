//
//  ApiHelper.m
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ApiHelper.h"
#import "Url+Param.h"
#import "HttpUtils.h"
#import "HttpResponse.h"
#import "ExtendNSLogFunctionality.h"

@implementation ApiHelper
/**
 *  用户登录难
 *
 *  @param UID user ID
 *
 *  @return 用户信息
 */
+ (HttpResponse *)login:(NSString *)UID {
    NSString *urlString = [Url login:UID];
    return [HttpUtils httpGet:urlString];
}

/**
 *  目录同步,获取某分类下的文档列表
 *
 *  @return 文档列表
 */
+ (HttpResponse *)slides:(NSString *)categoryID DeptID:(NSString *)deptID {
    NSString *urlString = [Url slides:categoryID DeptID:deptID];
    return [HttpUtils httpGet:urlString];
}
/**
 *  目录同步,获取某分类下的分类列表
 *
 *  @return 分类列表
 */
+ (HttpResponse *)categories:(NSString *)categoryID DeptID:(NSString *)deptID {
    NSString *urlString = [Url categories:categoryID DeptID:deptID];
    return [HttpUtils httpGet:urlString];
}

/**
 *  通知公告列表
 *
 *  @return 数据列表
 */
+ (HttpResponse *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID {
    NSString *urlString = [Url notifications:currentDate DeptID:depthID];
    return [HttpUtils httpGet:urlString];
}
/**
 *  用户操作记录
 *
 *  @param params ActionLog.toParams
 *
 *  @return 服务器响应信息
 */
+ (HttpResponse *)actionLog:(NSMutableDictionary *)params {
    params[@"AppName"] = @"iSearch";
    return [HttpUtils httpPost:[Url actionLog] Params:params];
}


@end
