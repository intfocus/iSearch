//
//  ApiUtils.h
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_DataHelper_h
#define iSearch_DataHelper_h

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
+ (NSArray*)loadContentData:(NSString *)deptID
                 CategoryID:(NSString *)categoryID
                       Type:(NSString *)localOrServer
                        Key:(NSString *)sortKey
                      Order:(BOOL)isAsceding;

@end

#endif
