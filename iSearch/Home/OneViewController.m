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
#import "ViewCategory.h"

@interface OneViewController ()<GMGridViewDataSource> {
    __gm_weak GMGridView *_gmGridView;
    UIImageView          *changeBigImageView;
    NSMutableArray       *_data;
}

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _data = [[NSMutableArray alloc] init];
    NSInteger i = 0;
    for(i=0; i< 13; i++) {
        [_data addObject:[NSString stringWithFormat:@"我的收藏-%ld", (long)i]];
    }
    
    // GMGridView Configuration
    [self configGMGridView];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.frame.size.width *2, self.view.frame.size.height)];
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowColor = [UIColor redColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.view.layer.shadowOpacity = 0.2f;
    self.view.layer.shadowPath = shadowPath.CGPath;
}

-(void)viewDidLayoutSubviews{
}

- (void) configGMGridView {
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.style = GMGridViewStylePush;
    gmGridView.itemSpacing = 12;
    gmGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    gmGridView.centerGrid = YES;
    gmGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
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
    return [_data count];
}

// GridViewCell界面 - 目录界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        ViewCategory *viewCategory = [[[NSBundle mainBundle] loadNibNamed:@"ViewCategory" owner:self options:nil] lastObject];
        viewCategory.labelTitle.text = [_data objectAtIndex:index];
        
        [viewCategory setImageWith:@"0" CategoryID:@"1"];
        [cell setContentView: viewCategory];
    }
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_data removeObjectAtIndex:index];
}
@end