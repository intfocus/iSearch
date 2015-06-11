//
//  ViewUtils.h
//  iLogin
//
//  Created by lijunjie on 15/5/6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iLogin_ViewUtils_h
#define iLogin_ViewUtils_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ViewUtils : NSObject
+ (void) simpleAlertView: delegate Title: (NSString*) title Message: (NSString*) message ButtonTitle: (NSString*) buttonTitle;
+ (NSDate *) strToDate: (NSString *)str Format:(NSString*) format;
+ (NSString *) dateToStr: (NSDate *)date Format:(NSString*) format;
@end

#endif
