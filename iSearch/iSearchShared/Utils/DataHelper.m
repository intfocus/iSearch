//
//  ApiUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataHelper.h"

#import "User.h"
#import "Slide.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "HttpUtils.h"
#import "ApiHelper.h"
#import "CacheHelper.h"
#import "ExtendNSLogFunctionality.h"

@interface DataHelper()

@end
@implementation DataHelper

/**
 *  获取通知公告数据
 *
 *  @return 通知公告数据列表
 */
+ (NSMutableDictionary *)notifications {
    NSMutableDictionary *notificationDatas = [[NSMutableDictionary alloc] init];
    
    //无网络，读缓存
    if(![HttpUtils isNetworkAvailable]) {
        return [CacheHelper readNotifications];
    }
    
    // 从服务器端获取[公告通知]
    NSString *currentDate = [DateUtils dateToStr:[NSDate date] Format:DATE_SIMPLE_FORMAT];
    notificationDatas = [ApiHelper notifications:currentDate DeptID:[User deptID]];
    
    [CacheHelper writeNotifications:notificationDatas];
    
    return notificationDatas;
}

/**
 *  获取目录信息: 分类数据+文档数据;
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
    NSMutableArray *slideList    = [[NSMutableArray alloc] init];

    if([localOrServer isEqualToString:LOCAL_OR_SERVER_LOCAL]) {
        categoryList = [CacheHelper readContents:CONTENT_CATEGORY ID:categoryID];
        slideList    = [CacheHelper readContents:CONTENT_SLIDE ID:categoryID];
    } else if([localOrServer isEqualToString:LOCAL_OR_SERVER_SREVER]) {
        categoryList = [self loadContentDataFromServer:CONTENT_CATEGORY DeptID:deptID CategoryID:categoryID];
        slideList    = [self loadContentDataFromServer:CONTENT_SLIDE DeptID:deptID CategoryID:categoryID];
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
        categoryList = [self sortArray:categoryList Key:CONTENT_SORT_KEY Ascending:isAsceding];
    }
    if([slideList count] > 0) {
        for(i = 0; i < [slideList count]; i++) {
            dict = [NSMutableDictionary dictionaryWithDictionary:slideList[i]];
            sID  = dict[CONTENT_FIELD_ID];
            nID  = [NSNumber numberWithInteger:[sID intValue]];
            dict[CONTENT_SORT_KEY]   = nID;
            slideList[i]             = dict;
        }
        slideList = [self sortArray:slideList Key:CONTENT_SORT_KEY Ascending:isAsceding];
    }
    
    return @[categoryList, slideList];
}

+ (NSMutableArray*)loadContentDataFromServer:(NSString *)type
                                      DeptID:(NSString *)deptID
                                  CategoryID:(NSString *)categoryID {
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
    // local cache
    [CacheHelper writeContents:responseJSON Type:type ID:categoryID];

    return mutableArray;
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


//
//+ (NSString *)postActionLog:(NSMutableDictionary *) params {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSString *url = [ApiUtils apiUrl:ACTION_LOGGER_URL_PATH];
//    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//    
//    return @"";
//}
//
@end