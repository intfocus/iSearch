//
//  ViewController.m
//  iContent
//
//  Created by lijunjie on 15/5/7.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  ISearch - 目录同步
//
//  步骤
//  1. 加载目录
//      1.1 网络环境良好，HttpPost 服务器获取网站目录（json数组格式）
//          Post /CONENT_URL_PATH {
//              user: user-name or user-email,
//              type: 0 , -- 目录: 0; 文档: 1; 直文档: 2; 视频: 4
//                id: 0 ,
//              lang: zh-CN -- app language
//          }
//          Response [{
//              type: 0,  -- 目录: 0; 文档: 1; 直文档: 2; 视频: 4
//              name: dir-name or file-name,
//              desc: desc,
//               tag:  tags, // TODO 待确认是否需要
//                id: 1,    -- 下次请求使用
//               url: zip download url when type is file
//          }]
//
//
//          说明:
//            1. 请求目录返回josn字符串写入CONTENT_DIRNAME/id.json
//            2. 请求下载文档，压缩包放至DOWNLOAD_DIRNAME/id.zip， 解压至FILE_DIRNAME/id
//            3. 压缩包文件名称不作要求，其压缩文件格式应为: id/{index.html, images/*}
//
//      1.2 无网络环境，但CONTENT_DIRNAME/id.json存在，读取该缓存信息加载目录，否则界面为空
//
//  2. 目录展示
//      2.1 加载每个[文件]界面时
//          [下载按钮]: 检测FILE_DIRNAME/id是否存在, 存在显示[演示],否则显示[下载]
//          其他按钮功能: 此代码中未实现
//
//          [演示]仅仅使用webview展示html文件，[长按]返回主界面
//
//      2.2 加载每个[目录]界面时,仅显示目录名，点击重复[步骤1]
//
//  TODO:
//      1. 目录加载的路径；eg: 目录一/目录一.1/目录一.1.a
//      2. iphone/ipad目录中控件尺寸比例不一致
//      3. 已经下载文件，是否删除
//
//  用彷点击行为记录:
//  点击分类push，点击[返回]pop, 如果到了根节点，则返回HomePage


#import "ContentViewController.h"

#import "GMGridView.h"
#import "ViewSlide.h"
#import "ViewCategory.h"

#import "DisplayViewController.h"
#import "HomeViewController.h"
#import "MainViewController.h"

#import "User.h"
#import "ContentUtils.h"
#import "DataHelper.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "ExtendNSLogFunctionality.h"
#import "MMMaterialDesignSpinner.h"

#define NUMBER_ITEMS_ON_LOAD 10
#define SIZE_GRID_VIEW_CELL_WIDTH 120//230
#define SIZE_GRID_VIEW_CELL_HEIGHT 80

//////////////////////////////////////////////////////////////
#pragma mark ViewController (privates methods)
//////////////////////////////////////////////////////////////

@interface ContentViewController ()  <GMGridViewDataSource>
{
    __gm_weak GMGridView     *_gridView;
    NSMutableArray *_dataList;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // 目录结构图
@property (strong, nonatomic) NSString  *deptID;
@property (strong, nonatomic) NSMutableDictionary *categoryDict; // 依赖于categoryID
@property (strong, nonatomic) NSMutableArray *dataListOne; // 分类
@property (strong, nonatomic) NSMutableArray *dataListTwo; // 文档

// 顶部控件
@property (weak, nonatomic) IBOutlet UIButton *navBtnBack; // 返回
@property (weak, nonatomic) IBOutlet UILabel  *navLabel;   // 当前分类名称
@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;
@property (weak, nonatomic) IBOutlet UIButton *navBtnFilterAll;   // 全部
@property (weak, nonatomic) IBOutlet UIButton *navBtnFilterOne;   // 分类
@property (weak, nonatomic) IBOutlet UIButton *navBtnFilterTwo;   // 文献
@property (strong, nonatomic) NSNumber        *filterType;        // 依此排序
@property (weak, nonatomic) IBOutlet UIButton *navBtnSortOne; // 按时间排序
@property (weak, nonatomic) IBOutlet UIImageView *dateSortImageView;
@property (weak, nonatomic) IBOutlet UIButton *navBtnSortTwo; // 按名称排序
@property (weak, nonatomic) IBOutlet UIImageView *nameSortImageView;
@property (weak, nonatomic) IBOutlet UILabel *nothingLabel;
@property (strong, nonatomic) NSMutableArray *navActionStack;// 用户点击行为


// 内存管理
@property (nonatomic, nonatomic) ContentViewController *contentViewController;
// http download variables end

@end

@implementation ContentViewController
@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化
     */
    _dataList           = [[NSMutableArray alloc] init];
    self.navActionStack = [[NSMutableArray alloc] init];
    self.categoryDict   = [[NSMutableDictionary alloc] init];
    
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    self.navActionStack = configDict[CONTENT_KEY_NAVSTACK];
    self.categoryDict   = [self.navActionStack lastObject];

