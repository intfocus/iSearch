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

@implementation NotificationCell
@synthesize cellTitle;
@synthesize cellMsg;
@synthesize cellCreatedDate;

/**
 *  TableViewCell自身函数，自定义操作放在这里
 *
 *  @param reuseIdentifier <#reuseIdentifier description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initLayuot];
    }
    return self;
}
//初始化控件
-(void)initLayuot{
}

/**
 *  赋值 and 自动换行,计算出cell的高度
 *
 *  @param text label内容
 */
- (void)setIntroductionText:(NSString*)text {
    text = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //获得当前cell高度
    CGRect frame = [self frame];
    //文本赋值
    self.cellMsg.text = text;
    //设置label的最大行数
    self.cellMsg.numberOfLines = 10;
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:NOTIFICATION_MSG_FONT]}];
    // Values are fractional -- you should take the ceilf to get equivalent values
    CGSize labelSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    
    // CGSize size = CGSizeMake(300, 1000);
    // CGSize labelSize = [self.cellMsg.text sizeWithFont:self.cellMsg.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
    self.cellMsg.frame = CGRectMake(self.cellMsg.frame.origin.x, self.cellMsg.frame.origin.y, labelSize.width, labelSize.height);
    //计算出自适应的高度
    frame.size.height = labelSize.height+30;
    
    self.frame = frame;
}

/**
 *  设置公告创建日期，如果是今天的则显示[今天]，否则显示[yyyy/MM/dd]
 *
 *  @param createdDate 公告创建日期字符串
 */
- (void)setCreatedDate:(NSString*)createdDate {
    if(![createdDate length]) {
        // 服务器返回字段无内容，则显示" - "
        self.cellCreatedDate.text = @" - ";
        return;
    }
    NSInteger toIndex = [DATE_SIMPLE_FORMAT length];
    createdDate = [createdDate substringToIndex:toIndex];
    NSString *today = [DateUtils dateToStr:[NSDate date] Format:DATE_SIMPLE_FORMAT];
    
    // 如果是今天则显示"今天", 否则显示[yyyy/MM/dd]
    if([today isEqualToString:createdDate])
        self.cellCreatedDate.text = NOTIFICATION_I18N_CREATEDDATE;
    else
        self.cellCreatedDate.text = createdDate;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}
@end