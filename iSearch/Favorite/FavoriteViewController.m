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

#import "FileUtils.h"
#import "const.h"
#import "SlideInfoView.h"

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
    
    [self configGridView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _dataList = [FileUtils favoriteFileList];
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
    _gridView = gridView;
    
    _gridView.style = GMGridViewStyleSwap;
    _gridView.itemSpacing = 50;
    _gridView.minEdgeInsets = UIEdgeInsetsMake(0,0,0,0);//UIEdgeInsetsMake(30, 10, -5, 10);
    _gridView.centerGrid = YES;
    _gridView.dataSource = self;
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.mainSuperView = self.view; 
    
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
        NSMutableDictionary *currentDict = [_dataList objectAtIndex:index];
        
        ViewSlide *slide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] objectAtIndex: 0];
        slide.isFavorite = YES;
        slide.dict = currentDict;
        slide.masterViewController = [self masterViewController];
        [cell setContentView: slide];
    }
    
    return cell;
}
- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_dataList removeObjectAtIndex:index];
}

@end