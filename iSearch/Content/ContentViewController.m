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

#import "ContentUtils.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "ExtendNSLogFunctionality.h"

#define NUMBER_ITEMS_ON_LOAD 10
#define SIZE_GRID_VIEW_CELL_WIDTH 120//230
#define SIZE_GRID_VIEW_CELL_HEIGHT 80

//////////////////////////////////////////////////////////////
#pragma mark ViewController (privates methods)
//////////////////////////////////////////////////////////////

@interface ContentViewController () <GMGridViewDataSource> {
__gm_weak GMGridView *_gridView;
NSMutableArray       *_dataList;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // 目录结构图
@property (strong, nonatomic) NSString  *deptID;
@property (strong, nonatomic) NSString  *categoryID; // 与categoryDict并不冲突，以此值来取它对应的信息
@property (strong, nonatomic) NSMutableDictionary *categoryDict; // 依赖于categoryID

// 顶部控件
@property (weak, nonatomic) IBOutlet UIButton *navBtnBack; // 返回
@property (weak, nonatomic) IBOutlet UILabel  *navLabel;   // 当前分类名称
@property (weak, nonatomic) IBOutlet UIButton *navBtnFilterAll;   // 全部
@property (weak, nonatomic) IBOutlet UIButton *navBtnFilterOne;   // 分类
@property (weak, nonatomic) IBOutlet UIButton *navBtnFilterTwo;   // 幻灯片
@property (weak, nonatomic) IBOutlet UIButton *navBtnFilterThree; // 文献
@property (weak, nonatomic) IBOutlet UIButton *navBtnSortOne; // 按时间排序
@property (weak, nonatomic) IBOutlet UIButton *navBtnSortTwo; // 按名称排序

// http download variables begin
@property (strong, nonatomic) NSURLConnection *downloadConnection;
@property (strong, nonatomic) NSMutableData   *downloadConnectionData;
@property (strong, nonatomic) NSString        *downloadSlideUrl;
@property (strong, nonatomic) NSString        *downloadSlideID;
// http download variables end

@end

@implementation ContentViewController
@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /**
     *任何实例都需要初始化
     */
    _dataList = [[NSMutableArray alloc] init];
    self.categoryDict = [[NSMutableDictionary alloc] init];

    // deptID
    [self assignUserInfo];
    // nav behaviour stack
    [self assignCategoryInfo:self.deptID];
    
    /**
     *  导航栏控件
     */
    [self.navBtnBack setTitle:@"\U000025C0\U0000FE0E返回" forState:UIControlStateNormal];
    [self.navBtnBack addTarget:self action:@selector(actionNavBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navLabel.text = self.categoryDict[CONTENT_FIELD_NAME];

    [self configGridView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //  1. 读取本地缓存，优先加载界面
    _dataList = [ContentUtils loadContentData:self.deptID CategoryID:self.categoryID Type:LOCAL_OR_SERVER_LOCAL];
    [self configGridView];
    self.view.backgroundColor=[UIColor blackColor];
    
    // 耗时间的操作放在些block中
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *tmpArray = [ContentUtils loadContentData:self.deptID CategoryID:self.categoryID Type:LOCAL_OR_SERVER_SREVER];
        if([tmpArray count]) {
            _dataList = tmpArray;
            [self configGridView];
        }
    });
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
- (IBAction)actionNavBack:(id)sender {
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    NSMutableArray *mutableArray = [configDict objectForKey:CONTENT_KEY_NAVSTACK];

    [mutableArray removeLastObject];
    [configDict setObject:mutableArray forKey:CONTENT_KEY_NAVSTACK];
    [configDict writeToFile:configPath atomically:true];
    
    MainViewController *mainViewController = (MainViewController *)[self masterViewController];
    if([mutableArray count] == 0) {
        // 返回HomePage
        HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:nil bundle:nil];
        [mainViewController setRightViewController:homeViewController withNav: NO];
    } else {
        // 刷新本视图
        ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
        [mainViewController setRightViewController:contentViewController withNav: NO];
    }
}
/**
 *  配置GridView
 */
- (void) configGridView {
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.scrollView.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollView addSubview:gmGridView];
    _gridView = gmGridView;
    
