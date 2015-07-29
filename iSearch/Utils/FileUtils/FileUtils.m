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
#import "ExtendNSLogFunctionality.h"

@interface FileUtils()
@end

@implementation FileUtils

+ (NSString *)getBasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    return [paths objectAtIndex:0];
}
/**
 *  传递目录名取得沙盒中的绝对路径(一级),不存在则创建，请慎用！
 *
 *  @param dirName  目录名称，不存在则创建
 *
 *  @return 沙盒中的绝对路径
 */
+ (NSString *)getPathName: (NSString *)dirName {
    //获取应用程序沙盒的Documents目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *basePath = [FileUtils getBasePath];
    BOOL isDir = true, existed;
    
    NSString *configPath = [basePath stringByAppendingPathComponent:LOGIN_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    NSString *userSpaceName = [NSString stringWithFormat:@"%@-%@", configDict[USER_DEPTID], configDict[USER_EMPLOYEEID]];
    NSString *userSpacePath = [basePath stringByAppendingPathComponent:userSpaceName];
    
    // 一级目录路径， 不存在则创建
    NSString *pathName = [userSpacePath stringByAppendingPathComponent:dirName];
    existed = [fileManager fileExistsAtPath:pathName isDirectory:&isDir];
    if ( !(isDir == true && existed == YES) ) {
        [fileManager createDirectoryAtPath:pathName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return pathName;
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
 *  读取配置档，有则读取。
 *  默认为NSMutableDictionary，若读取后为空，则按JSON字符串转NSMutableDictionary处理。
 *
 *  @param pathname 配置档路径
 *
 *  @return 返回配置信息NSMutableDictionary
 */
+ (NSMutableDictionary*) readConfigFile: (NSString*) pathName {
    NSMutableDictionary *dict = [NSMutableDictionary alloc];
    //NSLog(@"pathname: %@", pathname);
    if([self checkFileExist:pathName isDir:false]) {
        dict = [dict initWithContentsOfFile:pathName];
        // 若为空，则为JSON字符串
        if(!dict) {
            NSError *error;
            BOOL isSuccessfully;
            NSString *descContent = [NSString stringWithContentsOfFile:pathName encoding:NSUTF8StringEncoding error:&error];
            isSuccessfully = NSErrorPrint(error, @"read desc file: %@", pathName);
            if(isSuccessfully) {
                dict= [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                NSErrorPrint(error, @"convert string into json: \n%@", descContent);
            }
        }
    } else {
        dict = [dict init];
    }
    return dict;
}

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
+ (BOOL) checkSlideExist:(NSString *) slideID
                     Dir:(NSString *) dirName
                   Force:(BOOL) isForce {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    NSString *filePath = [FileUtils getPathName:dirName FileName:slideID];
    // 1. Files/fileID/文件是否存在
    if(![FileUtils checkFileExist:filePath isDir:YES]) {
        [errors addObject:@"fileID文件夹不存在."];
    }
    
    // 2. a)Files/fileID/desc.json是否存在，b)内容是否为空，c)格式是否为json
    NSString *descPath = [filePath stringByAppendingPathComponent:SLIDE_DICT_FILENAME];
    if(isForce && errors && [errors count] == 0) {
        // a)Files/fileID/desc.json是否存在
        if(![FileUtils checkFileExist:descPath isDir:NO]) {
            [errors addObject:@"fileID/desc.json文件不存在."];
        }
    
        // b)内容是否为空，c)格式是否为json
        if(errors && [errors count] == 0) {
            // b)内容是否为空，
            NSMutableDictionary *descDict = [FileUtils readConfigFile:descPath];
            if(!descDict) {
                [errors addObject:@"desc is nil"];
            }
        }
    }

    return ([errors count] == 0);
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
 *  专用函数;读取文档描述文件内容；{FILE_DIRNAME,FAVORITE_DIRNAME}/fileID/desc.json(.swp)
 *
 *  @param slideID slideID
 *  @param dirName SLIDE_DIRNAME/FAVORITE_DIRNAME
 *  @param klass   SLIDE_CONFIG_FILENAME/SLIDE_CONFIG_SWP_FILENAME
 *
 *  @return 文档配置档路径
 */
+ (NSString *) slideDescPath:(NSString *)fileID
                         Dir:(NSString *)dirName
                       Klass:(NSString *)klass {
    NSString *slidePath = [FileUtils getPathName:dirName FileName:fileID];
    NSString *descPath = [slidePath stringByAppendingPathComponent:klass];
    
    return descPath;
}

/**
 *  专用函数;读取文档描述文件内容；FILE_DIRNAME/fileID/desc.json
 *
 *
 *  @param slideID slideID
 *  @param dirName SLIDE_DIRNAME/FAVORITE_DIRNAME
 *  @param klass   SLIDE_CONFIG_FILENAME/SLIDE_CONFIG_SWP_FILENAME
 *
 *
 *  @return 文档配置档内容;str
 */
+ (NSString *) slideDescContent:(NSString *)slideID
                            Dir:(NSString *)dirName
                          Klass:(NSString *)klass {
    NSError *error;
    NSString *descPath = [FileUtils slideDescPath:slideID Dir:dirName Klass:klass];
    NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"slideID#%@, dirName#%@, klass#%@ - %@", slideID, dirName, klass, descPath);
    
    return descContent;
}

/**
 *  专用函数; 由文档演示界面进入文档页面编辑界面时，会拷贝一份描述文件，以实现[恢复]功能；
 *
 *  @param fileID fileID
 *  @param dirName FILE_DIRNAME/FAVORITE_DIRNAME
 *
 *  @return 文档配置档内容;jsonStr
 */
+ (NSString *)copyFileDescContent:(NSString *)slideID Dir:(NSString *)dirName {
    NSString *descContent = [FileUtils slideDescContent:slideID Dir:dirName Klass:SLIDE_CONFIG_FILENAME];
    NSString *descSwpPath = [FileUtils slideDescPath:slideID Dir:dirName Klass:SLIDE_CONFIG_SWP_FILENAME];
    
    NSError *error;
    [descContent writeToFile:descSwpPath atomically:true encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"slideID#%@, dirName#%@; desc write into desc.swp: %@", slideID, dirName, descSwpPath);
    
    return descContent;
}

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
+ (NSString *)humanFileSize:(NSString *)fileSize {
    NSString *humanSize = [[NSString alloc] init];
    
    @try {
        double convertedValue = [fileSize doubleValue];
        int multiplyFactor = 0;
        
        NSArray *tokens = [NSArray arrayWithObjects:@"B",@"K",@"M",@"G",@"T",nil];
        
        while (convertedValue > 1024) {
            convertedValue /= 1024;
            multiplyFactor++;
        }
        humanSize = [NSString stringWithFormat:@"%4.1f%@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
    } @catch(NSException *e) {
        NSLog(@"convert [%@] into human readability failed for %@", fileSize, [e description]);
        humanSize = fileSize;
    }
    
    return humanSize;
}

/**
 *  NSMutableDictionary写入本地文件
 *
 *  @param data     JSON
 *  @param filePath 目标文件
 */
+ (void) writeJSON:(NSMutableDictionary *)data
              Into:(NSString *)slidePath {
    NSError *error;
    if ([NSJSONSerialization isValidJSONObject:data]) {
        // NSMutableDictionary convert to JSON Data
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSErrorPrint(error, @"NsMutableDict convert to json");
        // JSON Data convert to NSString
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if(!error) {
            [jsonStr writeToFile:slidePath atomically:true encoding:NSUTF8StringEncoding error:&error];
            NSErrorPrint(error, @"json string write into desc file#%@", slidePath);
        }
    }
}
/**
 *  获取文档的缩略图，即文档中的pdf/gif文件; 文件名为PageID, 后缀应该小写
 *
 *  @param FileID fileID
 *  @param PageID pageID
 *
 *  @return pdf/gif文档路径
 */
+ (NSString*) slideThumbnail:(NSString *)slideID
                      PageID:(NSString *)pageID
                         Dir:(NSString *)dirName {
    NSString *slidePath  = [FileUtils getPathName:dirName FileName:slideID];
    NSString *pagePath   = [slidePath stringByAppendingPathComponent:pageID];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    
    //return [bundlePath stringByAppendingPathComponent:@"thumbnailPageVideo.png"];
    NSString *thumbnailPath, *format;
    BOOL isVideo = NO, isSlide = NO;

    for(format in @[@"Gif",@"gif"]) { // never load pdf, @"pdf"
        thumbnailPath = [pagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", pageID, format]];
        if([FileUtils checkFileExist:thumbnailPath isDir:NO]) {
            isSlide = YES; break;
        }
    }
    if(isSlide) { return thumbnailPath; }
    
    for(format in @[@"mp4", @"mpg"]) {
        thumbnailPath = [pagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", pageID, format]];
        if([FileUtils checkFileExist:thumbnailPath isDir:NO]) {
            isVideo = YES; break;
        }
    }
    if(isVideo) {
        thumbnailPath = [bundlePath stringByAppendingPathComponent:@"thumbnailPageVideo.png"];
        return thumbnailPath;
    };
    
    thumbnailPath = [bundlePath stringByAppendingPathComponent:@"thumbnailPageSlide.png"];
    return thumbnailPath;
}

/**
 *  在线浏览目录时，根据文档属性显示对应缩略图
 *
 *  @param slideTyoe 文档类型
 *
 *  @return 缩略图地址
 */
+ (NSString *)slideThumbnail:(NSString *)slideTyoe {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *thumbnailName;
    if([@[@"1",@"2",@"4"] containsObject:slideTyoe]) {
        thumbnailName = @"thumbnailPageSlide.png";
    } else if ([slideTyoe isEqualToString:@"3"]) {
        thumbnailName = @"thumbnailPageVideo.png";
    } else {
        thumbnailName = @"thumbnailPageSlide.png";
    }
    return [bundlePath stringByAppendingPathComponent:thumbnailName];
}

#pragma mark - slide download cache
+ (NSString *)slideDownloadCachePath:(NSString *)slideID {
    NSString *cacheName = [NSString stringWithFormat:@"%@.downloading", slideID];
    NSString *cachePath = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:cacheName];
    return cachePath;
}
+ (NSString *)slideToDownload:(NSString *)slideID {
    NSString *cachePath = [FileUtils slideDownloadCachePath:slideID];
    [@"downloading" writeToFile:cachePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    return cachePath;
}
+ (NSString *)slideDownloaded:(NSString *)slideID {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [FileUtils slideDownloadCachePath:slideID];
    [fileManager removeItemAtPath:cachePath error:NULL];
    
    return cachePath;
}
+ (BOOL)isSlideDownloading:(NSString *)slideID {
    NSString *cachePath = [FileUtils slideDownloadCachePath:slideID];
    return [FileUtils checkFileExist:cachePath isDir:NO];
}


/**
 *  计算指定文件路径的文件大小
 *
 *  @param filePath 文件绝对路径
 *
 *  @return 文件体积
 */
+ (NSString *)fileSize:(NSString *)filePath {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath]) {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
        NSErrorPrint(error, @"caculate file size - %@", filePath);
        return [NSString stringWithFormat:@"%lld", [[fileAttributes objectForKey:NSFileSize] longLongValue]];
    }
    return @"0";
}

/**
 *  计算指定文件夹路径的文件体积
 *
 *  @param folderPath 文件夹路径
 *
 *  @return 文件夹体积
 */
+ (NSString *)folderSize:(NSString *)folderPath {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [fileManager subpathsOfDirectoryAtPath:folderPath error:&error];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName, *filePath;
    unsigned long long int folderSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        filePath = [folderPath stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
        NSErrorPrint(error, @"caculate file size - %@", filePath);
        folderSize +=  [[fileAttributes objectForKey:NSFileSize] longLongValue];
    }
    return [NSString stringWithFormat:@"%lld", folderSize];
}
@end