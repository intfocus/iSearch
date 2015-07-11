//
//  HomeViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwoViewController.h"
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"

#import "User.h"
#import "const.h"
#import "DataHelper.h"
#import "HttpUtils.h"
#import "FileUtils.h"
#import "ViewSlide.h"
#import "ViewCategory.h"

#import "HomeViewController.h"
#import "MainViewController.h"
#import "ContentViewController.h"

@interface TwoViewController ()<GMGridViewDataSource> {
    __gm_weak GMGridView *_gridView;
    NSMutableArray       *_dataList;
}
@property (strong, nonatomic) User  *user;
@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化
     */
    self.user = [[User alloc] init];
    _dataList = [[NSMutableArray alloc] init];
    [self configGMGridView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadContentData:LOCAL_OR_SERVER_LOCAL];
    [_gridView reloadData];
    
    // 耗时间的操作放在些block中
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([HttpUtils isNetworkAvailable]) {
            [self loadContentData:LOCAL_OR_SERVER_SREVER];
            [_gridView reloadData];
        }
    });
}

- (void)viewDidLayoutSubviews{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.frame.size.width *2, self.view.frame.size.height)];
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.view.layer.shadowOpacity = 0.2f;
    self.view.layer.shadowPath = shadowPath.CGPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _gridView = nil;
}


#pragma mark - controls configuration


- (void)loadContentData:(NSString *)type {
    NSArray *array = [DataHelper loadContentData:self.user.deptID CategoryID:CONTENT_ROOT_ID Type:type Key:CONTENT_FIELD_ID Order:YES];
    _dataList = [array objectAtIndex:0];
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
    NSString *categoryType = [currentDict objectForKey:CONTENT_FIELD_TYPE];
    
    // 目录: 0; 文档: 1; 直文档: 2; 视频: 4
    if(![categoryType isEqualToString:CONTENT_CATEGORY]) {
        NSLog(@"Hey man, here is MyCategory, cannot load Slide!");
    }
    ViewCategory *viewCategory = [[[NSBundle mainBundle] loadNibNamed:@"ViewCategory" owner:self options:nil] lastObject];
    //        NSString *name = [NSString stringWithFormat:@"%ld-%@-%@", (long)index, currentDict[CONTENT_FIELD_ID], currentDict[CONTENT_FIELD_NAME]];
    viewCategory.labelTitle.text = currentDict[CONTENT_FIELD_NAME];
    
    
    [viewCategory setImageWith:categoryType CategoryID:currentDict[CONTENT_FIELD_ID]];
    viewCategory.btnImageCover.tag = index;
    [viewCategory.btnImageCover addTarget:self action:@selector(actionCategoryClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell setContentView: viewCategory];
    return cell;
}

/**
 *  分类列表鼠标点击事件。
 *  进入目录界面;
 *  用户点击分类导航行为记录CONTENT_CONFIG_FILENAME[@CONTENT_KEY_NAVSTACK], 类型为NSMutableArray
 *  进入push, 返回是pop
 *
 *  @param sender UIButton
 */
- (IBAction)actionCategoryClick:(UIButton *)sender {
    NSInteger index = [sender tag];
    NSMutableDictionary *currentDict = _dataList[index];
    
    // 点击分类导航行为记录
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSLog(@"%@", configPath);
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    configDict[CONTENT_KEY_NAVSTACK] = [NSMutableArray arrayWithArray:@[currentDict]];
    [FileUtils writeJSON:configDict Into:configPath];
    
    // enter ContentViewController
    HomeViewController *homeViewController = [self masterViewController];
    MainViewController *mainViewController = [homeViewController masterViewController];
    ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
    contentViewController.masterViewController = mainViewController;
    [mainViewController setRightViewController:contentViewController withNav:NO];
}


- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_dataList removeObjectAtIndex:index];
}

@end