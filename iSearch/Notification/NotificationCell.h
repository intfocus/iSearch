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

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelMsg;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;

/**
 *  设置公告创建日期，如果是今天的则显示[今天]，否则显示[yyyy/MM/dd]
 *
 *  @param createdDate 公告创建日期字符串
 */
- (void)setCreatedDate:(NSString*)createdDate;

@end

#endif
