//
//  ViewController.h
//  iSearch
//
//  Created by lijunjie on 15/5/29.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DetailViewController.h"
#import "RZSplitViewController.h"

/**
 *  框架为左右结构，此类为左边部分导航界面
 */
@interface MasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
// 左边导航栏列表
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

