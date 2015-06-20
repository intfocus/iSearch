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
    
    // 服务器获取的文档信息更新本地已下载文档配置信息
    if([type isEqualToString:CONTENT_SLIDE] && [mutableArray count] > 0) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *tmpDesc = [[NSMutableDictionary alloc] init];
        NSString *descPath = [[NSString alloc] init];
        for(tmpDict in mutableArray) {
            // skip when not download
            if(![FileUtils checkSlideExist:tmpDict[CONTENT_FIELD_ID] Dir:SLIDE_DIRNAME Force:NO])
                continue;
            
            descPath = [FileUtils slideDescPath:tmpDict[CONTENT_FIELD_ID] Dir:SLIDE_DIRNAME Klass:SLIDE_CONFIG_FILENAME];
            tmpDesc = [FileUtils readConfigFile:descPath];
            [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_NAME] Key:SLIDE_DESC_NAME];
            [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_DESC] Key:SLIDE_DESC_DESC];
            [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_TYPE] Key:SLIDE_DESC_TYPE];
            [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_TITLE] Key:CONTENT_FIELD_TITLE];
            [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_ZIPSIZE] Key:CONTENT_FIELD_ZIPSIZE];
            [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_CATEGORYID] Key:CONTENT_FIELD_CATEGORYID];
            [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_PAGENUM] Key:CONTENT_FIELD_PAGENUM];
            [ContentUtils mySet:tmpDesc Object:tmpDict[CONTENT_FIELD_CREATEDATE] Key:CONTENT_FIELD_CREATEDATE];
//            [tmpDesc setObject:tmpDict[CONTENT_FIELD_NAME] forKey:SLIDE_DESC_NAME];
//            [tmpDesc setObject:tmpDict[CONTENT_FIELD_DESC] forKey:SLIDE_DESC_DESC];
//            [tmpDesc setObject:tmpDict[CONTENT_FIELD_TYPE] forKey:SLIDE_DESC_TYPE];
//            [tmpDesc setObject:tmpDict[CONTENT_FIELD_TITLE] forKey:CONTENT_FIELD_TITLE];
//            [tmpDesc setObject:tmpDict[CONTENT_FIELD_ZIPSIZE] forKey:CONTENT_FIELD_ZIPSIZE];
//            [tmpDesc setObject:tmpDict[CONTENT_FIELD_CATEGORYID] forKey:CONTENT_FIELD_CATEGORYID];
//            [tmpDesc setObject:tmpDict[CONTENT_FIELD_PAGENUM] forKey:CONTENT_FIELD_PAGENUM];
//            [tmpDesc setObject:tmpDict[CONTENT_FIELD_CREATEDATE] forKey:CONTENT_FIELD_CREATEDATE];
            
            [FileUtils writeJSON:tmpDesc Into:descPath];
            /**
             *  warning: 此处不更新desc的SLIDE_DESC_LOCAL_UPDATEDAT,该信息用来记录用户的操作时候
             */
        }
    }
    
    NSString *cacheFilePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:[NSString stringWithFormat:@"%@-%@-%@",deptID, categoryID, type]];
    
    // 解析成功、获取数据不为空时，写入本地缓存
    if(!error && [mutableArray count]) {
        // 1. 请求目录返回josn字符串写入CONTENT_DIRNAME/deptID-categoryID-file.json
        [response writeToFile:cacheFilePath atomically:true encoding:NSUTF8StringEncoding error:&error];
        NSErrorPrint(error, @"content category write into %@", cacheFilePath);
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
+ (NSMutableArray*)loadContentDataFromLocal:(NSString *) type
                                     DeptID:(NSString *) deptID
                                 CategoryID:(NSString *) categoryID {
    NSError *error;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *cacheContent = [[NSString alloc] init];
    NSString *cacheFilePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:[NSString stringWithFormat:@"%@-%@-%@",deptID, categoryID, type]];
    
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
    NSLog(@"%@", pathName);
    NSError *error;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *fileContent = [NSString stringWithContentsOfFile:pathName encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read file content");
    NSLog(@"loadContentFromLocal: %@", pathName);
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
    NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:[NSString stringWithFormat:@"%@-%@-%@",deptID, parentID, CONTENT_CATEGORY]];
    NSString *cacheContent = [NSString stringWithContentsOfFile:cachePath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read category cache");
    NSMutableDictionary *cacheDict = [NSJSONSerialization JSONObjectWithData:[cacheContent dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
    NSErrorPrint(error, @"parese category cache info json");
    NSMutableArray *cacheData = [cacheDict objectForKey:CONTENT_FIELD_DATA];
    
    // 过滤
    NSString *predicateStr = [NSString stringWithFormat:@"(%@ == \"%@\")", CONTENT_FIELD_ID, categoryID];
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateStr];
    
    categoryDict = [[cacheData filteredArrayUsingPredicate:filter] lastObject];

    return categoryDict;
}

@end