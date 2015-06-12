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

#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#define NSErrorPrint(error, info) ExtendNSLogPrintError(__FILE__,__LINE__,__PRETTY_FUNCTION__, error, info, true);
#else
#define NSLog(x...)
#define NSErrorPrint(error, info) ExtendNSLogPrintError(__FILE__,__LINE__,__PRETTY_FUNCTION__, error, info, false);
#endif


void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);
void ExtendNSLogPrintError(const char *file, int lineNumber, const char *functionName, NSError *error, NSString *info, BOOL isPrintSuccessfully);

#endif
