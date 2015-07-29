//
//  MainAddNewTagView.m
//  iSearch
//
//  Created by lijunjie on 15/6/17.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainAddNewTagView.h"
#import "ExtendNSLogFunctionality.h"
#import "FileUtils.h"

#import "TagListView.h"
#import "AddNewTagView.h"


@interface MainAddNewTagView()

@property(nonatomic,strong)IBOutlet UIView *mainView;
@end

@implementation MainAddNewTagView

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  控件事件
     */
    TagListView *view         = [[TagListView alloc] initWithNibName:nil bundle:nil];
    view.masterViewController = self;
    self.mainViewController   = view;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!self.mainViewController) {
        TagListView *view         = [[TagListView alloc] initWithNibName:nil bundle:nil];
        view.masterViewController = self;
        self.mainViewController   = view;
    }
}

- (void)setMainViewController:(UIViewController *)mainView{
    [_mainViewController removeFromParentViewController];
    [_mainViewController.view removeFromSuperview];
    
    if (!mainView) return;

    UINavigationController *nav   = [[UINavigationController alloc] initWithRootViewController:mainView];
    nav.navigationBar.translucent = NO;
    nav.toolbar.translucent       = NO;
    mainView                      = nav;
    
    _mainViewController=mainView;
    [self addChildViewController:mainView];
    [self.mainView addSubview:mainView.view];

    mainView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    mainView.view.frame            = self.mainView.bounds;
}
@end