    self.deptID     = [User deptID];
    self.filterType = [NSNumber numberWithInteger:FilterAll];
    
    [self navFilterFont];
    /**
     *  导航栏控件
     */
    [self.navBtnBack setTitle:@"返回" forState:UIControlStateNormal];
    
    [self.navBtnBack addTarget:self action:@selector(actionNavBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBtnSortOne addTarget:self action:@selector(actionNavSortByDate:) forControlEvents:UIControlEventTouchUpInside];
    self.navBtnSortOne.tag = SortByAscending;
    
    [self.navBtnSortTwo addTarget:self action:@selector(actionNavSortByName:) forControlEvents:UIControlEventTouchUpInside];
    self.navBtnSortTwo.tag = SortByAscending;
    
    [self.navBtnFilterAll addTarget:self action:@selector(actionNavFilterAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBtnFilterOne addTarget:self action:@selector(actionNavFilterOne:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBtnFilterTwo addTarget:self action:@selector(actionNavFilterTwo:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view.backgroundColor=[UIColor blackColor];
    
    [self configGridView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self refreshContent];
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    
//     [self configSpinner];
//}

- (void)viewDidUnload {
    [super viewDidUnload];
    _gridView = nil;
}
//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"didReceiveMemoryWarning");
    _gridView = nil;
}


#pragma mark - assistant methods
- (void) refreshContent {
    [self loading];

    //  1. 读取本地缓存，优先加载界面
    [self loadContentData:LOCAL_OR_SERVER_LOCAL];
    [_gridView reloadData];
    
    // 耗时间的操作放在些block中
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([HttpUtils isNetworkAvailable]) {
            [self loadContentData:LOCAL_OR_SERVER_SREVER];
            [_gridView reloadData];
        }
    });
    self.navBtnBack.enabled = YES;
    [self performSelector:@selector(loaded) withObject:self afterDelay:0.3f];
    self.navLabel.text = self.categoryDict[CONTENT_FIELD_NAME];
}

#pragma mark - spinner loading
- (void)loading {
    if(!self.spinnerView) return;
    
    [self.navLabel setHidden:YES];
    [self.spinnerView startAnimating];
}
- (void)loaded {
    if(!self.spinnerView) return;
    
    [self.spinnerView stopAnimating];
    [self.navLabel setHidden:NO];
}

- (void)configSpinner {
    CGRect frame = self.navLabel.frame;
    frame.origin.x = frame.origin.x + frame.size.width/2;
    frame.origin.y = frame.origin.y + 30;
    frame.size.width = 20;
    frame.size.height = 20;
    if(!self.spinnerView) {
        self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:frame];
        // Set the line width of the spinner
        self.spinnerView.lineWidth = 1.5f;
        // Set the tint color of the spinner
        self.spinnerView.tintColor = [UIColor purpleColor];
        [self.view addSubview:self.spinnerView];
    } else {
        self.spinnerView.frame = frame;
    }
}


#pragma mark - assistant methods

- (void)configGridView {
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.scrollView.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    //[[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollView addSubview:gmGridView];
    _gridView = gmGridView;
    
    _gridView.style = GMGridViewStylePush;
    _gridView.itemSpacing = 10;
    _gridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    _gridView.centerGrid = YES;
    _gridView.dataSource = self;
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.mainSuperView = self.scrollView;
    
}

- (void)loadContentData:(NSString *)type {
    NSArray *array = [DataHelper loadContentData:self.deptID
                                      CategoryID:self.categoryDict[CONTENT_FIELD_ID]
                                            Type:type
                                             Key:CONTENT_FIELD_ID
                                           Order:YES];
    NSMutableArray *arrayOne = [array objectAtIndex:0];
    NSMutableArray *arrayTwo = [array objectAtIndex:1];
    
    self.dataListOne = [NSMutableArray arrayWithArray:arrayOne];
    self.dataListTwo = [NSMutableArray arrayWithArray:arrayTwo];
    
    array = [self.dataListOne arrayByAddingObjectsFromArray:self.dataListTwo];
    _dataList = [NSMutableArray arrayWithArray:array];
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    self.nothingLabel.hidden = (_dataList.count != 0);

    return [_dataList count];
}


- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(SIZE_GRID_VIEW_PAGE_WIDTH, SIZE_GRID_VIEW_PAGE_WIDTH);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    GMGridViewCell *cell = [gridView dequeueReusableCell];

    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
    }
    // 根据服务器返回的JSON数据显示文件夹或文档。
    NSMutableDictionary *currentDict = [_dataList objectAtIndex:index];
    NSString *contentType = [currentDict objectForKey:CONTENT_FIELD_TYPE];
    
