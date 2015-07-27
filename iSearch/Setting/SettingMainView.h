//
//  SettingViewController.h
//  iSearch
//
//  Created by lijunjie on 15/6/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_SettingMainView_h
#define iSearch_SettingMainView_h
#import <UIKit/UIKit.h>
@class MainViewController;
@class SettingViewController;

@interface SettingMainView : UIViewController
@property (nonatomic,nonatomic) MainViewController *mainViewController;
@property (nonatomic,nonatomic) SettingViewController *settingViewController;
@end
#endif
