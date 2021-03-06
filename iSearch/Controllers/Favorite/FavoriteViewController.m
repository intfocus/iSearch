//
//  FavoriteViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/18.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoriteViewController.h"
#import "GMGridView.h"
#import "ViewSlide.h"
#import "FileUtils+Slide.h"
#import "DataHelper.h"
#import "const.h"
#import "Slide.h"

#import "MainViewController.h"
#import "SideViewController.h"
#import "DisplayViewController.h"

@interface FavoriteViewController () <GMGridViewDataSource> {
    __gm_weak GMGridView *_gridView;
    NSMutableArray       *_dataList;
}
@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化/赋值
     */
    _dataList = [[NSMutableArray alloc] init];
    
    //导航栏标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-8, 0, 44, 44)];
    titleLabel.text = @"收藏";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:20.0];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [containerView addSubview:titleLabel];
    containerView.layer.masksToBounds = NO;
    UIBarButtonItem *leftTitleBI = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    self.navigationItem.leftBarButtonItem = leftTitleBI;
    
    [self configGridView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_dataList removeAllObjects];
    for(Slide *slide in [FileUtils favoriteSlideList1]) {
        [_dataList addObject:[slide refreshFields]];
    }
    if([_dataList count] > 0) {
        _dataList = [DataHelper sortArray:_dataList Key:CONTENT_FIELD_TITLE Ascending:NO];
    }
    [_gridView reloadData];
    
}
//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _gridView = nil;
}

/**
 *  配置GridView
 */
- (void) configGridView {
    GMGridView *gridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gridView];
    _gridView                 = gridView;
    _gridView.style           = GMGridViewStyleSwap;
    _gridView.itemSpacing     = 10;
    _gridView.minEdgeInsets   = UIEdgeInsetsMake(5, 5, 5, 5);
    _gridView.centerGrid      = YES;
    _gridView.dataSource      = self;
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.mainSuperView   = self.view;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [_dataList count];
}


- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(SIZE_GRID_VIEW_PAGE_WIDTH, SIZE_GRID_VIEW_PAGE_WIDTH);
}

// GridViewCell界面 - 目录界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
    }
    NSMutableDictionary *currentDict = [_dataList objectAtIndex:index];
    
    ViewSlide *viewSlide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] objectAtIndex: 0];
    viewSlide.isFavorite = YES;
    viewSlide.dict = currentDict;
    viewSlide.masterViewController = [self masterViewController];
    [cell setContentView:viewSlide];
    
    return cell;
}
- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_dataList removeObjectAtIndex:index];
}

@end