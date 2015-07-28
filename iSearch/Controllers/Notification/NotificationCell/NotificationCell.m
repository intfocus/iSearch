//
//  NotifictionCell.m
//  iNotification
//
//  Created by lijunjie on 15/5/28.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationCell.h"
#import "const.h"
#import "DateUtils.h"
#import "message.h"
#import "ExtendNSLogFunctionality.h"

@interface NotificationCell()
@end
@implementation NotificationCell
@synthesize labelTitle;
@synthesize labelMsg;
@synthesize labelDate;

/**
 *  default setting
 */
- (void)awakeFromNib {
    [self.labelTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:NOTIFICATION_TITLE_FONT]];
    [self.labelMsg setFont:[UIFont systemFontOfSize:NOTIFICATION_MSG_FONT]];
    [self.labelDate setFont:[UIFont systemFontOfSize:NOTIFICATION_DATE_FONT]];
}

/**
 *  设置公告创建日期，如果是今天的则显示[今天]，否则显示[yyyy/MM/dd]
 *
 *  @param createdDate 公告创建日期字符串
 */
- (void)setCreatedDate:(NSString*)createdDate {
    if(createdDate && ![createdDate length]) {
        // 服务器返回字段无内容，则显示" - "
        self.labelDate.text = @" - ";
        return;
    }
    NSInteger toIndex = [DATE_SIMPLE_FORMAT length];
    createdDate = [createdDate substringToIndex:toIndex];
    NSString *today = [DateUtils dateToStr:[NSDate date] Format:DATE_SIMPLE_FORMAT];
    
    // 如果是今天则显示"今天", 否则显示[yyyy/MM/dd]
    if([today isEqualToString:createdDate])
        self.labelDate.text = NOTIFICATION_I18N_CREATEDDATE;
    else
        self.labelDate.text = createdDate;
}

/**
 *  dict setter rewrite
 *
 *  @param dict NSDictionary
 */
- (void)setDict:(NSDictionary *)dict {
    self.labelTitle.text = dict[NOTIFICATION_FIELD_TITLE];
    self.labelMsg.text   = dict[NOTIFICATION_FIELD_MSG];
    
    _dict = dict;
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    if (iOSVersion < 8) {
        self.labelMsg.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 16 - 8;
    }
}

@end