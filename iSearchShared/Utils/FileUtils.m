//
//  FileUtils.m
//  iContent
//
//  Created by lijunjie on 15/5/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileUtils.h"
#import "const.h"

@interface FileUtils()
@end

@implementation FileUtils

/**
 *  传递目录名取得沙盒中的绝对路径(一级),不存在则创建，请慎用！
 *
 *  @param dirName  目录名称，不存在则创建
 *
 *  @return 沙盒中的绝对路径
 */
+ (NSString *)getPathName: (NSString *)dirName {
    //获取应用程序沙盒的Documents目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 一级目录路径， 不存在则创建
    NSString *pathname = [path stringByAppendingPathComponent:dirName];
    
    BOOL isDir = true;
    BOOL existed = [fileManager fileExistsAtPath:pathname isDirectory:&isDir];
    if ( !(isDir == true && existed == YES) ) {
        [fileManager createDirectoryAtPath:pathname withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return pathname;
}

/**
 *  传递目录名取得沙盒中的绝对路径(二级)
 *
 *  @param dirName  目录名称，不存在则创建
 *  @param fileName 文件名称或二级目录名称
 *
 *  @return 沙盒中的绝对路径
 */
+ (NSString *)getPathName: (NSString *)dirName FileName:(NSString*) fileName {
    // 一级目录路径， 不存在则创建
    NSString *pathname = [self getPathName:dirName];
    // 二级文件名称或二级目录名称
    pathname = [pathname stringByAppendingPathComponent:fileName];
    
    return pathname;
}

/**
 *  检测目录路径、文件路径是否存在
 *
 *  @param pathname 沙盒中的绝对路径
 *  @param isDir    是否是文件夹类型
 *
 *  @return 布尔类型，存在即TRUE，否则为FALSE
 */
+ (BOOL) checkFileExist: (NSString*) pathname isDir: (BOOL) isDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:pathname isDirectory:&isDir];
    return isExist;
}

/**
 *  读取登陆信息配置档，有则读取，无则使用默认值
 *
 *  @param pathname 配置档沙盒绝对路径
 *
 *  @return 返回配置信息NSMutableDictionary
 */
+ (NSMutableDictionary*) readConfigFile: (NSString*) pathName {
    NSMutableDictionary *dict = [NSMutableDictionary alloc];
    //NSLog(@"pathname: %@", pathname);
    if([self checkFileExist:pathName isDir:false]) {
        dict = [dict initWithContentsOfFile:pathName];
    } else {
        dict = [dict init];
    }
    return dict;
}

/**
 *  检测演示文档是否下载，[同步目录]中判断是否已下载.
 *
 *  @param fid 文件在服务器上的id
 *
 *  @return 存在即true, 否则false
 */
+ (BOOL) checkSlideExist: (NSString *) fileID {
    NSString *pathName = [FileUtils getPathName:FILE_DIRNAME FileName:fileID];
    
    NSLog(@"%@", pathName);
    return [FileUtils checkFileExist:pathName isDir:true];
}

/**
 *  打印沙盒目录列表, 相当于`tree ./`， 测试时可以用到
 */
+ (void) printDir: (NSString *)dirName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    if(dirName.length) documentsDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    
    NSFileManager *fileManage = [NSFileManager defaultManager];
    
    NSArray *files = [fileManage subpathsAtPath: documentsDirectory];
    NSLog(@"%@",files);
}

/**
 *  物理删除文件，并返回是否删除成功的布尔值。
 *
 *  @param filePath 待删除的文件路径
 *
 *  @return 是否删除成功的布尔值
 */
+ (BOOL) removeFile:(NSString *)filePath {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL removed = [fileManager removeItemAtPath: filePath error: &error];
    if(error)
        NSLog(@"<# remove file %@ failed: %@", filePath, [error localizedDescription]);
    
    return removed;
}

/**
 *  专用函数;读取文档描述文件内容；FILE_DIRNAME/fileID/desc.json
 *
 *  @param fileID fileID
 *
 *  @return 文档配置档内容;str
 */
+ (NSString *) fileDescContent:(NSString *) fileID {
    NSString *filePath = [FileUtils getPathName:FILE_DIRNAME FileName:fileID];
    NSString *descPath = [filePath stringByAppendingPathComponent:FILE_CONFIG_FILENAME];
    NSError *error;
    NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
    
    if(error) NSLog(@"fileDescContent# read %@ failed for %@", descPath, [error localizedDescription]);
    return descContent;
}

/**
 *  专用函数;读取文档描述文件内容；FILE_DIRNAME/fileID/desc.json(.swp)
 *  klass为FILE_CONFIG_FILENAME、FILE_DISPLAY_CONFIG_FILENAME
 *
 *  @param fileID fileID
 *
 *  @return 文档配置档路径
 */
+ (NSString *) fileDescPath:(NSString *) fileID
                      Klass:(NSString *) klass {
    NSString *filePath = [FileUtils getPathName:FILE_DIRNAME FileName:fileID];
    NSString *descPath = [filePath stringByAppendingPathComponent:klass];
    
    return descPath;
}

/**
 *  专用函数; 由文档演示界面进入文档页面编辑界面时，会拷贝一份描述文件，以实现[恢复]功能；
 *
 *  @param fileID fileID
 *
 *  @return 文档配置档内容;jsonStr
 */
+ (NSString *)copyFileDescContent:(NSString *) fileID {
    NSString *descContent = [FileUtils fileDescContent:fileID];
    NSString *filePath = [FileUtils getPathName:FILE_DIRNAME FileName:fileID];
    NSString *displayDescPath = [filePath stringByAppendingPathComponent:FILE_CONFIG_SWP_FILENAME];
    
    NSError *error;
    [descContent writeToFile:displayDescPath atomically:true encoding:NSUTF8StringEncoding error:&error];
    if(error) NSLog(@"fileDescContent# read %@ failed for %@", displayDescPath, [error localizedDescription]);
    
    return descContent;
}


@end