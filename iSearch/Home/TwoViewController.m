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

#import "const.h"
#import "FileUtils.h"
#import "ViewSlide.h"
#import "ViewCategory.h"
#import "ContentUtils.h"

#import "HomeViewController.h"
#import "MainViewController.h"
#import "ContentViewController.h"

@interface TwoViewController ()<GMGridViewDataSource> {
    __gm_weak GMGridView *_gridView;
    NSMutableArray       *_dataList;
}
@property (strong, nonatomic) NSString  *deptID;
@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化
     */
    self.deptID = @"10";
    _dataList = [[NSMutableArray alloc] init];

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _dataList = [ContentUtils loadContentData:self.deptID CategoryID:CONTENT_ROOT_ID Type:LOCAL_OR_SERVER_LOCAL];
    // sort by id ascending by default.
    _dataList = [ContentUtils sortArray:_dataList Key:CONTENT_FIELD_ID Ascending:YES];
    [self configGMGridView];
    
    // 耗时间的操作放在些block中
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *data = [ContentUtils loadContentData:self.deptID CategoryID:CONTENT_ROOT_ID Type:LOCAL_OR_SERVER_SREVER];
        if([data count] > 0) {
            _dataList = [ContentUtils sortArray:data Key:CONTENT_FIELD_ID Ascending:YES];
            [self configGMGridView];
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
        
        NSMutableDictionary *currentDict = [_dataList objectAtIndex:index];
        NSString *name = currentDict[CONTENT_FIELD_NAME];
        
        // 服务器端Category没有ID值
        if(![currentDict objectForKey:CONTENT_FIELD_TYPE]) {
            currentDict[CONTENT_FIELD_TYPE] = CONTENT_CATEGORY;
            [_dataList objectAtIndex:index][CONTENT_FIELD_TYPE] = CONTENT_CATEGORY;
        }
        
        NSString *categoryType = [currentDict objectForKey:CONTENT_FIELD_TYPE];
        
        // 目录: 0; 文档: 1; 直文档: 2; 视频: 4
        if(![categoryType isEqualToString:CONTENT_CATEGORY]) {
            NSLog(@"Hey man, here is MyCategory, cannot load Slide!");
        }
        ViewCategory *viewCategory = [[[NSBundle mainBundle] loadNibNamed:@"ViewCategory" owner:self options:nil] lastObject];
        viewCategory.labelTitle.text = name;
        
        [viewCategory setImageWith:categoryType CategoryID:currentDict[CONTENT_FIELD_ID]];
        viewCategory.btnImageCover.tag = [currentDict[CONTENT_FIELD_ID] intValue];
        [viewCategory.btnImageCover addTarget:self action:@selector(actionCategoryClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell setContentView: viewCategory];
    }
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
    NSString *categoryID = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    // 点击分类导航行为记录
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    // init as NSMutableArray when key@CONTENT_KEY_NAVSTACK not exist
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    if(!configDict[CONTENT_KEY_NAVSTACK]) {
        [configDict setObject:mutableArray forKey:CONTENT_KEY_NAVSTACK];
    }
    // 进入是push
    mutableArray = [configDict objectForKey:CONTENT_KEY_NAVSTACK];
    // clear and then push, becase hereis root
    [mutableArray removeAllObjects];
    [mutableArray addObject:categoryID];
    [configDict setObject:mutableArray forKey:CONTENT_KEY_NAVSTACK];
    [configDict writeToFile:configPath atomically:true];
    
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