    _gridView.style = GMGridViewStyleSwap;
    _gridView.itemSpacing = 50;
    _gridView.minEdgeInsets = UIEdgeInsetsMake(30, 10, -5, 10);
    _gridView.centerGrid = YES;
    _gridView.dataSource = self;
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.mainSuperView = self.scrollView; //[UIApplication sharedApplication].keyWindow.rootViewController.view;
    
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
 *      1.1 网络环境良好，HttpPost 服务器获取网站目录（json数组格式）
 *          Post /CONENT_URL_PATH {
 *              user: user-name or user-email,
 *              type: 0 , -- 目录: 0; 文档: 1; 直文档: 2; 视频: 4
 *                id: 0 ,
 *              lang: zh-CN -- app language
 *          }
 *          Response [{
 *              type: 0,  -- 目录: 0; 文档: 1; 直文档: 2; 视频: 4
 *              name: dir-name or file-name,
 *              desc: desc,
 *               tag:  tags,
 *                id: 1,    -- 下次请求使用
 *               url: zip download url when type is file
 *          }]
 *
 *
 *          说明:
 *            1. 请求目录返回josn字符串写入CONTENT_DIRNAME/id.json
 *            2. 请求下载文档，压缩包放至DOWNLOAD_DIRNAME/id.zip， 解压至FILE_DIRNAME/id
 *            3. 压缩包文件名称不作要求，其压缩文件格式应为: id/{index.html, images/}
 *
 *  @param fid  文件在服务器上的id
 *  @param type 文件类型
 */
 // 代码抽取放在ContentUtils.h文件中

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
        
        // 根据服务器返回的JSON数据显示文件夹或文档。
        NSMutableDictionary *currentDict = [_dataList objectAtIndex:index];
        NSString *name = currentDict[CONTENT_FIELD_NAME];
        
        // 服务器端Category没有ID值
        if(![currentDict objectForKey:CONTENT_FIELD_TYPE]) {
            currentDict[CONTENT_FIELD_TYPE] = CONTENT_CATEGORY;
            [_dataList objectAtIndex:index][CONTENT_FIELD_TYPE] = CONTENT_CATEGORY;
        }
        NSString *categoryType = [currentDict objectForKey:CONTENT_FIELD_TYPE];
        
        // 目录: 0; 文档: 1; 直文档: 2; 视频: 4
        if([categoryType isEqualToString:CONTENT_CATEGORY]) {
            ViewCategory *viewCategory = [[[NSBundle mainBundle] loadNibNamed:@"ViewCategory" owner:self options:nil] lastObject];
            viewCategory.labelTitle.text = name;
            
            [viewCategory setImageWith:categoryType CategoryID:currentDict[CONTENT_FIELD_ID]];
            viewCategory.btnImageCover.tag = [currentDict[CONTENT_FIELD_ID] intValue];
            [viewCategory.btnImageCover addTarget:self action:@selector(actionCategoryClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell setContentView: viewCategory];
        } else {
            ViewSlide *slide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] objectAtIndex: 0];
            slide.labelTitle.text = name;
            NSString *downloadUrl = [NSString stringWithFormat:@"%@%@?%@=%@",
                                     BASE_URL, CONTENT_DOWNLOAD_URL_PATH, CONTENT_PARAM_FILE_DWONLOADID, currentDict[CONTENT_FIELD_ID]];
            currentDict[CONTENT_FIELD_URL] = downloadUrl;
            slide.dict = currentDict;
            // 数据初始化操作，须在initWithFrame操作前，因为该操作会触发slide内部处理
            slide = [slide initWithFrame:CGRectMake(0, 0, 230, 150)];
            
