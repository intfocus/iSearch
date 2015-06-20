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
#import "DisplayViewController.h"
#import "MainViewController.h"
#import "ContentUtils.h"

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
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _dataList = [FileUtils favoriteFileList];
    // order by updated_at by default.
    _dataList = [ContentUtils sortArray:_dataList Key:SLIDE_DESC_LOCAL_UPDATEAT Ascending:NO];
    [self configGMGridView];
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
        if([FileUtils checkSlideExist:currentDict[SLIDE_DESC_ID] Dir:FAVORITE_DIRNAME Force:YES]) {
            NSError *error;
            NSString *descContent = [FileUtils slideDescContent:currentDict[SLIDE_DESC_ID] Dir:FAVORITE_DIRNAME];
            NSMutableDictionary *descData = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding]
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:&error];
            
            if(error == nil && descData[SLIDE_DESC_ORDER] && [descData[SLIDE_DESC_ORDER] count] > 0) {
                NSString *thumbnailPath = [FileUtils fileThumbnail:currentDict[SLIDE_DESC_ID] PageID:[descData[SLIDE_DESC_ORDER] firstObject] Dir:FAVORITE_DIRNAME];
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
    HomeViewController *homeViewController = [self masterViewController];
    MainViewController *mainViewController = [homeViewController masterViewController];
    [mainViewController poupSlideInfo:dict[SLIDE_DESC_ID] Dir:FAVORITE_DIRNAME];
}


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
    NSMutableDictionary *currentDict = _dataList[index];
    NSString *fileID = currentDict[SLIDE_DESC_ID];
    
    // 如果文档已经下载，即可执行演示效果，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:fileID Dir:FAVORITE_DIRNAME Force:YES]) {
        NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
        [configDict setObject:fileID forKey:CONTENT_KEY_DISPLAYID];
        [configDict setObject:[NSNumber numberWithInt:SlideTypeFavorite] forKey:SLIDE_DISPLAY_TYPE];
        [configDict writeToFile:configPath atomically:YES];
        
        DisplayViewController *showVC = [[DisplayViewController alloc] init];
        [self presentViewController:showVC animated:NO completion:nil];
    }
}
@end