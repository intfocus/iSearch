//
//  HomeViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OneViewController.h"
#import "HomeViewController.h"

#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"
#import "const.h"
#import "ViewSlide.h"
#import "FileUtils.h"

@interface OneViewController ()<GMGridViewDataSource> {
    __gm_weak GMGridView *_gridView;
    NSMutableArray       *_dataList;
}

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataList = [[NSMutableArray alloc] init];
    // GMGridView Configuration
    [self configGMGridView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _dataList = [FileUtils favoriteFileList];
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
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        ViewSlide *slide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] lastObject];
        NSMutableDictionary *currentDict = [_dataList objectAtIndex:index];
        slide.isFavoriteFile = YES;
        slide.dict = currentDict;
        if([FileUtils checkSlideExist:currentDict[FILE_DESC_ID] Dir:FAVORITE_DIRNAME Force:YES]) {
            NSError *error;
            NSString *descContent = [FileUtils fileDescContent:currentDict[FILE_DESC_ID] Dir:FAVORITE_DIRNAME];
            NSMutableDictionary *descData = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding]
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:&error];
            
            if(error == nil && descData[FILE_DESC_ORDER] && [descData[FILE_DESC_ORDER] count] > 0) {
                NSString *thumbnailPath = [FileUtils fileThumbnail:currentDict[FILE_DESC_ID] PageID:[descData[FILE_DESC_ORDER] firstObject] Dir:FAVORITE_DIRNAME];
                [slide loadThumbnail:thumbnailPath];
            }
        }
        slide.btnFileInfo.tag = index;
        [slide.btnFileInfo addTarget:self action:@selector(actionPopupSlideInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell setContentView: slide];
    }
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_dataList removeObjectAtIndex:index];
}

/**
 *  控件事件
 */
- (IBAction)actionPopupSlideInfo:(UIButton *)sender {
    NSInteger index = [sender tag];
    NSMutableDictionary *dict = _dataList[index];
    HomeViewController *homeViewController = [self masterViewController];
    [homeViewController actionPopupSlideInfo:dict];
}
@end