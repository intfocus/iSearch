//
//  ApiUtils.h
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_DataHelper_h
#define iSearch_DataHelper_h
#import <UIKit/UIKit.h>

/**
 *  处理数据: ApiHelper + CacheHelper
 */
@interface DataHelper : NSObject

/**
 *  获取通知公告数据
 *
 *  @return 通知公告数据列表
 */
+ (NSMutableDictionary *)notifications;
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
+ (NSArray*)loadContentData:(UIView *)view
                 CategoryID:(NSString *)categoryID
                       Type:(NSString *)localOrServer
                        Key:(NSString *)sortKey
                      Order:(BOOL)isAsceding;

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
                    Ascending:(BOOL)asceding;

/**
 *  同步用户行为操作
 *
 *  @param unSyncRecords 未同步数据
 */
+ (NSMutableArray *)actionLog:(NSMutableArray *)unSyncRecords;

+ (void)traverseVisitContent:(NSString *)categoryID;
@end

#endif
