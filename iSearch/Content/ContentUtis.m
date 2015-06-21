//
//  ContentUtis.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentUtils.h"
#import "FileUtils.h"
#import "HttpUtils.h"
#import "ExtendNSLogFunctionality.h"

#import "GMGridView.h"
#import "ViewSlide.h"
#import "ViewCategory.h"

@interface ContentUtils()

@end

@implementation ContentUtils
/**
 *  获取目录通过函数
 *
 *  @param deptID        <#deptID description#>
 *  @param categoryID    <#categoryID description#>
 *  @param localOrServer <#localOrServer description#>
 *
 *  @return <#return value description#>
 */
+ (NSMutableArray*)loadContentData:(NSString *)deptID
                        CategoryID:(NSString *)categoryID
                              Type:(NSString *)localOrServer {
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    
    if([localOrServer isEqualToString:LOCAL_OR_SERVER_LOCAL]) {
        categoryArray = [ContentUtils loadContentDataFromLocal:CONTENT_CATEGORY DeptID:deptID CategoryID:categoryID];
        fileArray     = [ContentUtils loadContentDataFromLocal:CONTENT_SLIDE DeptID:deptID CategoryID:categoryID];
    }
    else if([localOrServer isEqualToString:LOCAL_OR_SERVER_SREVER]) {
        categoryArray = [ContentUtils loadContentDataFromServer:CONTENT_CATEGORY DeptID:deptID CategoryID:categoryID];
        fileArray     = [ContentUtils loadContentDataFromServer:CONTENT_SLIDE DeptID:deptID CategoryID:categoryID];
    }
    else {
        NSLog(@"=BUG= not support localOrServer=%@", localOrServer);
    }
    if([categoryArray count] > 0) {
        categoryArray = [ContentUtils arraySortByID:categoryArray];
    }
    if([fileArray count] > 0) {
        fileArray = [ContentUtils arraySortByID:fileArray];
    }
    
    NSMutableSet *mergeSet = [NSMutableSet setWithArray:categoryArray];
    [mergeSet addObjectsFromArray:fileArray];
    NSArray *array = [mergeSet allObjects];
    
    return [NSMutableArray arrayWithArray:array];
}

+ (NSMutableArray *)arraySortByID:(NSMutableArray *)mutableArray {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:CONTENT_FIELD_ID ascending:YES];
    NSArray *array = [mutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    return [NSMutableArray arrayWithArray:array];
}

+ (NSMutableArray*)loadContentDataFromServer:(NSString *)type
                                      DeptID:(NSString *)deptID
                                  CategoryID:(NSString *)categoryID {
    NSError *error;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *urlPath = [[NSString alloc] init];
    NSString *response = [[NSString alloc] init];
    
    // 无网络直接返回空值
    if(![HttpUtils isNetworkAvailable]) {
        return mutableArray;
    }
    
    if([type isEqualToString:CONTENT_CATEGORY]) {
        urlPath = [NSString stringWithFormat:@"%@?lang=%@&%@=%@&%@=%@", CONTENT_URL_PATH, APP_LANG, CONTENT_PARAM_DEPTID, deptID, CONTENT_PARAM_PARENTID, categoryID];
    } else if([type isEqualToString:CONTENT_SLIDE]) {
        urlPath = [NSString stringWithFormat:@"%@?lang=%@&%@=%@&%@=%@", CONTENT_FILE_URL_PATH, APP_LANG, CONTENT_PARAM_DEPTID, deptID, CONTENT_PARAM_FILE_CATEGORYID, categoryID];
    } else {
        NSLog(@"Not Support [%@]", type);
        return mutableArray;
    }
    
    response = [HttpUtils httpGet: urlPath];
    NSMutableDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&error];
    NSErrorPrint(error, @"string convert into json");
    
    mutableArray = responseJSON[CONTENT_FIELD_DATA];
    
    // update local slide cache info
    if([type isEqualToString:CONTENT_SLIDE] && [mutableArray count] > 0) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *tmpDesc = [[NSMutableDictionary alloc] init];
        NSString *descPath = [[NSString alloc] init];
        NSString *cacheName = [[NSString alloc] init];
        NSString *cachePath = [[NSString alloc] init];
        for(tmpDict in mutableArray) {
            // update local slide desc when already download
            if([FileUtils checkSlideExist:tmpDict[CONTENT_FIELD_ID] Dir:SLIDE_DIRNAME Force:NO]) {
                descPath = [FileUtils slideDescPath:tmpDict[CONTENT_FIELD_ID] Dir:SLIDE_DIRNAME Klass:SLIDE_CONFIG_FILENAME];
                tmpDesc = [FileUtils readConfigFile:descPath];
                tmpDesc = [ContentUtils descConvert:tmpDict To:tmpDesc Type:CONTENT_DIRNAME];

                [FileUtils writeJSON:tmpDesc Into:descPath];
            }
            // write into cache then [view] slide info with popup view
            cacheName = [ContentUtils contentCacheName:type DeptID:deptID ID:categoryID];
            cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
            [FileUtils writeJSON:tmpDict Into:cachePath];
            /**
             *  warning: 此处不更新desc的SLIDE_DESC_LOCAL_UPDATEDAT,该信息用来记录用户的操作时候
             */
        }
    }
    NSString *cacheName = [ContentUtils contentCacheName:type DeptID:deptID ID:categoryID];
    NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
    
    // 解析成功、获取数据不为空时，写入本地缓存
    if(!error && [mutableArray count] > 0) {
        // 1. 请求目录返回josn字符串写入CONTENT_DIRNAME/deptID-categoryID-file.json
        [response writeToFile:cachePath atomically:true encoding:NSUTF8StringEncoding error:&error];
        NSErrorPrint(error, @"content category write into %@", cachePath);
    }
    
    return mutableArray;
}

