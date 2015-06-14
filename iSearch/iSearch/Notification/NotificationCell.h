//
//  NotifictionCell.h
//  iNotification
//
//  Created by lijunjie on 15/5/28.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//

#ifndef iNotification_NotifictionCell_h
#define iNotification_NotifictionCell_h
#import <UIKit/UIKit.h>


/**
 *  公告通知中通知列表使用TableView显示，此类为TableViewCell用来显示单个通知明细
 */
@interface NotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UILabel *cellMsg;
@property (weak, nonatomic) IBOutlet UILabel *cellCreatedDate;


/**
 *  TableViewCell自身函数，自定义操作放在这里
 *
 *  @param reuseIdentifier <#reuseIdentifier description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

/**
 *  赋值 and 自动换行,计算出cell的高度
 *
 *  @param text label内容
 */
- (void)setIntroductionText:(NSString*)text;

/**
 *  设置公告创建日期，如果是今天的则显示[今天]，否则显示[yyyy/MM/dd]
 *
 *  @param createdDate 公告创建日期字符串
 */
- (void)setCreatedDate:(NSString*)createdDate;

@end

#endif
