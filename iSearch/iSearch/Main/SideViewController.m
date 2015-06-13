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
#import "ContentViewController.h"

#import "UserHeadView.h"
#import "MainEntryButton.h"
#import "NewsListTabView.h"

@interface SideViewController ()

@property(nonatomic,weak)NewsListTabView *newsTabView;

@end

@implementation SideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor=[UIColor blackColor];
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
    [self.view addSubview:tab];
    self.newsTabView=tab;
}

-(void)placeEntryButton{
    NSInteger offset=20;

    {
        UserHeadView *head=(id)[ViewUtils loadNibClass:[UserHeadView class]];
        head.frame=CGRectOffset(head.frame, 0, offset);
        offset+=CGRectGetHeight(head.frame);
        [self.view addSubview:head];

        [head addTarget:self.masterViewController action:@selector(onUserHeadClick:) forControlEvents:UIControlEventTouchUpInside];
    }

    NSArray *array=@[@"首页",@"收藏",@"通知",@"下载",@"设置",@"登出"];

    //[array objectAtIndex:10];

    for (NSString *title in array) {
        MainEntryButton *entry=(id)[ViewUtils loadNibClass:[MainEntryButton class]];
        entry.frame=CGRectOffset(entry.frame, 0, offset);
        offset+=CGRectGetHeight(entry.frame);
        [self.view addSubview:entry];

        entry.tag=[array indexOfObject:title];
        entry.titleView.text=title;
        [entry addTarget:self.masterViewController action:@selector(onEntryClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(UIViewController *)viewControllerForTag:(NSInteger)tag{
    UIViewController *vc = nil;
    
    if (tag==0) {
        vc=[[ContentViewController alloc] initWithNibName:nil bundle:nil];
    }

    if (tag==2) {
        vc=[[NotificationViewController alloc] initWithNibName:nil bundle:nil];
    }
    if (tag==3) {
        vc=[[OfflineViewController alloc] initWithNibName:nil bundle:nil];
    }
    if (tag==5) {
        [self.masterViewController backToLoginViewController];
        return nil;
    }
    
    return vc;
}


@end
