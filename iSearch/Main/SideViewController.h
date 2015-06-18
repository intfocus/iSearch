//
//  SideViewController.h
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewUtils.h"
#import "UserHeadView.h"

@class MainViewController;

@interface SideViewController : UIViewController

@property(nonatomic,weak)MainViewController *masterViewController;
@property (nonatomic) UserHeadView *head;

-(UIViewController *)viewControllerForTag:(NSInteger)tag;

@end
