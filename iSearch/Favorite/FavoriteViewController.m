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
    _dataList = [FileUtils favoriteFileList];
    
    [self configGridView];
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
    _gridView.minEdgeInsets = UIEdgeInsetsMake(30, 10, -5, 10);
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
        slide.dict = currentDict;
        // 数据初始化操作，须在initWithFrame操作前，因为该操作会触发slide内部处理
        slide = [slide initWithFrame:CGRectMake(0, 0, 230, 150)];
        
        [cell setContentView: slide];
    }
    
    return cell;
}
- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_dataList removeObjectAtIndex:index];
}

@end