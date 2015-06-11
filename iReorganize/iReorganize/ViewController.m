//
//  ViewController.m
//  iReorganize
//
//  Created by lijunjie on 15/5/15.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  文件列表GridView样式展示
//
//  A 本地文件展示界面
//      A1 扫描<已下载或内容重组>文件列表
//         存在fileId/desc.json则读取，并转换格式为NSMutableDirecotry，添加至全局变量_data
//         不存在则忽略
//      A2 GridView样式展示，并读取_data，显示<文件缩略图/文件名称>
//      A3 GridView Cell - 目录/文件
//          A3.1 目录，点击则加载该目录下的文件列表
//          A3.2 文件顺序[编辑] - TODO
//          A3.3 文件移除 - TODO
//          A3.4 文件收藏 - TODO
//
//
#import "ViewController.h"
#import "ViewSlide.h"
#import "const.h"
#import "message.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "FileUtils.h"
#import "ReViewController.h"


@interface ViewController ()   <GMGridViewDataSource,
                                GMGridViewSortingDelegate,
                                GMGridViewTransformationDelegate,
                                GMGridViewActionDelegate> {
    __gm_weak GMGridView *_gmGridView;
    UIImageView          *changeBigImageView;
    NSMutableArray       *_data;
}
@property (weak, nonatomic) IBOutlet UIScrollView *structureView;

@end
@implementation ViewController

/**
 *  界面加载完成前的初始化操作
 */
- (void)viewDidLoad {
    [super viewDidLoad];

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
    _gmGridView.backgroundColor = [UIColor yellowColor];
    
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(self.structureView.bounds.size.width - 40,
                                  self.structureView.bounds.size.height - 40,
                                  40,
                                  40);
    infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [infoButton addTarget:self action:@selector(presentInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.structureView addSubview:infoButton];
    
    
    changeBigImageView = [[UIImageView alloc]init ];
    _gmGridView.mainSuperView = self.structureView;
    
    self.view.backgroundColor = [UIColor purpleColor];
    
//    UILongPressGestureRecognizer *tapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
//                                                                                             action:@selector(refreshGridView)];
//    [self.view addGestureRecognizer:tapGesture];
    
}

/**
 *  界面出现时都会被触发，动态加载动作放在这里
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // A1 扫描<已下载或内容重组>文件列表
    [self refreshGridView];
}

/**
 *  扫描<已下载或内容重组>文件列表,
 *  - 存在fileId/desc.json则读取，并转换格式为NSMutableDirecotry
 *  - 不存在则忽略
 *
 *  @return 各文件的配置信息
 */
- (NSMutableArray *) scanDownloadFiles {
    NSError *error;
    NSString *filesPath = [FileUtils getPathName:FILE_DIRNAME];
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filesPath error:&error];
    
    if(error) {
        NSLog(@"list FILE_DIRNAME/files failed: %@", [error localizedDescription]);
        files = @[];
    }
    // 扫描FILE_DIRNAME/ 下已经下载文件(其中是文件夹)
    NSString *fileId;
    for(fileId in files) {
        NSString *filePath = [filesPath stringByAppendingPathComponent:fileId];
        NSString *descPath = [filePath stringByAppendingPathComponent:FILE_CONFIG_FILENAME];

        // 描述文件不存在则忽略
        if(![FileUtils checkFileExist:descPath isDir:false])
            continue;
        
        NSString *descContent = [NSString stringWithContentsOfFile:descPath usedEncoding:NULL error:NULL];
        id json = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:NSJSONReadingMutableContainers
                                                    error:&error];
        /**
         *  desc.json结构
         *  { 
         *      id: fileId,
         *      name: fileName,
         *      desc: fileDesc,
         *      order: [fileId_pageId]
         *  }
         */
        if(!error) {
            // 如果@"id"未赋值则补上，此情况不应该出现
            if(![json objectForKey:@"id"])
                [json setObject:fileId forKey:@"id"];
            
            [mutableArray addObject: json];
        } else
            NSLog(@"parse json failed: %@", [error localizedDescription]);
    }
    return mutableArray;
}

/**
 *  重新刷新GridView, 在页面内容重组后，反回该界面时，新建文件并未显示，so...
 */
- (void) refreshGridView {
    _data = [self scanDownloadFiles];
    // 初次加载时，需要下载文件， 测试时使用
    if(![_data count])
        [self loadContent:@"@" Type:@"@"];
    
    [_gmGridView reloadData];
}

//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _gmGridView = nil;
}


//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////

/**
 *  下载文件，测试时使用
 *
 *  @param fid  @"0"
 *  @param type @"0"
 */
