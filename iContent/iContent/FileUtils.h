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

@interface FileUtils : NSObject

+ (NSString *)getPathName: (NSString *)dirName;
+ (NSString *)getPathName: (NSString *)dirName FileName:(NSString*) fileName;
+ (BOOL) checkFileExist: (NSString*) pathname isDir: (BOOL) isDir;
+ (NSMutableDictionary*) readConfigFile:(NSString*) pathname;
+ (BOOL) checkSlideExist: (NSString *) fid;

@end


#endif
