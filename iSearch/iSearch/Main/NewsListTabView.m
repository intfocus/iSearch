//
//  NewsTabView.m
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "NewsListTabView.h"

#import "NewsListCell.h"

@interface NewsListTabView () <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UISegmentedControl *tabView;
@property(nonatomic,weak)IBOutlet UITableView *listView;

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
    if (self.tabView.selectedSegmentIndex==0) {
        self.tableItems=@[@"pub1",@"pub2",@"pub3"];
    }
    if (self.tabView.selectedSegmentIndex==1) {
        self.tableItems=@[@"act1",@"act2",@"act3"];
    }
    [self.listView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableItems count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"news" forIndexPath:indexPath];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.adjustsFontSizeToFitWidth=YES;
    NSString *text=[self.tableItems objectAtIndex:indexPath.row];
    cell.textLabel.text=text;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@",cell);
}

@end