- (void) loadContent: (NSString*) fid Type: (NSString*) type {
    // TODO Global shared value; Deal with in iLogin.
    
    NSString *pathName = [FileUtils getPathName:CONTENT_DIRNAME FileName:[NSString stringWithFormat:@"local.json"]];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    if([FileUtils checkFileExist:pathName isDir:false]) {
        mutableArray = [self scanDownloadFiles];
        
        if(![mutableArray count])
            mutableArray = [self loadContentFromLocal: pathName];
    } else {
        NSString *jsonStr = [HttpUtils httpGet: @"/demo/isearch/reorganize"];
        NSLog(@"JSON: %@", jsonStr);
        NSError *error;
        id objects = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
        
        if(!error) {
            // 1. 请求目录返回josn字符串写入CONTENT_DIRNAME/id.json
            [jsonStr writeToFile:pathName atomically:true encoding:NSUTF8StringEncoding error:&error];
            NSLog(@"WriteToLocal: %@", error == NULL ? @"successfully." : [error localizedDescription]);
            
            for( NSDictionary *dict in objects)
                [mutableArray addObject:dict];
        } else {
            NSLog(@"loadContent: %@", [error localizedDescription]);
        }
    }
    // 目录数据有则加载，无则弹出框提示
    if([mutableArray count]) {
        _data = mutableArray;
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
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSString *fileContent = [NSString stringWithContentsOfFile:pathName usedEncoding:NULL error:NULL];
    NSLog(@"loadContentFromLocal: %@", pathName);
    mutableArray = [NSJSONSerialization JSONObjectWithData:[fileContent dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingMutableContainers
                                                     error:NULL];
    
    return mutableArray;
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [_data count];
}
// GridView Cell的长宽
- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView {
    return CGSizeMake(SIZE_GRID_VIEW_CELL_WIDTH, SIZE_GRID_VIEW_CELL_HEIGHT);
}

// A2 GridView样式展示，并读取_data，显示<文件缩略图/文件名称>
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:GRID_VIEW_DELETE_BTN_IMAGE];
        cell.deleteButtonOffset = CGPointMake(GRID_VIEW_DELETE_BTN_OFFSET_X, GRID_VIEW_DELETE_BTN_OFFSET_Y);
        
        /**
         *  GridView Cell的index与_data一一对应
         *
         *  _data存放的NSDirecotry为desc.json内容，其结构
         *  {
         *      id: fileId,
         *      name: fileName,
         *      desc: fileDesc,
         *      order: [fileId_pageId]
         *  }
         */
        NSMutableDictionary *dict = [_data objectAtIndex:index];
        NSString *name = [dict objectForKey:@"name"];
        

        ViewSlide *slide = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlide" owner:self options:nil] objectAtIndex: 0];
        slide.slideTitle.text = name;
        /**
         *  重点: [下载]功能实现的代码在ViewSlide.m中，各Cell负责各自己的， 
         *  所以文件下载可以并行异步。
         *
         *  解释: SLIDE_DOWNLOAD_BTN可时为[下载]、[详细]?
         *  通过判断FILE_DIRNAME/fileId是否存在，不存在显示[下载]，否则显示[详细]
         *  点击文件[详细]进入，文件页面界面功能实现的代码，是通过赋予[SLIDE_DOWNLOAD_BTN]点击时触发enterFilePagesView函数
         *
         */
        // ViewSlide内部下载时，也需要知道文件的fileId所以传递配置信息
        slide.dict = dict;
        
        // 数据初始化操作，须在initWithFrame操作前，因为该操作会触发slide内部处理
        slide = [slide initWithFrame:CGRectMake(0, 0, 230, 150)];
        
        // 按钮附带信息，否则被触发时，找不到目标
        slide.slideDownload.tag = index;
        [slide.slideDownload addTarget:self action:@selector(enterFilePagesView:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell setContentView: slide];
    }
    
    return cell;
}

/**
 *  ViewSlide的SLIDE_DOWNLOAD_BTN被下载时，会触发该函数。
 *  只有文件已经下载时，才会真正有动作。
 *
 *  @param sender 无返回
 */
- (void)enterFilePagesView:(id)sender {
    NSMutableDictionary *dict = [_data objectAtIndex:[sender tag]];
    NSString *detailId = dict[@"id"];
    // 如果文档已经下载，可以查看文档内部详细信息，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:detailId]) {
        // 界面跳转需要传递fileId，通过写入配置文件来实现交互
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:REORGANIZE_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        [config setObject:detailId forKey:@"DetailId"];
        [config writeToFile:pathName atomically:YES];
        
        config = [FileUtils readConfigFile:pathName];
        
        // 界面跳转
        // TODO 跳转实现方式不太合适
        ReViewController *showVC = [[ReViewController alloc] init];
        [self presentViewController:showVC animated:NO completion:nil];
        NSLog(@"Come back from pages.");
    }
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////
//          A3.3 文件移除
// GridView移除操作
- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [_data removeObjectAtIndex:index];
}


/**
 *  A3.1 目录，点击则加载该目录下的文件列表
 *
 *  GridView中各cell点击响应处理，
 *  如果是目录，点击cell则加载该目录下的文件列表，相当于递归自己；
 *  如果是文件，则点击cell上的[功能按钮]
 *
 *  @param gridView GridView
 *  @param position 该cell在GridView中的序号, 与_data的序号对应
 */
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    // 根据服务器返回的JSON数据显示文件夹或文档。
    NSMutableDictionary *mutableDictionary = [_data objectAtIndex:position];
    
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

//          A3.2 文件顺序[编辑] - TODO
- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2 {
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
#pragma mark GridView private methods
//////////////////////////////////////////////////////////////

- (void)addMoreItem{}
- (void)removeItem{}
- (void)refreshItem{}

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
- (void)presentOptions:(UIBarButtonItem *)barButton {}



@end

