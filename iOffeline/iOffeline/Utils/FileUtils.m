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
 *  传递目录名取得沙盒中的绝对路径(一级)
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
+ (NSMutableDictionary*) readConfigFile: (NSString*) pathname {
    NSMutableDictionary *dict = [NSMutableDictionary alloc];
    //NSLog(@"pathname: %@", pathname);
    if([self checkFileExist:pathname isDir:false]) {
        dict = [dict initWithContentsOfFile:pathname];
    } else {
        dict = [dict init];
        [dict setObject:@"" forKey:@"DisplayId"];
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
+ (BOOL) checkSlideExist: (NSString *) fid {
    NSString *pathName = [FileUtils getPathName:FILE_DIRNAME FileName:fid];
    
    return [FileUtils checkFileExist:pathName isDir:true];
}


@end