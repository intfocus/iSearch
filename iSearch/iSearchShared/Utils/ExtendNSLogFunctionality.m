//
//  ExtendNSLogFunctionality.m
//  iReorganize
//
//  Created by lijunjie on 15/5/20.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtendNSLogFunctionality.h"

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...) {
    // Type to hold information about variable arguments.
    va_list ap;
    
    // Initialize a variable argument list.
    va_start (ap, format);
    
    // NSLog only adds a newline to the end of the NSLog format if
    // one is not already there.
    // Here we are utilizing this feature of NSLog()
    if (![format hasSuffix: @"\n"])
        format = [format stringByAppendingString: @"\n"];
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    
    // End using variable argument list.
    va_end (ap);
    
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    fprintf(stderr, "(%s) (%s:%d) %s",
            functionName, [fileName UTF8String],
            lineNumber, [body UTF8String]);
}

void ExtendNSLogPrintError(const char *file, int lineNumber, const char *functionName, BOOL isPrintSuccessfully, NSError *error, NSString *format, ...) {
    if(!isPrintSuccessfully && !error) return;
    
    // Type to hold information about variable arguments.
    va_list ap;
    
    // Initialize a variable argument list.
    va_start (ap, format);
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    if(isPrintSuccessfully && !error) {
        body = [NSString stringWithFormat:@"%@ successfully.", body];
    } else {
        body = [NSString stringWithFormat:@"%@ failed for %@", body, [error localizedDescription]];
    }
    
    if (![body hasSuffix: @"\n"])
        body = [body stringByAppendingString: @"\n"];
    
    // End using variable argument list.
    va_end (ap);
    
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    fprintf(stderr, "(%s) (%s:%d) %s", functionName, [fileName UTF8String], lineNumber, [body UTF8String]);
}

/**
 * 需要post的数据为：
 * UserId        用户编号
 * FunctionName  功能名称
 * ActionName    动作名称
 * ActionTime    操作时间（2015/06/1 18:18:18）
 * ActionReturn  操作结果（包括错误）
 * ActionObject  操作对象（具体到文件）
 */
void actionLogPost(const char *sourceFile, int lineNumber, const char *functionName, NSString *actionName, NSString *actionResult) {
    NSString *userID = @"1";
    NSString *actionTime = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];
    NSString *data = [NSString stringWithFormat:@"UserId=%@&FunctionName=%s#%d&ActionName=%@&ActionTime=%@&ActionReturn=%@&ActionObject=%s",
                      userID, functionName, lineNumber, actionName, actionTime, actionResult, sourceFile];
    
    [HttpUtils httpPost:ACTION_LOGGER_URL_PATH Data:data];
}