//
//  ViewUtils.m
//  iLogin
//
//  Created by lijunjie on 15/5/6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewUtils.h"

@implementation ViewUtils

+ (void) simpleAlertView: delegate Title: (NSString*) title Message: (NSString*) message ButtonTitle: (NSString*) buttonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:buttonTitle otherButtonTitles:nil];
    [alert show];
}

+ (NSString *) dateToStr: (NSDate *)date Format:(NSString*) format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}
+ (NSDate *) strToDate: (NSString *)str Format:(NSString*) format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString: str];
}

+ (UIView *)loadNibClass:(Class)cls {
    UINib *nib=[UINib nibWithNibName:NSStringFromClass(cls) bundle:nil];
    NSArray *views=[nib instantiateWithOwner:nil options:nil];
    return [views firstObject];
}

@end