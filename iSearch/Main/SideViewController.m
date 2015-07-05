//
//  SideViewController.m
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "SideViewController.h"
#import "MainViewController.h"

#import "NotificationViewController.h"
#import "OfflineViewController.h"
#import "HomeViewController.h"
#import "FavoriteViewController.h"
#import "SettingViewController.h"


#import "UserHeadView.h"
#import "MainEntryButton.h"
#import "NewsListTabView.h"
#import "const.h"

@interface SideViewController ()

@property(nonatomic,weak)NewsListTabView *newsTabView;

@end

@implementation SideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.buttons = [@[] mutableCopy];
    [self placeEntryButton];
    [self placeNewsTab];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    CGRect bounds=self.view.bounds;
    CGRect frame=self.newsTabView.frame;
    frame.origin.y=CGRectGetHeight(bounds)-CGRectGetHeight(frame);
    self.newsTabView.frame=frame;
}

-(void)placeNewsTab{
    NewsListTabView *tab=(id)[ViewUtils loadNibClass:[NewsListTabView class]];
    tab.sideViewController = self;
    [self.view addSubview:tab];
    self.newsTabView=tab;
}

-(void)placeEntryButton{
    NSInteger offset=20;
    
    {
        self.head=(id)[ViewUtils loadNibClass:[UserHeadView class]];
        self.head.frame=CGRectOffset(self.head.frame, 0, offset);
        offset+=CGRectGetHeight(self.head.frame);
        [self.view addSubview:self.head];
        
        [self.head addTarget:self.masterViewController action:@selector(onUserHeadClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // warning 此处位置调整时，需要修改
    NSArray *array=@[@"首页",@"收藏",@"通知",@"设置"];//,@"下载",@"登出"];//
    NSArray *images = @[@"iconIndex",@"iconCollection",@"iconNotification",@"iconDownload",@"iconSetup"];//,@"iconSignOut"];//

    //[array objectAtIndex:10];

    for (NSString *title in array) {
        MainEntryButton *entry=(id)[ViewUtils loadNibClass:[MainEntryButton class]];
        entry.frame=CGRectOffset(entry.frame, 0, offset);
        offset+=CGRectGetHeight(entry.frame);
        [self.view addSubview:entry];

        entry.tag=[array indexOfObject:title];
        entry.titleView.text=title;
        entry.iconView.image = [UIImage imageNamed:images[entry.tag]];
        [entry addTarget:self.masterViewController action:@selector(onEntryClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:entry];
        [entry addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self buttonClicked:self.buttons.firstObject];
}

- (void)buttonClicked:(MainEntryButton *)button{
    for (MainEntryButton *entry in self.buttons) {
        entry.backgroundColor = [UIColor clearColor];
        entry.heightConstraint.constant = 0.5;
        entry.heightConstraint2.constant = 0.5;
    }
    if ([self.buttons indexOfObject:button] > 0) {
        MainEntryButton *lastOne = self.buttons[[self.buttons indexOfObject:button] - 1];
        lastOne.heightConstraint.constant = 0;
        lastOne.heightConstraint2.constant = 0;
    }
    button.backgroundColor = [UIColor colorWithRed:45/255.0 green:45/255.0 blue:45/255.0 alpha:1.0];
}

-(UIViewController *)viewControllerForTag:(NSInteger)tag{
    UIViewController *vc = nil;
    switch (tag) {
        case EntryButtonHomePage:
            vc=[[HomeViewController alloc] initWithNibName:nil bundle:nil];
            break;
            
        case EntryButtonFavorite:
            vc=[[FavoriteViewController alloc] initWithNibName:nil bundle:nil];
            break;
            
        case EntryButtonNotification:
            vc=[[NotificationViewController alloc] initWithNibName:nil bundle:nil];
            break;
            
        case EntryButtonDownload:
            vc=[[OfflineViewController alloc] initWithNibName:nil bundle:nil];
            break;
            
        case EntryButtonSetting:
            break;
        default:
            break;
    }
    
    if(!vc) vc = [[OfflineViewController alloc] initWithNibName:nil bundle:nil];
    return vc;
}


@end
