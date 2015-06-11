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
 *  读取登陆信息配置档，有则读取，无则使用默认值
 *
 *  @param pathname 配置档沙盒绝对路径
 *
 *  @return 返回配置信息NSMutableDictionary
 */
+ (NSMutableDictionary*) readConfigFile:(NSString*) pathname;


/**
 *  检测演示文档是否下载，[同步目录]中判断是否已下载.
 *
 *  @param fid 文件在服务器上的id
 *
 *  @return 存在即true, 否则false
 */
+ (BOOL) checkSlideExist: (NSString *) fid;

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
 *
 *  @param fileID fileID
 *
 *  @return 文档配置档内容;jsonStr
 */
+ (NSString *) fileDescContent:(NSString *) fileID;

/**
 *  专用函数;读取文档描述文件内容；FILE_DIRNAME/fileID/desc.json(.swp)
 *  klass为FILE_CONFIG_FILENAME、FILE_DISPLAY_CONFIG_FILENAME
 *
 *  @param fileID fileID
 *
 *  @return 文档配置档内容;json
 */
+ (NSString *) fileDescPath:(NSString *) fileID
                      Klass:(NSString *) klass;

/**
 *  专用函数; 由文档演示界面进入文档页面编辑界面时，会拷贝一份描述文件，以实现[恢复]功能；
 *
 *  @param fileID fileID
 *
 *  @return 文档配置档内容;jsonStr
 */
+ (NSString *) copyFileDescContent:(NSString *) fileID;

@end


#endif
