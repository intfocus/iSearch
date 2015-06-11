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


#import "ViewController.h"
#import "ViewSlide.h"
#import "ViewFolder.h"
#import "UIRequestButton.h"
#import "const.h"
#import "message.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "FileUtils.h"
#import "ShowViewController.h"


#define NUMBER_ITEMS_ON_LOAD 10
#define SIZE_GRID_VIEW_CELL_WIDTH 120//230
#define SIZE_GRID_VIEW_CELL_HEIGHT 80

//////////////////////////////////////////////////////////////
#pragma mark ViewController (privates methods)
//////////////////////////////////////////////////////////////

@interface ViewController ()   <GMGridViewDataSource,
                                GMGridViewSortingDelegate,
                                GMGridViewTransformationDelegate,
                                GMGridViewActionDelegate> {
__gm_weak GMGridView *_gmGridView;
UIImageView          *changeBigImageView;
NSMutableArray       *_data;
}
@property (weak, nonatomic) IBOutlet UIScrollView *structureView; // 目录结构图
@property (weak, nonatomic) IBOutlet UITextView *noticeView;      //
@property (weak, nonatomic) IBOutlet UIView *btnsView;
@property (nonatomic) NSMutableArray  *requestPath;
@property (nonatomic) NSInteger offsetX;


// http download variables begin
@property (strong, nonatomic) NSURLConnection *downloadConnection;
@property (strong, nonatomic) NSMutableData   *downloadConnectionData;
@property (strong, nonatomic) NSString        *downloadFileUrl;
@property (strong, nonatomic) NSString        *downloadFileId;
// http download variables end

@end

@implementation ViewController
@synthesize structureView;
@synthesize noticeView;
@synthesize btnsView;
@synthesize offsetX;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"structureView: %@",NSStringFromCGRect(self.structureView.bounds));

    
    //  1. 加载目录
    [self loadContent: @"0" Type: @"0"];
    
    // GMGridView Configuration
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.structureView.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.structureView addSubview:gmGridView];
    _gmGridView = gmGridView;
    
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.itemSpacing = 50;
    _gmGridView.itemHSpacing = 50;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(30, 10, -5, 10);
    _gmGridView.centerGrid = YES;
    _gmGridView.actionDelegate = self;
    _gmGridView.sortingDelegate = self;
    _gmGridView.transformDelegate = self;
    _gmGridView.dataSource = self;
    _gmGridView.backgroundColor = [UIColor clearColor];
    
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(self.structureView.bounds.size.width - 40,
                                  self.structureView.bounds.size.height - 40,
                                  40,
                                  40);
    infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [infoButton addTarget:self action:@selector(presentInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.structureView addSubview:infoButton];
    
    
    changeBigImageView = [[UIImageView alloc]init ];
    //[self.structureView addSubview:changeBigImageView];
    _gmGridView.mainSuperView = self.structureView; //[UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    self.view.backgroundColor = [UIColor purpleColor];
    
    
    //[self printDir];
}
//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _gmGridView = nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                        image:[UIImage imageNamed:@"cloud_normal"]
                                                selectedImage:[UIImage imageNamed:@"cloud_pressed"]];
        
    }
    return self;
}

- (void) printDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    //NSString *downloadPath = [documentsDirectory stringByAppendingPathComponent:@"/Download"];
    
    NSFileManager *fileManage = [NSFileManager defaultManager];
    
    NSArray *files = [fileManage subpathsAtPath: documentsDirectory];
    NSLog(@"%@",files);
}


//////////////////////////////////////////////////////////////
#pragma mark 文档结构 点击文件夹进入下一层
//////////////////////////////////////////////////////////////

