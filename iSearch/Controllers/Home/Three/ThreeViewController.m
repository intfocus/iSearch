//
//  HomeViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreeViewController.h"
#import "HomeViewController.h"
#import "MainViewController.h"

#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"
#import "const.h"
#import "ViewSlide.h"
#import "FileUtils.h"
#import "Slide.h"
#import "ActionLog.h"

@interface ThreeViewController ()<GMGridViewDataSource> {
    __gm_weak GMGridView *_gmGridView;
    NSMutableArray       *_dataList;
}
@property (strong, nonatomic) ActionLog *actionLog;
@end

@implementation ThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     * 实例变量初始化
     */
    _dataList  = [[NSMutableArray alloc] init];
    _actionLog = [[ActionLog alloc] init];
    [self configGMGridView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_dataList removeAllObjects];

    _dataList = [self.actionLog records];
    [_gmGridView reloadData];
}

-(void)viewDidLayoutSubviews{
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
    _gmGridView = gmGridView;
    
    
    _gmGridView.dataSource = self;
    _gmGridView.mainSuperView = self.view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _gmGridView = nil;
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
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
    }
    ViewSlide *viewSlide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] objectAtIndex: 0];
    
    NSMutableDictionary *currentDict = [_dataList objectAtIndex:index];
    NSString *slideID                = currentDict[LOCAL_COLUMN_SLIDE_ID];
    BOOL isFavorite                  = [currentDict[LOCAL_COLUMN_SLIDE_TYPE] isEqualToString:FAVORITE_DIRNAME];
    Slide *slide = [Slide findById:slideID isFavorite:isFavorite];
    
    viewSlide.isFavorite           = isFavorite;
    viewSlide.dict                 = [slide refreshFields];
    viewSlide.masterViewController = [[self masterViewController] masterViewController];

    [cell setContentView: viewSlide];
    
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {}
@end