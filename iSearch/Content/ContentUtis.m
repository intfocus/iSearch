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

#import "Slide.h"
#import "GMGridView.h"
#import "ViewSlide.h"
#import "ViewCategory.h"

@interface ContentUtils()

@end

@implementation ContentUtils
/**
 *  获取目录;
 *  分类在前，文档在后；各自默认按名称升序排序；
 *
 *  @param deptID        <#deptID description#>
 *  @param categoryID    <#categoryID description#>
 *  @param localOrServer <#localOrServer description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray*)loadContentData:(NSString *)deptID
                        CategoryID:(NSString *)categoryID
                              Type:(NSString *)localOrServer {
    NSMutableArray *categoryList = [[NSMutableArray alloc] init];
    NSMutableArray *slideList = [[NSMutableArray alloc] init];
    
    if([localOrServer isEqualToString:LOCAL_OR_SERVER_LOCAL]) {
        categoryList = [ContentUtils loadContentDataFromLocal:CONTENT_CATEGORY DeptID:deptID CategoryID:categoryID];
        slideList     = [ContentUtils loadContentDataFromLocal:CONTENT_SLIDE DeptID:deptID CategoryID:categoryID];
    }
    else if([localOrServer isEqualToString:LOCAL_OR_SERVER_SREVER]) {
        categoryList = [ContentUtils loadContentDataFromServer:CONTENT_CATEGORY DeptID:deptID CategoryID:categoryID];
        slideList     = [ContentUtils loadContentDataFromServer:CONTENT_SLIDE DeptID:deptID CategoryID:categoryID];
    }
    else {
        NSLog(@"=BUG= not support localOrServer=%@", localOrServer);
    }
    if([categoryList count] > 0) {
        categoryList = [ContentUtils sortArray:categoryList Key:CONTENT_FIELD_NAME Ascending:YES];
    }
    if([slideList count] > 0) {
        slideList = [ContentUtils sortArray:slideList Key:CONTENT_FIELD_NAME Ascending:YES];
    }
    
//    NSArray *array = [categoryList arrayByAddingObjectsFromArray:slideList];
//    return [NSMutableArray arrayWithArray:array];
#warning make sure return two array
    return @[categoryList, slideList];
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
    Slide *slide = [Slide alloc];
    // update local slide cache info
    if([type isEqualToString:CONTENT_SLIDE] && [mutableArray count] > 0) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for(dict in mutableArray) {
            slide = [slide initWith:dict Favorite:NO];
            if(slide.isDownload) {
                [slide save];
            }
            // write into cache then [view] slide info with popup view
            NSString *cacheName = [ContentUtils contentCacheName:CONTENT_SLIDE DeptID:deptID ID:slide.ID];
            [slide cached:cacheName];

        }
    }
    NSString *cacheName = [ContentUtils contentCacheName:type DeptID:deptID ID:categoryID];
    NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
    
    // 解析成功、获取数据不为空时，写入本地缓存
    if(!error && [mutableArray count] > 0) {
        [FileUtils writeJSON:responseJSON Into:cachePath];
    }
    
    return mutableArray;
}

+ (NSMutableArray*)loadContentDataFromLocal:(NSString *)type
                                     DeptID:(NSString *)deptID
                                 CategoryID:(NSString *)categoryID {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *cacheName = [ContentUtils contentCacheName:type DeptID:deptID ID:categoryID];
    NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
    
    if([FileUtils checkFileExist:cachePath isDir:false]) {
        NSMutableDictionary *cacheJSON = [FileUtils readConfigFile:cachePath];
        mutableArray = cacheJSON[CONTENT_FIELD_DATA];
    }
    
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
    NSMutableDictionary *categoryDict = [[NSMutableDictionary alloc] init];
    NSString *cacheName = [ContentUtils contentCacheName:CONTENT_CATEGORY DeptID:deptID ID:parentID];
    NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
    NSMutableDictionary *cacheDict = [FileUtils readConfigFile:cachePath];
    NSMutableArray *cacheData = [cacheDict objectForKey:CONTENT_FIELD_DATA];
    
    // 过滤
    NSString *predicateStr = [NSString stringWithFormat:@"(%@ == \"%@\")", CONTENT_FIELD_ID, categoryID];
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateStr];

    categoryDict = [[cacheData filteredArrayUsingPredicate:filter] lastObject];

    return categoryDict;
}

/**
 *  给元素为字典的数组排序；
 *  需求: 分类、文档顺序排放，然后各自按ID/名称/更新日期排序
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
@end