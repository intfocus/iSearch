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
#import "ViewCategory.h"
#import "ContentUtils.h"

#import "MainViewController.h"
#import "ContentViewController.h"

@interface TwoViewController ()<GMGridViewDataSource> {
    __gm_weak GMGridView *_gmGridView;
    UIImageView          *changeBigImageView;
    NSMutableArray       *_data;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSString  *deptID;
@end

@implementation TwoViewController
@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.deptID = @"10";
    _data = [[NSMutableArray alloc] init];
    _data = [ContentUtils loadContentData:self.deptID CategoryID:CONTENT_ROOT_ID Type:LOCAL_OR_SERVER_LOCAL];
    
    // GMGridView Configuration
    [self configGMGridView];
    
    // 耗时间的操作放在些block中
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //NSActionLogger(@"主界面加载", @"successfully");
        
        NSMutableArray *data = [ContentUtils loadContentData:self.deptID CategoryID:CONTENT_ROOT_ID Type:LOCAL_OR_SERVER_SREVER];
        if([data count] > 0) {
            _data = data;
            [_gmGridView reloadData];
        }

    });
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

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [_data count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(SIZE_GRID_VIEW_PAGE_WIDTH, SIZE_GRID_VIEW_PAGE_WIDTH);
}

// GridViewCell界面 - 目录界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    GMGridViewCell *cell = [gridView dequeueReusableCell];

    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        ViewCategory *viewCategory = [[[NSBundle mainBundle] loadNibNamed:@"ViewCategory" owner:self options:nil] lastObject];
        
        NSMutableDictionary *currentDict = [_data objectAtIndex:index];
        
        // 服务器端Category没有ID值
        if(![currentDict objectForKey:CONTENT_FIELD_TYPE]) {
            currentDict[CONTENT_FIELD_TYPE] = CONTENT_CATEGORY;
            [_data objectAtIndex:index][CONTENT_FIELD_TYPE] = CONTENT_CATEGORY;
        }
        
        viewCategory.labelTitle.text = [currentDict objectForKey:CONTENT_FIELD_NAME];
        [viewCategory setImageWith:[_data objectAtIndex:index][CONTENT_FIELD_TYPE] CategoryID:[currentDict objectForKey:CONTENT_FIELD_ID]];
        viewCategory.btnEvent.tag = [[currentDict objectForKey:CONTENT_FIELD_ID] intValue];
        [viewCategory.btnEvent addTarget:self action:@selector(enterContentViewController:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell setContentView: viewCategory];
    }
    
    return cell;
}

/**
 *  进入目录界面;
 *  用户点击分类导航行为记录CONTENT_CONFIG_FILENAME[@CONTENT_KEY_NAVSTACK], 类型为NSMutableArray
 *  进入push, 返回是pop
 *
 *  @param sender UIButton
 */
- (IBAction)enterContentViewController:(UIButton *)sender {
    // 进入分类时，需要记录该分类ID
    NSString *categoryID = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    // 点击分类导航行为记录
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    // 不存在key@CONTENT_KEY_NAVSTACK则初始为空数组
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    if(![configDict objectForKey:CONTENT_KEY_NAVSTACK]) {
        [configDict setObject:mutableArray forKey:CONTENT_KEY_NAVSTACK];
    }
    // 进入是push
    mutableArray = [configDict objectForKey:CONTENT_KEY_NAVSTACK];
    // 此处为homePage应该先清空栈再宰相
    [mutableArray removeAllObjects];
    [mutableArray addObject:categoryID];
    [configDict setObject:mutableArray forKey:CONTENT_KEY_NAVSTACK];
    // 写入配置档
    [configDict writeToFile:configPath atomically:true];
    
    
    // 切换viewController视图
    MainViewController *mainViewController = (MainViewController *)[self masterViewController];
    ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
    [mainViewController setRightViewController:contentViewController withNav: NO];

}


- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_data removeObjectAtIndex:index];
}

@end