//
//  FileUtils.h
//  iContent
//
//  Created by lijunjie on 15/5/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  说明:
//  处理File相关的代码合集.

#ifndef iContent_FileUtils_h
#define iContent_FileUtils_h

#import <UIKit/UIKit.h>

/**
 *  处理File相关的代码块合集
 */
@interface FileUtils : NSObject

/**
 *  传递目录名取得沙盒中的绝对路径(一级),不存在则创建，请慎用！
 *
 *  @param dirName  目录名称，不存在则创建
 *
 *  @return 沙盒中的绝对路径
 */
+ (NSString *)getPathName: (NSString *)dirName;

/**
 *  传递目录名取得沙盒中的绝对路径(二级)
 *
 *  @param dirName  目录名称，不存在则创建
 *  @param fileName 文件名称或二级目录名称
 *
 *  @return 沙盒中的绝对路径
 */
+ (NSString *)getPathName: (NSString *)dirName FileName:(NSString*) fileName;

/**
 *  检测目录路径、文件路径是否存在
 *
 *  @param pathname 沙盒中的绝对路径
 *  @param isDir    是否是文件夹类型
 *
 *  @return 布尔类型，存在即TRUE，否则为FALSE
 */
+ (BOOL) checkFileExist: (NSString*) pathname isDir: (BOOL) isDir;

/**
 *  读取配置档，有则读取。
 *  默认为NSMutableDictionary，若读取后为空，则按JSON字符串转NSMutableDictionary处理。
 *
 *  @param pathname 配置档路径
 *
 *  @return 返回配置信息NSMutableDictionary
 */
+ (NSMutableDictionary*) readConfigFile: (NSString*) pathName;


/**
 *  检测演示文档是否下载;
 *    平时扫描文件列表时，force:NO
 *    演示文稿时，force:YES;
 *    避免由于文件约束问题闪退。
 *
 *  需要考虑问题:
 *  1. Files/fileID/文件是否存在；
 *  2.（force:YES)
 *     a)Files/fileID/desc.json是否存在
 *     b)内容是否为空
 *     c)格式是否为json
 *
 *  @param fileID 文件在服务器上的文件id
 *  @param isForce 确认文件存在的逻辑强度
 *
 *  @return 存在即true, 否则false
 */

+ (BOOL) checkSlideExist: (NSString *) slideID
                     Dir:(NSString *)dir
                   Force:(BOOL)isForce;

/**
 *  打印沙盒目录列表, 相当于`tree ./`， 测试时可以用到
 */
+ (void) printDir: (NSString *)dirName;

/**
 *  物理删除文件，并返回是否删除成功的布尔值。
 *
 *  @param filePath 待删除的文件路径
 *
 *  @return 是否删除成功的布尔值
 */
+ (BOOL) removeFile:(NSString *)filePath;

/**
 *  专用函数;读取文档描述文件内容；FILE_DIRNAME/fileID/desc.json
 *  Dir: FILE_DIRNAME/FAVORITE_DIRNAME
 *  @param fileID fileID
 *
 *  @return 文档配置档内容;jsonStr
 */
+ (NSString *) slideDescContent:(NSString *) fileID Dir:(NSString *)dir;

/**
 *  专用函数;读取文档描述文件内容；{FILE_DIRNAME,FAVORITE_DIRNAME}/fileID/desc.json(.swp)
 *  Dir为FILE_DIRNAME/FAVORITGE_DIRNAME
 *  klass为FILE_CONFIG_FILENAME/FILE_DISPLAY_CONFIG_FILENAME
 *
 *  @param fileID fileID
 *  @param Dir    FILE_DIRNAME/FAVORITE_DIRNAME
 *  @param Klass  FILE_DESC_FILENAME/FILE_DESC_SWP_FILE_NAME
 *
 *  @return 文档配置档路径
 */
+ (NSString *) slideDescPath:(NSString *)fileID
                        Dir:(NSString *)dirName
                      Klass:(NSString *)klass;

/**
 *  专用函数; 由文档演示界面进入文档页面编辑界面时，会拷贝一份描述文件，以实现[恢复]功能；
 *
 *  @param fileID fileID
 *  @param dirName FILE_DIRNAME/FAVORITE_DIRNAME
 *
 *  @return 文档配置档内容;jsonStr
 */
+ (NSString *)copyFileDescContent:(NSString *)slideID Dir:(NSString *)dirName;


/**
 *  文件体积大小转化为可读文字；
 *
 *  831106     => 811.6K
 *  8311060    =>   7.9M
 *  83110600   =>  79.3M
 *  831106000  =>  792.6M
 *
 *  @param fileSize 文件体积大小
 *
 *  @return 可读数字，保留一位小数，追加单位
 */
+ (NSString *)humanFileSize:(NSString *)fileSize;

/**
 *  收藏文件列表（FAVORITE_DIRNAME）
 *
 *  @return @{FILE_DESC_KEY: }
 */
+ (NSMutableArray *) favoriteFileList;

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
+ (NSMutableDictionary *)findOrCreateTag:(NSString*)tagName
                                    Desc:(NSString *)tagDesc
                               Timestamp:(NSString *)timestamp;

/**
 *  NSMutableDictionary写入本地文件
 *
 *  @param data     JSON
 *  @param filePath 目标文件
 */
+ (void) writeJSON:(NSMutableDictionary *)data
              Into:(NSString *) filePath;

/**
 *  根据文件名称在收藏夹中查找文件描述档
 *
 *  @param fileName 文件名称
 *
 *  @return descJSOn
 */
+ (NSMutableDictionary *) getDescFromFavoriteWithName:(NSString *)fileName;

/**
 *  获取文档的缩略图，即文档中的pdf/gif文件; 文件名为PageID, 后缀应该小写
 *
 *  @param FileID fileID
 *  @param PageID pageID
 *
 *  @return pdf/gif文档路径
 */
+ (NSString*) fileThumbnail:(NSString *)FileID
                     PageID:(NSString *)PageID
                        Dir:(NSString *)dir;

/**
 *  文档收藏；把文档从SLIDE_DIRNAME拷贝到FAVORITE_DIRNAME;
 *  使用block是为了保持FileUtils一方净土
 *
 *  @param slideID                   文档ID
 *  @param updateSlideTimestampBlock 使用DateUtils更新日间戳
 *
 *  @return 操作成功否
 */
+ (BOOL) copySlideToFavorite:(NSString *)slideID
                       Block:(void (^)(NSMutableDictionary *dict))updateSlideTimestampBlock;
@end


#endif
