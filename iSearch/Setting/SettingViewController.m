//
//  SettingViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingViewController.h"
#import "MainViewController.h"

@interface SettingViewController()
@property (nonatomic, nonatomic) IBOutlet UINavigationItem *navigationPanel;
@property (nonatomic, nonatomic) IBOutlet UIButton *btnLogout;

@end

@implementation SettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  控件事件
     */
    UIBarButtonItem *navBtnClose = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(actionBtnClose:)];
    self.navigationPanel.rightBarButtonItem = navBtnClose;
    self.navigationPanel.title = @"设置";
    
    [self.btnLogout addTarget:self action:@selector(actionLogout:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - controls action
- (IBAction)actionBtnClose:(UIBarButtonItem *)sender {
    MainViewController *mainViewController = [self masterViewController];
    [mainViewController dimmissPopupSettingViewController];
}

- (IBAction)actionLogout:(id)sender {
    
    MainViewController *mainViewController = [self masterViewController];
    [mainViewController backToLoginViewController];
}
@end
