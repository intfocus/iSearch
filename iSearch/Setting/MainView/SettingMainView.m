//
//  SettingViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingMainView.h"

#import "User.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "SettingUserInfo.h"

typedef NS_ENUM(NSInteger, SettingSectionIndex) {
    SettingAppInfoIndex  = 0,
    SettingUserInfoIndex = 1,
    SettingRegularIndex  = 2
};

@interface SettingMainView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, nonatomic) IBOutlet UIButton *btnLogout;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) User *user;

@end

@implementation SettingMainView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     *  实例变量初始化
     */
    self.dataList = [[NSMutableArray alloc] init];
    self.user     = [[User alloc] init];
    /**
     *  控件事件
     */
    UIBarButtonItem *navBtnClose = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(actionBtnClose:)];
    self.navigationItem.rightBarButtonItem = navBtnClose;
    self.navigationItem.title = @"设置";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(!self.user) {
        self.user = [[User alloc] init];
    }
    NSDictionary *localVersionInfo =[[NSBundle mainBundle] infoDictionary];
    NSString *currVersion = [localVersionInfo objectForKey:@"CFBundleShortVersionString"];
    
    [self.dataList addObject:@[@"app版本", currVersion]];
    [self.dataList addObject:@[@"登录用户", self.user.name]];
    [self.dataList addObject:@[@"常规设置", @""]];
}

#pragma mark - controls action
- (IBAction)actionBtnClose:(UIBarButtonItem *)sender {
    MainViewController *mainViewController = [self mainViewController];
    [mainViewController dimmissPopupSettingViewController];
}

- (IBAction)actionLogout:(id)sender {
    MainViewController *mainViewController = [self mainViewController];
    [mainViewController backToLoginViewController];
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataList[row][0];
    cell.detailTextLabel.text = self.dataList[row][1];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

// 选择某行, 跳转至[首页][通知]
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch ([indexPath row]) {
        case SettingUserInfoIndex:{
            SettingUserInfo *viewController = [[SettingUserInfo alloc] init];
            viewController.settingViewController = self.settingViewController;
            viewController.mainViewController = self.mainViewController;
            self.settingViewController.containerViewController = viewController;
        }
            break;
            
        default:
            break;
    }
}
@end