    /**
     *  目录: 0; 文档: 1; 直文档: 2; 视频: 4
     *  category: name; slide: title;(name is origin upload filename)
     */
    if([contentType isEqualToString:CONTENT_CATEGORY]) {
        ViewCategory *viewCategory = [[[NSBundle mainBundle] loadNibNamed:@"ViewCategory" owner:self options:nil] lastObject];
        viewCategory.labelTitle.text =  currentDict[CONTENT_FIELD_NAME];
        
        [viewCategory setImageWith:CONTENT_CATEGORY CategoryID:currentDict[CONTENT_FIELD_ID]];
        viewCategory.btnImageCover.tag = [currentDict[CONTENT_FIELD_ID] intValue];
        [viewCategory.btnImageCover addTarget:self action:@selector(actionCategoryClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // NSLog(@"category - %@,%@", currentDict[CONTENT_FIELD_ID],currentDict[CONTENT_FIELD_NAME]);
        [cell setContentView: viewCategory];
    } else {
        ViewSlide *viewSlide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] objectAtIndex: 0];
        viewSlide.isFavorite = NO;
        viewSlide.dict = currentDict;
        viewSlide.masterViewController = [self masterViewController];
        
        //NSLog(@"slide - %@,%@", currentDict[CONTENT_FIELD_ID],currentDict[CONTENT_FIELD_TITLE]);
        [cell setContentView: viewSlide];
    }
    return cell;
}

#pragma mark - controls action
/**
 *  分类列表鼠标点击事件。
 *  进入目录界面;
 *  用户点击分类导航行为记录CONTENT_CONFIG_FILENAME[@CONTENT_KEY_NAVSTACK], 类型为NSMutableArray
 *  进入push, 返回是pop
 *
 *  @param sender UIButton
 */
- (IBAction)actionCategoryClick:(UIButton *)sender {
    self.navBtnBack.enabled = NO;
    NSString *categoryID = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    NSString *predicateStr = [NSString stringWithFormat:@"(%@ == \"%@\")", CONTENT_FIELD_ID, categoryID];
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateStr];
    self.categoryDict = [[self.dataListOne filteredArrayUsingPredicate:filter] lastObject];
    
    [self.navActionStack addObject:self.categoryDict];
    
    [self refreshContent];
}

/**
 *  导航栏[返回]响应处理；
 *  关键: CONTENT_CONFIG_FILENAME[CONTENT_KEY_NAVSTACK] - 栈 NSMutableArray
 *      1. 移除最后一个对象
 *      2. 判断栈中对象数据
 *      2.1 如果为空，判断HomePage
 *      2.2 不为空，刷新本界面
 *
 *  @param sender <#sender description#>
 */
- (IBAction)actionNavBack:(UIButton *)sender {
    sender.enabled = NO;
    if([self.navActionStack count] == 1) {
        HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:nil bundle:nil];
        MainViewController *mainViewController = (MainViewController *)[self masterViewController];
        [mainViewController setRightViewController:homeViewController withNav:YES];
    } else {
        [self.navActionStack removeLastObject];
        self.categoryDict = [self.navActionStack lastObject];
        [self refreshContent];
    }
}


