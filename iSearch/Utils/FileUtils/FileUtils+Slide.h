//
//  FileUtils+Slide.h
//  iSearch
//
//  Created by lijunjie on 15/7/9.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_FileUtils_Slide_h
#define iSearch_FileUtils_Slide_h
#import "FileUtils.h"
@class Slide;

@interface FileUtils (Slide)

/** 创建新标签
 *
 * step1: 判断该标签名称是否存在
 *      创建FileID, 格式: r150501010101
 *      初始化重组内容文件的配置档
 *  step2.1 若不存在,则创建
 *  @param tagName 输入的新标签名称
 *
 *  结论: 调用过本函数，FILE_DIRNAME/FileID/desc.json 必须存在
 *       后继操作: 拷贝页面文件及文件夹
 *
 *  @param tagName   标签名称
 *  @param tagDesc   标签描述
 *  @param timestamp 时间戳 （创建新FileID时使用)
 */
+ (Slide *)findOrCreateTag:(NSString *)tagName
                      Desc:(NSString *)tagDesc
                 Timestamp:(NSString *)timestamp;

+ (void)copyFilePage:(NSString *)pName
           FromSlide:(Slide *)fromSlide
             ToSlide:(Slide *)toSlide;


/**
 *  收藏文件列表（FAVORITE_DIRNAME）
 *
 *  @return @{FILE_DESC_KEY: }
 */
+ (NSMutableArray *) favoriteSlideList1;

/**
 *  根据文件名称在收藏夹中查找文件描述档
 *
 *  @param fileName 文件名称
 *
 *  @return descJSOn
 */
+ (NSMutableDictionary *) getDescFromFavoriteWithName:(NSString *)fileName;

@end

#endif
