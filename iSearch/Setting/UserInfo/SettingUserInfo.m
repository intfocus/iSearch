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

@interface SettingUserInfo()
@property (nonatomic, weak) IBOutlet UILabel *labelName;
@property (nonatomic, weak) IBOutlet UILabel *labelEmployee;
@property (nonatomic, weak) IBOutlet UILabel *labelDept;
@property (nonatomic, strong) User *user;
@end

@implementation SettingUserInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化
     */
    self.user = [[User alloc] init];
    
    /**
     *  控件事件
     */
    UIBarButtonItem *navBtnBackToMain = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(actionBackToMain:)];
    self.navigationItem.leftBarButtonItem = navBtnBackToMain;
    self.navigationItem.title = @"用户信息";
    
    self.labelName.text     = [NSString stringWithFormat:@"%@: %@", @"名称", self.user.name];
    self.labelEmployee.text = [NSString stringWithFormat:@"%@: %@", @"员工编号", self.user.employeeID];
    self.labelDept.text = [NSString stringWithFormat:@"%@: %@", @"所属部门", self.user.deptID];
}

- (IBAction)actionBackToMain:(id)sender {
    SettingMainView *view = [[SettingMainView alloc] init];
    view.mainViewController = self.mainViewController;
    view.settingViewController = self.settingViewController;
    self.settingViewController.containerViewController = view;
}
@end