- (void) btnTouchUpInside:(id)sender {
    UIRequestButton *btn = (UIRequestButton *)sender;
    NSLog(@"Click:%@", btn.path);

    [self loadContent:@"" Type:@"dir"];
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
- (void) loadContent: (NSString*) fid Type: (NSString*) type {
    // TODO Global shared value; Deal with in iLogin.
    NSString *uid = @"1";
    
    NSString *path = [NSString stringWithFormat:@"%@?user=%@&type=%@&id=%@&lang=%@", CONTENT_URL_PATH, uid, type, fid, APP_LANG];
    NSLog(@"%@", path);
    NSString *jsonStr = [HttpUtils httpGet: path];
    
    NSError *error;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    id objects = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:NSJSONReadingMutableContainers
                                                   error:&error];
    
    NSString *pathName = [FileUtils getPathName:CONTENT_DIRNAME FileName:[NSString stringWithFormat:@"%@.json",fid]];
    
    if(error == NULL) {
        // 1. 请求目录返回josn字符串写入CONTENT_DIRNAME/id.json
        [jsonStr writeToFile:pathName atomically:true encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"WriteToLocal: %@", error == NULL ? @"successfully." : [error localizedDescription]);
        
        for( NSDictionary *dict in objects) [mutableArray addObject:dict];
    } else {
        // 1.2 无网络环境(获取目录失败)，但CONTENT_DIRNAME/id.json存在，读取该缓存信息加载目录
        if([FileUtils checkFileExist:pathName isDir:false]) mutableArray = [self loadContentFromLocal: pathName];
    }
    
    // 目录数据有则加载，无则弹出框提示
    if([mutableArray count]) {
        _data = mutableArray;
        [_gmGridView reloadData];
    } else {
        [ViewUtils simpleAlertView:self Title:ALERT_TITLE_CONTENT_FAIL Message:ALERT_MSG_CONTENT_SERVER_ERROR ButtonTitle:BTN_CONFIRM];
    }
}

/**
 *  CONTENT_DIRNAME/id.json存在，读取该缓存信息加载目录
 *
 *  @param pathName 目录json缓存文件路径
 *
 *  @return 目录数据
 */
- (NSMutableArray *) loadContentFromLocal: (NSString*) pathName {
    NSLog(@"%@", pathName);
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *fileContent = [NSString stringWithContentsOfFile:pathName usedEncoding:NULL error:NULL];
    NSLog(@"loadContentFromLocal: %@", pathName);
    mutableArray = [NSJSONSerialization JSONObjectWithData:[fileContent dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingMutableContainers
                                                     error:NULL];
    
    return mutableArray;
}


//////////////////////////////////////////////////////////////
#pragma mark orientation management
//////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;//(interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
    // interfaceOrientation==UIInterfaceOrientationLandscapeRight);
    
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [_data count];
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView {
    return CGSizeMake(SIZE_GRID_VIEW_CELL_WIDTH, SIZE_GRID_VIEW_CELL_HEIGHT);
}

// GridViewCell界面 - 目录界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        // 根据服务器返回的JSON数据显示文件夹或文档。
        NSMutableDictionary *mutableDictionary = [_data objectAtIndex:index];
        NSString *name = [mutableDictionary objectForKey:@"name"];
        NSString *type = [mutableDictionary objectForKey:@"type"];
        
        // 目录: 0; 文档: 1; 直文档: 2; 视频: 4
        if([type isEqualToString:@"0"]) {
            ViewFolder *folder = [[[NSBundle mainBundle] loadNibNamed:@"ViewFolder" owner:self options:nil] lastObject];
            folder.folderTitle.text = name;
            
            [folder setFrame:CGRectMake(0, 0, 76,107)];
            [cell setContentView: folder];
        } else {
            ViewSlide *slide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] objectAtIndex: 0];
            slide.slideTitle.text = name;
            slide.dict = mutableDictionary;
            // 数据初始化操作，须在initWithFrame操作前，因为该操作会触发slide内部处理
            slide = [slide initWithFrame:CGRectMake(0, 0, 230, 150)];
            
            // 如果文件已经下载，文档原[下载]按钮显示为[演示]
            slide.slideDownload.tag = [slide.dict[@"id"] intValue];
            [slide.slideDownload addTarget:self action:@selector(showSlide:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell setContentView: slide];
        }
    }
    //[[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    return cell;
}

