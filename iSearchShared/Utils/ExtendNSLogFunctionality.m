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

void ExtendNSLogPrintError(const char *file, int lineNumber, const char *functionName, NSError *error, NSString *info, BOOL isPrintSuccessfully) {
    if(!isPrintSuccessfully && !error) return;
    
    NSString *body = [[NSString alloc] init];
    if(isPrintSuccessfully && !error) {
        body = [NSString stringWithFormat:@"%@ successfully.", info];
    } else {
        body = [NSString stringWithFormat:@"%@ failed for %@", info, [error localizedDescription]];
    }
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    
    if (![body hasSuffix: @"\n"])
        body = [body stringByAppendingString: @"\n"];
    
    fprintf(stderr, "(%s) (%s:%d) %s", functionName, [fileName UTF8String], lineNumber, [body UTF8String]);
}