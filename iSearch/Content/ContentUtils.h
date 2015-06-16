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
 *  获取目录的一些能用函数，在[首页]也会使用到同样功能代码。
 *
 *  此功能函数为什么不放在HttpUtils.h?
 *      代码中涉及到文件操作，需要引用FileUtils.h, 而FileUtils.h中如果有网络操作也引用HttpUtils.h的话，就会成为死循环。
 *      *Utils.h中函数尽量不要引用其他*Utils.h文件。
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
@end
#endif
