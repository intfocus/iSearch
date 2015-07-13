//
//  SettingAppInfo.h
//  iSearch
//
//  Created by lijunjie on 15/7/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_SettingAppInfo_h
#define iSearch_SettingAppInfo_h
#import <UIKit/UIKit.h>
@class MainViewController;
@class SettingViewController;

@interface SettingAppInfo : UIViewController
@property (nonatomic,nonatomic) MainViewController *mainViewController;
@property (nonatomic,nonatomic) SettingViewController *settingViewController;
@end

#endif
