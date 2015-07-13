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
#import "ApiHelper.h"
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
 *  @param deptID        部门ID
 *  @param categoryID    分类ID
 *  @param localOrServer local or sever
 *
 *  @return 数据列表
 */
+ (NSArray*)loadContentData:(NSString *)deptID
                 CategoryID:(NSString *)categoryID
                       Type:(NSString *)localOrServer
                        Key:(NSString *)sortKey
                      Order:(BOOL)isAsceding {
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
    // mark sure array not nil
    if(!categoryList) { categoryList = [[NSMutableArray alloc] init]; }
    if(!slideList) { slideList = [[NSMutableArray alloc] init]; }
    
    NSString *sID             = [[NSString alloc] init];
    NSNumber *nID             = [[NSNumber alloc] init];
    // order
    NSInteger i = 0;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if([categoryList count] > 0) {
        for(i = 0; i < [categoryList count]; i++) {
            dict = [NSMutableDictionary dictionaryWithDictionary:categoryList[i]];
            sID  = dict[CONTENT_FIELD_ID];
            nID  = [NSNumber numberWithInteger:[sID intValue]];
            dict[CONTENT_SORT_KEY]   = nID;
            // warning: 服务器返回的分类列表数据中，未设置type
            dict[CONTENT_FIELD_TYPE] = CONTENT_CATEGORY;
            categoryList[i]          = dict;
        }
        categoryList = [ContentUtils sortArray:categoryList Key:CONTENT_SORT_KEY Ascending:isAsceding];
    }
    if([slideList count] > 0) {
        for(i = 0; i < [slideList count]; i++) {
            dict = [NSMutableDictionary dictionaryWithDictionary:slideList[i]];
            sID  = dict[CONTENT_FIELD_ID];
            nID  = [NSNumber numberWithInteger:[sID intValue]];
            dict[CONTENT_SORT_KEY]   = nID;
            slideList[i]             = dict;
        }
        slideList = [ContentUtils sortArray:slideList Key:CONTENT_SORT_KEY Ascending:isAsceding];
    }
    
    return @[categoryList, slideList];
}

+ (NSMutableArray*)loadContentDataFromServer:(NSString *)type
                                      DeptID:(NSString *)deptID
                                  CategoryID:(NSString *)categoryID {
    NSError *error;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    // 无网络直接返回空值
    if(![HttpUtils isNetworkAvailable]) {
        return mutableArray;
    }
    
    NSMutableDictionary *responseJSON = [[NSMutableDictionary alloc] init];
    if([type isEqualToString:CONTENT_CATEGORY]) {
        responseJSON = [ApiHelper categories:categoryID DeptID:deptID];
    } else if([type isEqualToString:CONTENT_SLIDE]) {
        responseJSON = [ApiHelper slides:categoryID DeptID:deptID];
    }

    NSErrorPrint(error, @"string convert into json");
    if(responseJSON[CONTENT_FIELD_DATA]) {
        mutableArray = [NSMutableArray arrayWithArray:responseJSON[CONTENT_FIELD_DATA]];
    }
    
    // update local slide when downloaded
    if([type isEqualToString:CONTENT_SLIDE] && [mutableArray count] > 0) {
        Slide *slide;
        for(NSMutableDictionary *dict in mutableArray) {
            slide = [[Slide alloc]initSlide:dict isFavorite:NO];
            //[slide toCached];
            if([slide isDownloaded:NO]) { [slide save]; }
        }
    }
    
    // 获取数据不为空时，写入本地缓存
    if([mutableArray count] > 0) {
        NSString *cacheName = [ContentUtils contentCacheName:type ID:categoryID];
        NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
        [FileUtils writeJSON:responseJSON Into:cachePath];
    }
    
    return mutableArray;
}

+ (NSMutableArray*)loadContentDataFromLocal:(NSString *)type
                                     DeptID:(NSString *)deptID
                                 CategoryID:(NSString *)categoryID {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *cacheName = [ContentUtils contentCacheName:type ID:categoryID];
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
    NSString *cacheName = [ContentUtils contentCacheName:CONTENT_CATEGORY ID:parentID];
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
 *  @param ID ID
 *
 *  @return cacheName
 */
+ (NSString *)contentCacheName:(NSString *)type
                            ID:(NSString *)ID {
    return [NSString stringWithFormat:@"%@-%@.cache",type, ID];
}
@end