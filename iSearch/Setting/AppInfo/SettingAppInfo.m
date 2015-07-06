//
//  SettingAppInfo.m
//  iSearch
//
//  Created by lijunjie on 15/7/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingAppInfo.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "SettingMainView.h"
#import "Version.h"


@interface SettingAppInfo()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataList;
@end

@implementation SettingAppInfo

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
    self.navigationItem.title = @"应用信息";
    
    Version *version = [[Version alloc] init];
    
    [self.dataList addObject:@[@"应用名称", version.appName]];
    [self.dataList addObject:@[@"应用版本", version.current]];
    [self.dataList addObject:@[@"当前语言", version.lang]];
    [self.dataList addObject:@[@"支持最低版本",version.suport]];
    [self.dataList addObject:@[@"当前版本",  [version.sdkName stringByReplacingOccurrencesOfString:version.platform withString:@""]]];
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