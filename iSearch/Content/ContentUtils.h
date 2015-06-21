//
//  ContentUtils.h
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_ContentUtils_h
#define iSearch_ContentUtils_h

#import <UIKit/UIKit.h>

/**
 *  获取目录的一些通用函数 - [首页][我的分类][离线下载]。
 *
 *  此功能函数为什么不放在HttpUtils.h?
 *      代码中涉及到文件操作，需要引用FileUtils.h, 而FileUtils.h中如果有网络操作也引用HttpUtils.h的话，就会成为死循环。
 *      *Utils.h中函数尽量不要引用其他*Utils.h文件。
 *
 *  为什么每次从服务器取文档信息时，要更新本地已经文档配置？
 *      用户上传文档后，一但压缩后，再修改文档的名称或描述，则压缩包内的配置档信息则无法修改。
 *      所以从服务器端取得文档列表时，检测本地是否已下载，若已下载则更新name/desc字段
 */
@interface ContentUtils : NSObject

+ (NSMutableArray*)loadContentData:(NSString *)deptID
                        CategoryID:(NSString *)categoryID
                              Type:(NSString *)localOrServer;


+ (NSMutableArray*)loadContentDataFromServer:(NSString *) type
                                      DeptID:(NSString *) deptID
                                  CategoryID:(NSString *) categoryID;

+ (NSMutableArray*)loadContentDataFromLocal:(NSString *) type
                                     DeptID:(NSString *) deptID
                                 CategoryID:(NSString *) categoryID;
+ (NSMutableArray *)loadContentFromLocal:(NSString *)pathName;

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
                                  DepthID:(NSString *)deptID;

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
                           Key:(NSString *)key;

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
                                Type:(NSString *)convertType;

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
                    Ascending:(BOOL)asceding;
@end
#endif
