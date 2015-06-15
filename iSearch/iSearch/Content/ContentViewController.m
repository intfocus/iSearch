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


#import "ContentViewController.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMGridView.h"
#import "common.h"
#import "ViewSlide.h"
#import "ViewFolder.h"
#import "DisplayViewController.h"
#import "ContentUtils.h"

#define NUMBER_ITEMS_ON_LOAD 10
#define SIZE_GRID_VIEW_CELL_WIDTH 120//230
#define SIZE_GRID_VIEW_CELL_HEIGHT 80

//////////////////////////////////////////////////////////////
#pragma mark ViewController (privates methods)
//////////////////////////////////////////////////////////////

@interface ContentViewController () <GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate> {
__gm_weak GMGridView *_gmGridView;
UIImageView          *changeBigImageView;
NSMutableArray       *_data;
}
@property (weak, nonatomic) IBOutlet UIScrollView *structureView; // 目录结构图
@property (weak, nonatomic) IBOutlet UITextView *noticeView;      //
@property (weak, nonatomic) IBOutlet UIView *btnsView;
@property (strong, nonatomic) NSString  *deptID;
@property (nonatomic) NSInteger offsetX;


// http download variables begin
@property (strong, nonatomic) NSURLConnection *downloadConnection;
@property (strong, nonatomic) NSMutableData   *downloadConnectionData;
@property (strong, nonatomic) NSString        *downloadFileUrl;
@property (strong, nonatomic) NSString        *downloadFileId;
// http download variables end

@end

@implementation ContentViewController
@synthesize structureView;
@synthesize noticeView;
@synthesize btnsView;
@synthesize offsetX;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"structureView: %@",NSStringFromCGRect(self.structureView.bounds));

    self.deptID = @"10";
    //  1. 读取本地缓存，优先加载界面
    _data = [[NSMutableArray alloc] init];
    _data = [ContentUtils loadContentData:self.deptID CategoryID:@"1" Type:LOCAL_OR_SERVER_LOCAL];
    
    // GMGridView Configuration
    [self configGridView];
    
    // 耗时间的操作放在些block中
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *tmpArray = [ContentUtils loadContentData:self.deptID CategoryID:@"1" Type:LOCAL_OR_SERVER_SREVER];
        if([tmpArray count]) {
            _data = tmpArray;
            [_gmGridView reloadData];
        }
    });
}

- (void) configGridView {
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
    _gmGridView.mainSuperView = self.structureView; //[UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    self.view.backgroundColor = [UIColor purpleColor];
}
//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _gmGridView = nil;
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
    return CGSizeMake(SIZE_GRID_VIEW_PAGE_WIDTH, SIZE_GRID_VIEW_PAGE_WIDTH);
}

// GridViewCell界面 - 目录界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        
        // 根据服务器返回的JSON数据显示文件夹或文档。
        NSMutableDictionary *dict = [_data objectAtIndex:index];
        NSString *name = dict[CONTENT_FIELD_NAME];
        if(![[dict allKeys] containsObject:CONTENT_FIELD_TYPE]) {
            dict[CONTENT_FIELD_TYPE] = @"0";
            [_data objectAtIndex:index][CONTENT_FIELD_TYPE] = @"0";
        }
        NSString *type = [dict objectForKey:CONTENT_FIELD_TYPE];
        NSLog(@"%@", dict);
        
        // 目录: 0; 文档: 1; 直文档: 2; 视频: 4
        if([type isEqualToString:@"0"]) {
            ViewFolder *folder = [[[NSBundle mainBundle] loadNibNamed:@"ViewFolder" owner:self options:nil] lastObject];
            folder.folderTitle.text = name;
            
            [folder setFrame:CGRectMake(0, 0, 76,107)];
            [cell setContentView: folder];
            NSLog(@"%@ - %@", name, type);
        } else {
            ViewSlide *slide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] objectAtIndex: 0];
            slide.slideTitle.text = name;
            NSString *downloadUrl = [NSString stringWithFormat:@"%@%@?%@=%@",
                                     BASE_URL, CONTENT_DOWNLOAD_URL_PATH, CONTENT_PARAM_FILE_DWONLOADID, dict[CONTENT_FIELD_ID]];
            dict[CONTENT_FIELD_URL] = downloadUrl;
            slide.dict = dict;
            // 数据初始化操作，须在initWithFrame操作前，因为该操作会触发slide内部处理
            slide = [slide initWithFrame:CGRectMake(0, 0, 230, 150)];
            
            // 如果文件已经下载，文档原[下载]按钮显示为[演示]
            slide.slideDownload.tag = [dict[CONTENT_FIELD_ID] intValue];
            [slide.slideDownload addTarget:self action:@selector(actionDisplaySlide:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell setContentView: slide];
        }
    }
    //[[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    return cell;
}

// 如果文件已经下载，文档原[下载]按钮显示为[演示]
- (IBAction) actionDisplaySlide:(id)sender {
    NSString *fileID = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    // 如果文档已经下载，即可执行演示效果，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:fileID Force:YES]) {
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:FILE_DISPLAY_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        [config setObject:fileID forKey:@"FileID"];
        [config writeToFile:pathName atomically:YES];
        
        DisplayViewController *showVC = [[DisplayViewController alloc] init];
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
    NSMutableDictionary *dict = [_data objectAtIndex:position];
    NSLog(@"click data - name: %@, type: %@", dict[CONTENT_FIELD_NAME],dict[CONTENT_FIELD_TYPE]);
    
    NSString *categoryID  = dict[CONTENT_FIELD_ID];
    NSString *type = dict[CONTENT_FIELD_TYPE];
    
    // 如果是目录，点击cell则加载该目录下的数据结构
    // 如果是文件，则点击cell上的功能按钮
    if([type isEqualToString:@"0"]) {
        NSString *localOrServer = [HttpUtils isNetworkAvailable] ? LOCAL_OR_SERVER_SREVER : LOCAL_OR_SERVER_LOCAL;
        _data = [ContentUtils loadContentData:self.deptID CategoryID:categoryID Type:localOrServer];
    
        [_gmGridView reloadData];
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

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell {}

- (void)calledByPresentedViewController {
    NSLog(@"called by Display view.");
}
@end
