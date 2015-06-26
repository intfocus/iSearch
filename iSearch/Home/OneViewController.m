//
//  HomeViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OneViewController.h"

#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"
#import "const.h"
#import "ViewSlide.h"
#import "FileUtils.h"
#import "ContentUtils.h"
#import "Slide.h"

#import "MainViewController.h"
#import "HomeViewController.h"

@interface OneViewController ()<GMGridViewDataSource> {
    __gm_weak GMGridView *_gridView;
    NSMutableArray       *_dataList;
}
@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     * 实例变量初始化
     */
    _dataList = [[NSMutableArray alloc] init];
    
    HomeViewController *homeViewController = [self masterViewController];
    self.mainViewController = [homeViewController masterViewController];
    
    [self configGMGridView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_dataList removeAllObjects];
    for(Slide *slide in [FileUtils favoriteSlideList1]) {
        [_dataList addObject:[slide refreshFields]];
    }
    if([_dataList count] > 0) {
        _dataList = [ContentUtils sortArray:_dataList Key:SLIDE_DESC_LOCAL_UPDATEAT Ascending:NO];
    }
    // must be refresh
    [_gridView reloadData];
}

- (void)viewDidLayoutSubviews{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.frame.size.width *2, self.view.frame.size.height)];
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.view.layer.shadowOpacity = 0.2f;
    self.view.layer.shadowPath = shadowPath.CGPath;
}

- (void) configGMGridView {
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.style = GMGridViewStylePush;
    gmGridView.itemSpacing = 12;
    gmGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    gmGridView.centerGrid = YES;
    gmGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.view addSubview:gmGridView];
    _gridView = gmGridView;
    
    _gridView.dataSource = self;
    _gridView.mainSuperView = self.view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _gridView = nil;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(SIZE_GRID_VIEW_PAGE_WIDTH, SIZE_GRID_VIEW_PAGE_WIDTH);
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [_dataList count];
}

// GridViewCell界面 - 目录界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
    }
    ViewSlide *viewSlide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] lastObject];
    NSMutableDictionary *currentDict = [_dataList objectAtIndex:index];
    viewSlide.isFavorite = YES;
    viewSlide.dict = currentDict;
    viewSlide.masterViewController = [self mainViewController];
    [cell setContentView: viewSlide];
    return cell;
}
@end