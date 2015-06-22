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
        slide.isFavoriteFile = YES;
        slide.dict = currentDict;
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


#pragma mark - controls action

/**
 *  本viewController中为服务端所有文件列表；
 *  如果已经下载，则可以[演示], 否则需要下载, 所下载文件在FILE_DIRNAME/下
 *
 *  与DisplayViewController传递文件ID通过CONFIG_DIRNAME/CONETNT_CONFIG_FILENAME[@CONTENT_KEY_DISPLAYID]
 *
 *  @param IBAction [演示]按钮点击事件
 *
 *  @return 演示界面
 */
// 如果文件已经下载，文档原[下载]按钮显示为[演示]
- (IBAction)actionDisplaySlide:(UIButton *)sender {
    NSInteger index = [sender tag];
    NSMutableDictionary *currentDict = [_dataList objectAtIndex:index];
    NSString *slideID = currentDict[SLIDE_DESC_ID];
    
    // 如果文档已经下载，即可执行演示效果，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:slideID Dir:FAVORITE_DIRNAME Force:YES]) {
        NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
        [configDict setObject:slideID forKey:CONTENT_KEY_DISPLAYID];
        [configDict setObject:[NSNumber numberWithInt:SlideTypeFavorite] forKey:SLIDE_DISPLAY_TYPE];
        [configDict writeToFile:configPath atomically:YES];
        
        DisplayViewController *showVC = [[DisplayViewController alloc] init];
        [self presentViewController:showVC animated:NO completion:nil];
    }
}
/**
 *  poupView display Slide info.
 *
 *  @param sender UIButton
 */
- (IBAction)actionPopupSlideInfo:(UIButton *)sender {
    NSInteger index = [sender tag];
    NSMutableDictionary *dict = _dataList[index];
    MainViewController *mainViewController = [self masterViewController];
    [mainViewController poupSlideInfo:dict[SLIDE_DESC_ID] Dir:FAVORITE_DIRNAME];
}
@end