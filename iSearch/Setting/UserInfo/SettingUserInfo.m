//
//  SettingUserInfo.m
//  iSearch
//
//  Created by lijunjie on 15/7/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingUserInfo.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "SettingMainView.h"
#import "User.h"

@interface SettingUserInfo()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataList;
@end

@implementation SettingUserInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化
     */
    self.dataList = [[NSMutableArray alloc] init];
    
    /**
     *  控件事件
     */
    UIBarButtonItem *navBtnBackToMain = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(actionBackToMain:)];
    self.navigationItem.leftBarButtonItem = navBtnBackToMain;
    self.navigationItem.title = @"用户信息";
    
    
    User *user = [[User alloc] init];
    [self.dataList addObject:@[@"名称", user.name]];
    [self.dataList addObject:@[@"邮箱", user.email]];
    [self.dataList addObject:@[@"员工编号", user.employeeID]];
    //[self.dataList addObject:@[@"所属部门", user.deptID]];
    [self.dataList addObject:@[@"上次登录时间", user.loginLast]];
}

- (IBAction)actionBackToMain:(id)sender {
    SettingMainView *view = [[SettingMainView alloc] init];
    view.mainViewController = self.mainViewController;
    view.settingViewController = self.settingViewController;
    self.settingViewController.containerViewController = view;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellID";
    NSInteger row = [indexPath row];
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.dataList[row][0];
    cell.detailTextLabel.text = self.dataList[row][1];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
@end