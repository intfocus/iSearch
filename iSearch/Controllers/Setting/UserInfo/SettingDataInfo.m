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
#import "DatabaseUtils+ActionLog.h"

@interface SettingDataInfo()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataList;
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
        self.dataList = @[
            @[@"用户信息",
                @[
                   @[@"名称", user.name],
                   @[@"邮箱", user.email],
                   @[@"员工编号", user.employeeID],
                   @[@"上次登录时间", user.loginLast]
                ]
              ],
            @[@"本地信息",
              @[
                 @[@"本地记录", [[[DatabaseUtils alloc] init] localInfo]]
              ]
            ]
        ];
    }
    else {
        title = @"应用信息";
        
        Version *version = [[Version alloc] init];
        self.dataList = @[
            @[@"应用信息",
              @[
                @[@"应用名称", version.appName],
                @[@"应用版本", version.current]
              ]
            ],
            @[@"设备信息",
              @[
                 @[@"设备型号", [version machineHuman]],
                 @[@"系统语言", version.lang],
                 @[@"支持最低IOS版本",version.suport],
                 @[@"当前IOS版本",  [version.sdkName stringByReplacingOccurrencesOfString:version.platform withString:@""]],
                 @[@"系统空间", [FileUtils humanFileSize:version.fileSystemSize]],
                 @[@"系统可用空间", [FileUtils humanFileSize:version.fileSystemFreeSize]]
              ]
            ]
        ];
    }
    
    self.navigationItem.title = title;
}

- (IBAction)actionBackToMain:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataList count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList[section][1] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataList[section][0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellID";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSArray *array            = self.dataList[section][1][row];
    cell.textLabel.text       = array[0];
    cell.detailTextLabel.text = array[1];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 18.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 18.0;
}
@end