#pragma mark - 导航栏按钮事件
- (IBAction)actionNavSortByDate:(UIButton *)sender {
    if([sender tag] == SortByAscending) {
        sender.tag = SortByDescending;
        self.dateSortImageView.image = [UIImage imageNamed:@"iconDescending"];
    } else {
        sender.tag = SortByAscending;
        self.dateSortImageView.image = [UIImage imageNamed:@"iconAscending"];
    }
    BOOL isAscending = ([sender tag] == SortByAscending);
    switch ([self.filterType intValue]) {
        case FilterAll:{
            self.dataListOne = [ContentUtils sortArray:self.dataListOne Key:CONTENT_FIELD_CREATEDATE Ascending:isAscending];
            self.dataListTwo = [ContentUtils sortArray:self.dataListTwo Key:CONTENT_FIELD_CREATEDATE Ascending:isAscending];
            NSArray *array = [self.dataListOne arrayByAddingObjectsFromArray:self.dataListTwo];
            _dataList = [NSMutableArray arrayWithArray:array];
        }
            break;
        case FilterCategory: {
            _dataList = [ContentUtils sortArray:self.dataListOne Key:CONTENT_FIELD_CREATEDATE Ascending:isAscending];
        }
            break;
        case FilterSlide: {
            _dataList = [ContentUtils sortArray:self.dataListTwo Key:CONTENT_FIELD_CREATEDATE Ascending:isAscending];
        }
            break;
        default:
            break;
    }
    
    [_gridView reloadData];
}

- (IBAction)actionNavSortByName:(UIButton *)sender {
    if([sender tag] == SortByAscending) {
        sender.tag = SortByDescending;
        self.nameSortImageView.image = [UIImage imageNamed:@"iconDescending"];
    } else {
        sender.tag = SortByAscending;
        self.nameSortImageView.image = [UIImage imageNamed:@"iconAscending"];
    }
    BOOL isAscending = ([sender tag] == SortByAscending);
    switch ([self.filterType intValue]) {
        case FilterAll:{
            self.dataListOne = [ContentUtils sortArray:self.dataListOne Key:CONTENT_FIELD_NAME Ascending:isAscending];
            self.dataListTwo = [ContentUtils sortArray:self.dataListTwo Key:CONTENT_FIELD_NAME Ascending:isAscending];
            NSArray *array = [self.dataListOne arrayByAddingObjectsFromArray:self.dataListTwo];
            _dataList = [NSMutableArray arrayWithArray:array];
        }
            break;
        case FilterCategory: {
            _dataList = [ContentUtils sortArray:self.dataListOne Key:CONTENT_FIELD_NAME Ascending:isAscending];
        }
            break;
        case FilterSlide: {
            _dataList = [ContentUtils sortArray:self.dataListTwo Key:CONTENT_FIELD_NAME Ascending:isAscending];
        }
            break;
        default:
            break;
    }
    [_gridView reloadData];
}

- (IBAction)actionNavFilterAll:(id)sender {
    self.filterType = [NSNumber numberWithInteger:FilterAll];
    [self navFilterFont];
    NSArray *array = [self.dataListOne arrayByAddingObjectsFromArray:self.dataListTwo];
    _dataList = [NSMutableArray arrayWithArray:array];
    [_gridView reloadData];
}

- (IBAction)actionNavFilterOne:(id)sender {
    self.filterType = [NSNumber numberWithInteger:FilterCategory];
    [self navFilterFont];
    _dataList = self.dataListOne;
    [_gridView reloadData];
}

- (IBAction)actionNavFilterTwo:(id)sender {
    self.filterType = [NSNumber numberWithInteger:FilterSlide];
    [self navFilterFont];
    _dataList = self.dataListTwo;
    [_gridView reloadData];
}

- (void)navFilterFont {
    self.navBtnFilterAll.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.navBtnFilterAll.titleLabel.textColor = [UIColor darkGrayColor];
    self.navBtnFilterOne.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.navBtnFilterOne.titleLabel.textColor = [UIColor darkGrayColor];
    self.navBtnFilterTwo.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.navBtnFilterTwo.titleLabel.textColor = [UIColor darkGrayColor];
    switch ([self.filterType intValue]) {
        case FilterAll:
            self.navBtnFilterAll.titleLabel.font = [UIFont systemFontOfSize:20.0];
            self.navBtnFilterAll.titleLabel.textColor = [UIColor blackColor];
            break;
        case FilterCategory:
            self.navBtnFilterOne.titleLabel.font = [UIFont systemFontOfSize:20.0];
            self.navBtnFilterOne.titleLabel.textColor = [UIColor blackColor];
            break;
        case FilterSlide:
            self.navBtnFilterTwo.titleLabel.font = [UIFont systemFontOfSize:20.0];
            self.navBtnFilterTwo.titleLabel.textColor = [UIColor blackColor];
            break;
        default:
            break;
    }
}
@end
