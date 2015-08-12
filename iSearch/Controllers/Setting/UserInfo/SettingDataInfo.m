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
@end

@implementation SettingDataInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化
     */
    self.dataList = [[NSMutableArray alloc] init];

    NSString *title;
    if(self.indexRow == 0) {
        title = @"用户信息";
        
        User *user = [[User alloc] init];
        [self.dataList addObject:@[@"名称", user.name]];
        [self.dataList addObject:@[@"邮箱", user.email]];
        [self.dataList addObject:@[@"员工编号", user.employeeID]];
        [self.dataList addObject:@[@"上次登录时间", user.loginLast]];
    }
    else {
        title = @"应用信息";
        
        Version *version = [[Version alloc] init];
        [self.dataList addObject:@[@"应用名称", version.appName]];
        [self.dataList addObject:@[@"应用版本", version.current]];
        [self.dataList addObject:@[@"设备型号", [version machineHuman]]];
        [self.dataList addObject:@[@"系统语言", version.lang]];
        [self.dataList addObject:@[@"支持最低IOS版本",version.suport]];
        [self.dataList addObject:@[@"当前IOS版本",  [version.sdkName stringByReplacingOccurrencesOfString:version.platform withString:@""]]];
        [self.dataList addObject:@[@"系统空间", [FileUtils humanFileSize:version.fileSystemSize]]];
        [self.dataList addObject:@[@"系统可用空间", [FileUtils humanFileSize:version.fileSystemFreeSize]]];
    }
    
    self.navigationItem.title = title;
}

- (IBAction)actionBackToMain:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellID";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray *array            = self.dataList[indexPath.row];
    cell.textLabel.text       = array[0];
    cell.detailTextLabel.text = array[1];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
@end