/**
 *  NSMutableDictionary#setObject,forKey
 *  只有object不为nil才赋值
 *
 *  @param dict <#dict description#>
 *  @param obj  <#obj description#>
 *  @param key  <#key description#>
 *
 *  @return <#return value description#>
 */
+ (NSMutableDictionary *)mySet:(NSMutableDictionary *)dict
                        Object:(id)obj
                           Key:(NSString *)key {
    if(obj) {
        [dict setObject:obj forKey:key];
    } else {
        NSLog(@"Key#%@ is nil", key);
    }
    return dict;
    
}

/**
 *  缓存文件名称
 *
 *  @param type       category,slide?
 *  @param deptID     deptID
 *  @param categoryID categoryID
 *
 *  @return cacheName
 */
+ (NSString *)contentCacheName:(NSString *)type
                        DeptID:(NSString *)deptID
                    ID:(NSString *)categoryID {
    return [NSString stringWithFormat:@"%@-%@-%@.cache",deptID, categoryID, type];
}

/**
 *  获取获取信息格式统一转化为文档格式
 *
 *  @param tmpDict source dict
 *  @param tmpDesc target dict
 *  @param convertType 目录/离线下载
 *
 *  @return 文档格式
 */
+ (NSMutableDictionary *)descConvert:(NSMutableDictionary *)tmpDict
                                  To:(NSMutableDictionary *)tmpDesc
                                Type:(NSString *)convertType {
    if([convertType isEqualToString:CONTENT_DIRNAME]) {
        [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_NAME] Key:SLIDE_DESC_NAME];
        [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_DESC] Key:SLIDE_DESC_DESC];
        [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_TYPE] Key:SLIDE_DESC_TYPE];
        [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_TITLE] Key:CONTENT_FIELD_TITLE];
        [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_ZIPSIZE] Key:CONTENT_FIELD_ZIPSIZE];
        [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_CATEGORYID] Key:CONTENT_FIELD_CATEGORYID];
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_CATEGORYNAME] Key:OFFLINE_FIELD_CATEGORYNAME];
        [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_PAGENUM] Key:CONTENT_FIELD_PAGENUM];
        [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_CREATEDATE] Key:CONTENT_FIELD_CREATEDATE];
    }
    if([convertType isEqualToString:OFFLINE_DIRNAME]) {
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_NAME] Key:SLIDE_DESC_NAME];
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_DESC] Key:SLIDE_DESC_DESC];
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_TYPE] Key:SLIDE_DESC_TYPE];
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_TITLE] Key:CONTENT_FIELD_TITLE];
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_ZIPSIZE] Key:CONTENT_FIELD_ZIPSIZE];
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_CATEGORYID] Key:CONTENT_FIELD_CATEGORYID];
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_CATEGORYNAME] Key:OFFLINE_FIELD_CATEGORYNAME];
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_PAGENUM] Key:CONTENT_FIELD_PAGENUM];
        [ContentUtils mySet:tmpDesc Object:tmpDict[OFFLINE_FIELD_CREATEDATE] Key:CONTENT_FIELD_CREATEDATE];
    }
    return tmpDesc;
}