// 如果文件已经下载，文档原[下载]按钮显示为[演示]
- (IBAction) showSlide:(id)sender {
    NSString *fid = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    // 如果文档已经下载，即可执行演示效果，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:fid]) {
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        [config setObject:fid forKey:@"DisplayId"];
        [config writeToFile:pathName atomically:YES];
        
        ShowViewController *showVC = [[ShowViewController alloc] init];
        [self presentViewController:showVC animated:NO completion:nil];
    }
}



- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    [_data removeObjectAtIndex:index];
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

/**
 *  GridView中各cell点击响应处理，
 *  如果是目录，点击cell则加载该目录下的数据结构；
 *  如果是文件，则点击cell上的功能按钮
 *
 *  @param gridView GridView
 *  @param position 该cell在GridView中的序号
 */
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    // 根据服务器返回的JSON数据显示文件夹或文档。
    NSMutableDictionary *mutableDictionary = [_data objectAtIndex:position];
    NSLog(@"click data - name: %@, type: %@", [mutableDictionary objectForKey:@"name"],[mutableDictionary objectForKey:@"type"]);
    
    NSString *fid  = [mutableDictionary objectForKey:@"id"];
    NSString *type = [mutableDictionary objectForKey:@"type"];
    
    // 如果是目录，点击cell则加载该目录下的数据结构
    // 如果是文件，则点击cell上的功能按钮
    if([type isEqualToString:@"0"]) {
        [self loadContent:fid Type:type];
    }
}



//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor orangeColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSObject *object = [_data objectAtIndex:oldIndex];
    [_data removeObject:object];
    [_data insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [_data exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}


//////////////////////////////////////////////////////////////
#pragma mark DraggableGridViewTransformingDelegate
//////////////////////////////////////////////////////////////

- (CGSize)GMGridView:(GMGridView *)gridView sizeInFullSizeForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{   //310, 310
    return CGSizeMake(150, 100);
}

- (UIView *)GMGridView:(GMGridView *)gridView fullSizeViewForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index {
    UIView *fullView = [[UIView alloc] init];
    fullView.backgroundColor = [UIColor yellowColor];
    fullView.layer.masksToBounds = NO;
    fullView.layer.cornerRadius = 8;
    
    CGSize size = [self GMGridView:gridView sizeInFullSizeForCell:cell atIndex:index];
    fullView.bounds = CGRectMake(0, 0, size.width, size.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:fullView.bounds];
    label.text = [NSString stringWithFormat:@"Fullscreen View for cell at index %ld", (long)index];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.font = [UIFont boldSystemFontOfSize:15];
    
    [fullView addSubview:label];
    
    return fullView;
}

- (void)GMGridView:(GMGridView *)gridView didStartTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor yellowColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEndTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell
{
    
}


//////////////////////////////////////////////////////////////
#pragma mark private methods
//////////////////////////////////////////////////////////////

- (void)addMoreItem
{
    // Example: adding object at the last position
    NSString *newItem = [NSString stringWithFormat:@"%d", (int)(arc4random() % 1000)];
    
    [_data addObject:newItem];
    [_gmGridView insertObjectAtIndex:[_data count] - 1];
}

- (void)removeItem
{
    // Example: removing last item
    if ([_data count] > 0)
    {
        NSInteger index = [_data count] - 1;
        
        [_gmGridView removeObjectAtIndex:index];
        [_data removeObjectAtIndex:index];
    }
}

- (void)refreshItem
{
    // Example: reloading last item
    if ([_data count] > 0) {
        NSInteger index = [_data count] - 1;
        NSLog(@"iam infoBtn");
        NSString *newMessage = [NSString stringWithFormat:@"%d", (arc4random() % 1000)];
        
        [_data replaceObjectAtIndex:index withObject:newMessage];
        [_gmGridView reloadObjectAtIndex:index];
    }
}

- (void)presentInfo
{
    NSString *info = @"长按一个项目，可以移动它。 \n\n 使用两个手指捏/拖/旋转一个项目;变焦足够，进入全尺寸模式 \n\n";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:info
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)presentOptions:(UIBarButtonItem *)barButton
{
    if (_gmGridView.editing) {
        _gmGridView.editing = NO;
    }else {
        _gmGridView.editing = YES;
    }
}



@end
