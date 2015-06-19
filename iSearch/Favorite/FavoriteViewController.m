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
#import "UIViewController+CWPopup.h"
#import "SlideInfoView.h"

#import "MainViewController.h"
#import "SideViewController.h"

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
    
    // CWPopup 事件
    self.useBlurForPopup = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
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
        slide.isFavoriteFile = YES;
        slide.dict = currentDict;
        // 数据初始化操作，须在initWithFrame操作前，因为该操作会触发slide内部处理
        
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
        slide.btnSlideInfo.tag = index;
        [slide.btnSlideInfo addTarget:self action:@selector(actionPopupSlideInfo:) forControlEvents:UIControlEventTouchUpInside];
        [slide.btnDownloadOrDisplay addTarget:self action:@selector(actionDisplaySlide:) forControlEvents:UIControlEventTouchUpInside];
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
    SlideInfoView *slideInfoView = [[SlideInfoView alloc] init];
    slideInfoView.masterViewController = self;
    slideInfoView.isFavoriteFile = YES;
    slideInfoView.dict = dict;
    [self presentPopupViewController:slideInfoView animated:YES completion:^(void) {
        NSLog(@"popup view presented");
    }];
}

/**
 *  关闭弹出框；
 *  由于弹出框没有覆盖整个屏幕，所以关闭弹出框时，不会触发回调事件[viewDidAppear]。
 *  强制刷新本界面；
 */
- (void)dismissPopup {
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissed");
        }];
    }
    MainViewController *mainViewController = [self masterViewController];
    FavoriteViewController *favoriteViewController = [[FavoriteViewController alloc] init];
    [mainViewController setRightViewController:favoriteViewController withNav:YES];
}
@end