+ (NSMutableArray*)loadContentDataFromLocal:(NSString *)type
                                     DeptID:(NSString *)deptID
                                 CategoryID:(NSString *)categoryID {
    NSError *error;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *cacheContent = [[NSString alloc] init];
    NSString *cacheName = [ContentUtils contentCacheName:type DeptID:deptID ID:categoryID];
    NSString *cacheFilePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
    
    if(![FileUtils checkFileExist:cacheFilePath isDir:false]) {
        return mutableArray;
    }
    
    cacheContent = [NSString stringWithContentsOfFile:cacheFilePath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read cache#%@ %@", type, cacheContent);
    
    NSMutableDictionary *cacheJSON = [NSJSONSerialization JSONObjectWithData:[cacheContent dataUsingEncoding:NSUTF8StringEncoding]
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&error];
    NSErrorPrint(error, @"string convert into json");
    mutableArray = cacheJSON[CONTENT_FIELD_DATA];
    
    return mutableArray;
}
/**
 *  CONTENT_DIRNAME/id.json存在，读取该缓存信息加载目录
 *
 *  @param pathName 目录json缓存文件路径
 *
 *  @return 目录数据
 */
+ (NSMutableArray *)loadContentFromLocal:(NSString *)pathName {
    NSError *error;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *fileContent = [NSString stringWithContentsOfFile:pathName encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read file content");
    mutableArray = [NSJSONSerialization JSONObjectWithData:[fileContent dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingMutableContainers
                                                     error:&error];
    NSErrorPrint(error, @"string convert into json");
    return mutableArray;
}

/**
 *  获取某分类的基本信息。
 *  首页目录为指定CONTENT_ROOT_ID -> level1
 *  点击某分类categoryID -> level2
 *      此时导航栏需要显示该类的基本信息，但存放在level1分类ID的缓存文件中
 *  此时CONTENT_ROOT_ID为parentID
 *
 *  @param categoryID 当前目录的根ID
 *  @param parentID   上一层目录的根ID
 *  @param depthID    部门ID
 *
 *  @return categoryDict
 */

+ (NSMutableDictionary *)readCategoryInfo:(NSString *)categoryID
                                 ParentID:(NSString *)parentID
                                  DepthID:(NSString *)deptID {
    NSError *error;
    NSMutableDictionary *categoryDict = [[NSMutableDictionary alloc] init];
    NSString *cacheName = [ContentUtils contentCacheName:CONTENT_CATEGORY DeptID:deptID ID:parentID];
    NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
    NSString *cacheContent = [NSString stringWithContentsOfFile:cachePath encoding:NSUTF8StringEncoding error:&error];
    BOOL isSuccessfully = NSErrorPrint(error, @"read category cache");
    if(!isSuccessfully) {
        return categoryDict;
    }
    
    NSMutableDictionary *cacheDict = [NSJSONSerialization JSONObjectWithData:[cacheContent dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
    isSuccessfully = NSErrorPrint(error, @"parese category cache info json");
    if(!isSuccessfully) {
        return categoryDict;
    }
    
    NSMutableArray *cacheData = [cacheDict objectForKey:CONTENT_FIELD_DATA];
    
    // 过滤
    NSString *predicateStr = [NSString stringWithFormat:@"(%@ == \"%@\")", CONTENT_FIELD_ID, categoryID];
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateStr];
    
    categoryDict = [[cacheData filteredArrayUsingPredicate:filter] lastObject];

    return categoryDict;
}

/**
 *  给元素为字典的数组排序；
 *  需求: 为目录列表按ID/名称/更新日期排序
 *
 *  @param mutableArray mutableArray
 *  @param key          数组元素的key
 *  @param asceding     是否升序
 *
 *  @return 排序过的数组
 */
+ (NSMutableArray *)sortArray:(NSMutableArray *)mutableArray
                          Key:(NSString *)key
                    Ascending:(BOOL)asceding {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:asceding];
    NSArray *array = [mutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    return [NSMutableArray arrayWithArray:array];
}

@end