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
#import "SettingMainView.h"

@interface SettingViewController()
@property (nonatomic,weak) IBOutlet UIView *containerView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  控件事件
     */

    SettingMainView *viewController      = [[SettingMainView alloc] initWithNibName:nil bundle:nil];
    viewController.settingViewController = self;
    viewController.mainViewController    = self.masterViewController;
    self.containerViewController         = viewController;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!self.containerView) {
        SettingMainView *viewController      = [[SettingMainView alloc] initWithNibName:nil bundle:nil];
        viewController.settingViewController = self;
        viewController.mainViewController    = self.masterViewController;
        self.containerViewController         = viewController;
    }
}

- (void)setContainerViewController:(UIViewController *)mainView{
    [_containerViewController removeFromParentViewController];
    [_containerViewController.view removeFromSuperview];
    
    if (!mainView) return;
    
    UINavigationController *nav   = [[UINavigationController alloc] initWithRootViewController:mainView];
    nav.navigationBar.translucent = NO;
    nav.toolbar.translucent       = NO;
    mainView                      = nav;
    
    _containerViewController=mainView;
    [self addChildViewController:mainView];
    [self.containerView addSubview:mainView.view];
    
    mainView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    mainView.view.frame            = self.containerView.bounds;
}@end
