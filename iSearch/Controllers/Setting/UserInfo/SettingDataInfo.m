//
//  SettingUserInfo.m
//  iSearch
//
//  Created by lijunjie on 15/7/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingDataInfo.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "User.h"
#import "Version.h"
#import "FileUtils.h"

@interface SettingDataInfo()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) NSMutableArray *dataListTwo;
@end

@implementation SettingDataInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化
     */
    self.dataList = [[NSMutableArray alloc] init];
    self.dataListTwo = [[NSMutableArray alloc] init];
    /**
     *  控件事件
     */
    NSString *title = (self.indexRow == 0 ? @"用户信息" : @"应用信息");
    self.navigationItem.title = title;
    
    
    
    User *user = [[User alloc] init];
    [self.dataList addObject:@[@"名称", user.name]];
    [self.dataList addObject:@[@"邮箱", user.email]];
    [self.dataList addObject:@[@"员工编号", user.employeeID]];
    [self.dataList addObject:@[@"上次登录时间", user.loginLast]];
    
    Version *version = [[Version alloc] init];
    [self.dataListTwo addObject:@[@"应用名称", version.appName]];
    [self.dataListTwo addObject:@[@"应用版本", version.current]];
    [self.dataListTwo addObject:@[@"设备名称", [[UIDevice currentDevice] name]]];
    [self.dataListTwo addObject:@[@"设备型号", [[UIDevice currentDevice] model]]];
    [self.dataListTwo addObject:@[@"系统语言", version.lang]];
    [self.dataListTwo addObject:@[@"支持最低IOS版本",version.suport]];
    [self.dataListTwo addObject:@[@"当前IOS版本",  [version.sdkName stringByReplacingOccurrencesOfString:version.platform withString:@""]]];
    [self.dataListTwo addObject:@[@"系统空间", [FileUtils humanFileSize:version.fileSystemSize]]];
    [self.dataListTwo addObject:@[@"系统可用空间", [FileUtils humanFileSize:version.fileSystemFreeSize]]];
   
}

- (IBAction)actionBackToMain:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.indexRow == 0 ? [self.dataList count] : [self.dataListTwo count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellID";
    NSInteger row = [indexPath row];
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray *array = (self.indexRow == 0 ? self.dataList : self.dataListTwo);
    cell.textLabel.text = array[row][0];
    cell.detailTextLabel.text = array[row][1];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
@end