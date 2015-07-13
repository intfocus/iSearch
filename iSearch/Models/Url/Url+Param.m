//
//  Url+Param.m
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "Url+Param.h"
#import "const.h"
#import "ExtendNSLogFunctionality.h"

@implementation Url (Param)

#pragma mark - GET

/**
 *  用户登录经第三方验证成功，会通过UIWebView返回cookie值
 *
 *  @param UID user ID
 *
 *  @return urlString
 */
+ (NSString *)login:(NSString *)UID {
    BOOL isParamsValid = CheckParams(GenFormat(1), UID);
    if(!isParamsValid) {
        UID = (NSString *)psd(UID, @"null");
    }
                              
    NSString *urlString  = [[Url alloc] init].login;
    NSDictionary *params = @{LOGIN_PARAM_UID: UID};

    return [Url UrlConcate:urlString Param:params];
}
/**
 *  目录同步,获取某分类下的文档列表
 *
 *  @return urlString
 */
+ (NSString *)slides:(NSString *)categoryID DeptID:(NSString *)deptID {
    BOOL isParamsValid = CheckParams(GenFormat(2), categoryID, deptID);
    if(!isParamsValid) {
        categoryID = (NSString *)psd(categoryID, @"null");
        deptID     = (NSString *)psd(deptID, @"null");
    }
    
    NSString *urlString  = [[Url alloc] init].slides;
    NSDictionary *params = @{CONTENT_PARAM_DEPTID: deptID, CONTENT_PARAM_FILE_CATEGORYID:categoryID};
    
    return [Url UrlConcate:urlString Param:params];
}
/**
 *  目录同步,获取某分类下的分类列表
 *
 *  @return urlString
 */
+ (NSString *)categories:(NSString *)categoryID DeptID:(NSString *)deptID {
    BOOL isParamsValid = CheckParams(GenFormat(2), categoryID, deptID);
    if(!isParamsValid) {
        categoryID = (NSString *)psd(categoryID, @"null");
        deptID     = (NSString *)psd(deptID, @"null");
    }
    
    NSString *urlString  = [[Url alloc] init].categories;
    NSDictionary *params = @{CONTENT_PARAM_DEPTID: deptID, CONTENT_PARAM_PARENTID:categoryID};
    
    return [Url UrlConcate:urlString Param:params];
}
/**
 *  目录同步界面，点击文档进入下载
 *
 *  @return urlString
 */
+ (NSString *)slideDownload:(NSString *)slideID {
    BOOL isParamsValid = CheckParams(GenFormat(1), slideID);
    if(!isParamsValid) {
        slideID = (NSString *)psd(slideID, @"null");
    }
    
    NSString *urlString  = [[Url alloc] init].slideDownload;
    NSDictionary *params = @{CONTENT_PARAM_FILE_DWONLOADID: slideID};
    
    return [Url UrlConcate:urlString Param:params];
}

/**
 *  批量下载时，获取该用户有权限看到的所有文档列表
 *
 *  @return urlString
 */
+ (NSString *)slideList:(NSString *)deptID {
    BOOL isParamsValid = CheckParams(GenFormat(1), deptID);
    if(!isParamsValid) {
        deptID = (NSString *)psd(deptID, @"null");
    }
    
    NSString *urlString  = [[Url alloc] init].slideList;
    NSDictionary *params = @{OFFLINE_PARAM_DEPTID: deptID};
    
    return [Url UrlConcate:urlString Param:params];
}
/**
 *  通知公告列表
 *
 *  @return urlString
 */
+ (NSString *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID {
    BOOL isParamsValid = CheckParams(GenFormat(2), currentDate, depthID);
    if(!isParamsValid) {
        currentDate = (NSString *)psd(currentDate, @"null");
        depthID     = (NSString *)psd(depthID, @"null");
    }
    
    NSString *urlString  = [[Url alloc] init].notifications;
    NSDictionary *params = @{NOTIFICATION_PARAM_DEPTID: depthID, NOTIFICATION_PARAM_DATESTR:currentDate};
    
    return [Url UrlConcate:urlString Param:params];
}



#pragma mark - GET# assistant methods
+ (NSString *)UrlConcate:(NSString *)url Param:(NSDictionary *)params {
    NSString *paramString = [Url _parameters:params];
    NSString *urlString   = [NSString stringWithFormat:@"%@?%@", url, paramString];
    return urlString;
}


+ (NSString *)_parameters:(NSDictionary *)params {
    // additional params
    NSMutableDictionary *baseParams = [[NSMutableDictionary alloc] init];
    [baseParams addEntriesFromDictionary:@{PARAM_LANG: APP_LANG}];
    [baseParams addEntriesFromDictionary:params];
    
    NSString *value;
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    for(NSString *key in baseParams) {
        value = [baseParams objectForKey:key];
        [paramArray addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    return [paramArray componentsJoinedByString:@"&"];
}

#pragma mark - POST
/**
 *  行为记录
 *
 *  @return urlString
 */
+ (NSString *)actionLog {
    return [[Url alloc] init].actionLog;
}
@end
