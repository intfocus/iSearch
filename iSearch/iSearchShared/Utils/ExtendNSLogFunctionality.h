//
//  ExtendNSLogFunctionality..h
//  iReorganize
//
//  Created by lijunjie on 15/5/20.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  Reference:
//
//  [Quick Tip: Customize NSLog for Easier Debugging](http://code.tutsplus.com/tutorials/quick-tip-customize-nslog-for-easier-debugging--mobile-19066)

#ifndef iSearch_ExtendNSLogFunctionality__h
#define iSearch_ExtendNSLogFunctionality__h
#import <Foundation/Foundation.h>
#import "DateUtils.h"
#import "HttpUtils.h"
#import "const.h"

#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define NSLog(x...)
#endif

#ifdef DEBUG_ERROR
#define NSErrorPrint(error, args...) ExtendNSLogPrintError(__FILE__,__LINE__,__PRETTY_FUNCTION__, true, error, args);
#else
#define NSErrorPrint(error, args...) ExtendNSLogPrintError(__FILE__,__LINE__,__PRETTY_FUNCTION__, false, error, args);
#endif


#define NSActionLogger(actionName, actionResult) actionLogPost(__FILE__,__LINE__,__PRETTY_FUNCTION__, actionName, actionResult);

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);
void ExtendNSLogPrintError(const char *file, int lineNumber, const char *functionName,BOOL isPrintSuccessfully, NSError *error, NSString *format, ...);
void actionLogPost(const char *sourceFile, int lineNumber, const char *functionName, NSString *actionName, NSString *actionResult);
#endif
