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
    TagListView *view  = [[TagListView alloc] initWithNibName:nil bundle:nil];
    view.masterViewController = self;
    self.mainViewController   = view;
}

- (void)setMainViewController:(UIViewController *)mView{
    [_mainViewController removeFromParentViewController];
    [_mainViewController.view removeFromSuperview];
    
    if (!mView) return;
    
    _mainViewController=mView;
    [self addChildViewController:mView];
    [self.mainView addSubview:mView.view];
    
    mView.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    mView.view.frame=self.mainView.bounds;
}
@end