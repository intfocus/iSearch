//
//  DateUtils.m
//  iNotification
//
//  Created by lijunjie on 15/5/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateUtils.h"
#import "const.h"

@implementation DateUtils

/**
 *  通用函数: 字符串转日期。
 *
 *  @param str    日期字符串
 *  @param format 日期字符串的日期格式
 *
 *  @return 日期字符串对应的日期
 */
+ (NSString *) dateToStr: (NSDate *)date Format:(NSString*) format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}


/**
 *  通用函数: 日期转成字符串
 *
 *  @param date   待转换的日期
 *  @param format 转换字符串的格式
 *
 *  @return 指定格式的日期字符串
 */
+ (NSDate *) strToDate: (NSString *)str Format:(NSString*) format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString: str];
}

/**
 *  操作文档配置时修改时间戳。
 *  创建日期无，则添加。
 *  更新日期必须更新。
 *
 *  @param dict      配置档
 *  @param timestamp 当前时间
 *
 *  @return 更新后的配置档
 */
+ (NSMutableDictionary *) updateDescTimestamp:(NSMutableDictionary *)dict {
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];
    
    if(!dict[SLIDE_DESC_LOCAL_CREATEAT]) {
        [dict setObject:timestamp forKey:SLIDE_DESC_LOCAL_CREATEAT];
    }
    [dict setObject:timestamp forKey:SLIDE_DESC_LOCAL_UPDATEAT];
    return dict;
}
@end