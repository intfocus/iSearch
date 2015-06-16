//
//  NewsTabView.m
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "NewsListTabView.h"
#import "NewsListCell.h"
#import "ViewUtils.h"

@interface NewsListTabView () <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UISegmentedControl *tabView;
@property(nonatomic,weak)IBOutlet UITableView *listView;
@property(nonatomic,weak) NewsListCell *tmpCell;

@property(nonatomic,strong)NSArray *tableItems;

@end

@implementation NewsListTabView

-(void)awakeFromNib{
    UINib *nib=[UINib nibWithNibName:NSStringFromClass([NewsListCell class]) bundle:nil];
    [self.listView registerNib:nib forCellReuseIdentifier:@"news"];
    [self onTabClick:self.tabView];
}

#warning 点击之后刷新新闻
-(IBAction)onTabClick:(id)sender{
    NSString *oneItem = @"第二季度PBL产品知识培训将于4/25日开始，欢迎各区代码参加。";
    NSString *twoItem = @"台湾年会即将到来，还没有办理台湾通行证的代码请抓紧时间输。";
    NSString *threeItem = [NSString stringWithFormat:@"长文测试自动挑选:1.%@ 2.%@", oneItem, twoItem];

    if (self.tabView.selectedSegmentIndex==0) {
        self.tableItems=@[oneItem, twoItem, threeItem];
    }
    if (self.tabView.selectedSegmentIndex==1) {
        self.tableItems=@[oneItem, threeItem, twoItem];
    }
    [self.listView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableItems count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsListCell *cell= (NewsListCell *)[tableView dequeueReusableCellWithIdentifier:@"news" forIndexPath:indexPath];
    cell.textLabel.numberOfLines=0;
    //cell.textLabel.adjustsFontSizeToFitWidth=YES;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    NSString *text = [self.tableItems objectAtIndex:indexPath.row];
    cell.textLabel.text = text;

    return cell;
}

// 选择某行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsListCell *cell= (NewsListCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor blackColor];
    NSLog(@"s%@",cell);
}

// 取消选择某行(选择了其他行)
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsListCell *cell= (NewsListCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor whiteColor];
    NSLog(@"uns%@",cell);
}

// 自定义cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *text = [self.tableItems objectAtIndex:indexPath.row];
    CGSize size = [ViewUtils sizeForTableViewCell:text Width:240 FontSize:12];
    return size.height + 10.0f;
}

@end