            slide.btnSlideInfo.tag = index;
            [slide.btnSlideInfo addTarget:self action:@selector(actionPopupSlideInfo:) forControlEvents:UIControlEventTouchUpInside];
            // 如果文件已经下载，文档原[下载]按钮显示为[演示]
            slide.btnDownloadOrDisplay.tag = [currentDict[CONTENT_FIELD_ID] intValue];
            [slide.btnDownloadOrDisplay addTarget:self action:@selector(actionDisplaySlide:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell setContentView: slide];
        }
    }
    //[[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
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
    NSString *categoryID = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    // 点击分类导航行为记录
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    // init as NSMutableArray when key@CONTENT_KEY_NAVSTACK not exist
    NSMutableArray *navStack = [configDict objectForKey:CONTENT_KEY_NAVSTACK];
    // push current categoryID
    [navStack addObject:categoryID];
    [configDict setObject:navStack forKey:CONTENT_KEY_NAVSTACK];
    [configDict writeToFile:configPath atomically:true];
    
    // enter ContentViewController
    MainViewController *mainViewController = [self masterViewController];
    ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
    contentViewController.masterViewController = mainViewController;
    [mainViewController setRightViewController:contentViewController withNav:NO];
}

- (IBAction)actionPopupSlideInfo:(UIButton *)sender {
    NSInteger index = [sender tag];
    NSMutableDictionary *dict = _dataList[index];
    MainViewController *mainViewController = [self masterViewController];
    [mainViewController poupSlideInfo:dict[CONTENT_FIELD_ID] Dir:CONTENT_DIRNAME];
}

/**
 *  如果文件已经下载，文档原[下载]按钮显示为[演示]
 *
 *  @param IBAction <#IBAction description#>
 *
 *  @return <#return value description#>
 */
- (IBAction) actionDisplaySlide:(id)sender {
    NSString *fileID = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    // 如果文档已经下载，即可执行演示效果，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:fileID Dir:FAVORITE_DIRNAME Force:YES]) {
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        [config setObject:fileID forKey:CONTENT_KEY_DISPLAYID];
        [config writeToFile:pathName atomically:YES];
        
        DisplayViewController *showVC = [[DisplayViewController alloc] init];
        [self presentViewController:showVC animated:NO completion:nil];
    }
}

#pragma mark - private methods
/**
 *  读取配置档，获取用户信息
 */
- (void)assignUserInfo {
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:LOGIN_CONFIG_FILENAME];
    NSMutableDictionary *userDict =[FileUtils readConfigFile:configPath];
    self.deptID = userDict[USER_DEPTID];
    
    if(self.deptID == nil || [self.deptID length] == 0) {
        NSLog(@"Fail read DeptID!");
        abort();
    }
}
/**
 *  取得当前目录视图下的分类ID
 *  关键: CONTENT_CONFIG_FILENAME[CONTENT_KEY_NAVSTACK] - 栈 NSMutableArray
 *  栈中最后一个对象即当前目录的分类ID
 *
 *  强制使用deptID作为参数，以避免先使用后赋值。
 *
 */
- (void)assignCategoryInfo:(NSString *)deptID {
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    NSMutableArray *mutableArray = [configDict objectForKey:CONTENT_KEY_NAVSTACK];
    NSString *categoryID = [mutableArray lastObject];
    if([categoryID length] == 0) {
        NSLog(@"BUG - 此目录下未取得CategoryID: %@", mutableArray);
        categoryID = CONTENT_ROOT_ID;
    }
    
    NSString *parentID = CONTENT_ROOT_ID;
    if([mutableArray count] >= 2) {
        // 倒数第二个为父ID
        NSInteger index = [mutableArray count] - 2;
        parentID = [mutableArray objectAtIndex:index];
    }
    
    self.categoryID = categoryID;
    self.categoryDict = [ContentUtils readCategoryInfo:categoryID ParentID:parentID DepthID:deptID];
}

@end
