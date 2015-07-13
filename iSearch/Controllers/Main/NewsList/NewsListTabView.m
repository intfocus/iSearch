//
//  NewsTabView.m
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "NewsListTabView.h"
#import "NewsListCell.h"

#import "SideViewController.h"
#import "MainViewController.h"
#import "MainEntryButton.h"

#import "const.h"
#import "DataHelper.h"
#import "ViewUtils.h"

@interface NewsListTabView () <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UISegmentedControl *tabView;
@property(nonatomic,weak)IBOutlet UITableView *listView;
@property(nonatomic,weak) NewsListCell *tmpCell;

@property(nonatomic,strong)NSArray *tableItems;
@property(nonatomic,strong)NSArray *dataListOne;
@property(nonatomic,strong)NSArray *dataListTwo;

@end

@implementation NewsListTabView

-(void)awakeFromNib{
    UINib *nib=[UINib nibWithNibName:NSStringFromClass([NewsListCell class]) bundle:nil];
    [self.listView registerNib:nib forCellReuseIdentifier:@"news"];
    
    NSMutableDictionary *notificationDatas = [DataHelper notifications];
    self.dataListOne = notificationDatas[NOTIFICATION_FIELD_GGDATA]; // 公告数据
    self.dataListTwo = notificationDatas[NOTIFICATION_FIELD_HDDATA]; // 预告数据
    [self onTabClick:self.tabView];
}

//#warning 点击之后刷新新闻
-(IBAction)onTabClick:(id)sender{
//    NSString *oneItem = @"第二季度PBL产品知识培训将于4/25日开始，欢迎各区代码参加。";
//    NSString *twoItem = @"台湾年会即将到来，还没有办理台湾通行证的代码请抓紧时间输。";
//    NSString *threeItem = [NSString stringWithFormat:@"长文测试自动挑选:1.%@ 2.%@", oneItem, twoItem];

    if (self.tabView.selectedSegmentIndex==0) {
        self.tableItems = self.dataListOne; //@[oneItem, twoItem, threeItem];
    }
    if (self.tabView.selectedSegmentIndex==1) {
        self.tableItems = self.dataListTwo; //@[oneItem, threeItem, twoItem];
    }
    [self.listView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableItems count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsListCell *cell= (NewsListCell *)[tableView dequeueReusableCellWithIdentifier:@"news" forIndexPath:indexPath];
    NSMutableDictionary *dict = [self.tableItems objectAtIndex:indexPath.row];
    NSString *message = dict[NOTIFICATION_FIELD_TITLE];
    
    cell.textLabel.numberOfLines=0;
    //cell.textLabel.adjustsFontSizeToFitWidth=YES;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.textLabel.text = message;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

// 选择某行, 跳转至[首页][通知]
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SideViewController *sideViewController = self.sideViewController;
    MainViewController *mainViewController = [sideViewController masterViewController];

    MainEntryButton *btn = (MainEntryButton *)[sideViewController.buttons objectAtIndex:EntryButtonNotification];
    [btn setTag:EntryButtonNotification];
    [mainViewController performSelector:@selector(onEntryClick:) withObject:btn];
    [sideViewController performSelector:@selector(buttonClicked:) withObject:btn];
    
}

// 取消选择某行(选择了其他行)
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsListCell *cell= (NewsListCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    NSLog(@"uns%@",cell);
}

// 自定义cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dict = [self.tableItems objectAtIndex:indexPath.row];
    NSString *message = dict[NOTIFICATION_FIELD_TITLE
                             ];
    CGSize size = [ViewUtils sizeForTableViewCell:message Width:240 FontSize:12];
    return size.height + 10.0f;
}

@end
