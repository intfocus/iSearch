//
//  ViewController.m
//  iReorganize
//
//  Created by lijunjie on 15/5/15.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  显示文件的各个页面
//
//  功能：
//      1. 排序
//      2. 删除
//      3. 重组 -> 另存为
//
//  已下载文件的目录结构:
//      FILE_DIRNAME/fileId/{fileId_pageId.html, fileId_pageId.gif, desc.json}
//
//  界面初始化:
//      扫描FILE_DIRNAME，如果存在配置档fileId/desc.json，则显示该文件信息
//      点击文件[详情]进入文件页面界面
//
//  文件页面详情:
//      从文件界面跳转至页面界面时，文件id写入CONFIG_DIRNAME/REORGANIZE_CONFIG_DIRNAME
//      读取配置档desc.json[@"order"] 并按该顺序加载界面
//
//  文件页面功能:
//      交换顺序: 长按拖拉
//      移除页面: 移除状态，点击页面移除按钮
//      选择页面另存在: 选择状态，选择页面，[保存]为新文件或合并至已存在文件（已存在的页面不会复制）
//
//  ===============================
//  B 文件页面 - 内容重组
//      B1 点击文件[详细]时，该文件ID写入CONFIG_DIRNAME/REORGANIZE_CONFIG_DIRNAME[@"DetailID"]
//      B2 读取DetailId/desc.json[@"order"]并按该顺序写入_data
//      B3 GridView样式展示，并读取_data，显示<fileId_pageId.gif>
//      B4 页面顺序 - 长按[页面]至颤动，搬动至指定位置，重置fileId/desc[@"order"]
//      B5 页面移除 - 点击导航栏中的[移除], 各页面左上角出现[x]按钮，点击[x]则会移除fileId_pageId.{html,gif}，并修改desc.json[@"order"]
//      B6 内容重组 - 点击导航栏中的[选择], 点击指定页面，页面会出现[V]表示选中，选择想要的页面后，再点击导航栏中的[保存] ->
//          弹出选择框有已经重组文件名称，选择指定文件名称，则会把页面拷贝至选择的fileId/下并修改desc.json[@"order"]
//          如果新建内容重组文件，则输入文件名称、文件描述，然后生成新的fileId(ryyMMddHHmmSS), 把页面拷贝至新的fileId/下，并创建desc.json
//
#import "ReViewController.h"
#import "ViewSlide.h"
#import "const.h"
#import "message.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "FileUtils.h"

@interface ReViewController ()   <GMGridViewDataSource,
                                GMGridViewSortingDelegate,
                                GMGridViewTransformationDelegate,
                                GMGridViewActionDelegate> {
    __gm_weak GMGridView *_gmGridView;
    UIImageView          *changeBigImageView;
    NSMutableArray       *_data; // 文件的页面信息
    NSMutableArray       *_select; // 内容重组选择的页面序号
}
@property (weak, nonatomic) IBOutlet UIScrollView *structureView; // GridView Container
@property (weak, nonatomic) IBOutlet UINavigationItem *navigation;
@property (nonatomic, assign) BOOL editabled; // 移除页面
@property (nonatomic, assign) BOOL selectable; // 内容重组
@property (nonatomic, strong) NSString  *detailId; // 本界面展示该fileId的页面
@property (nonatomic, strong) UIBarButtonItem *editItem;
@property (nonatomic, strong) UIBarButtonItem *selectItem;


@end


@implementation ReViewController
@synthesize detailId;
@synthesize editItem;
@synthesize selectItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.editabled = false;
    self.selectable = false;
    NSLog(@"structureView: %@",NSStringFromCGRect(self.structureView.bounds));
    
    // 顶部导航 按钮控件
    self.navigation.rightBarButtonItem = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                          target:self
                                          action:@selector(viewTapped:)];
    // 导航左侧按钮区
    NSMutableArray* array = [NSMutableArray array];
    UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"< 返回"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:@selector(viewTapped:)];
    [array addObject:item];
    self.navigation.leftBarButtonItems = array;
    
    // 导航右侧按钮区
    [array removeAllObjects];
    self.editItem = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"移除"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:@selector(switchEditable)];
    [array addObject:self.editItem];
    self.selectItem = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"选择"]
                                           style:UIBarButtonItemStylePlain
                                          target:nil
                                          action:@selector(switchSelectable)];
    [array addObject:self.selectItem];
    self.navigation.rightBarButtonItems = array;
    
    // 配置创建 GMGridView
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
    _gmGridView.mainSuperView = self.structureView;
    
    self.view.backgroundColor = [UIColor purpleColor];
    _select = [[NSMutableArray alloc] init];
    
    // 由文件界面点击[详细]进入该界面
    // 通过REORGANIZE_CONFIG_FILENAME配置档传递文件ID
    self.detailId = [self currentFileId];
    
    // 加载文件各页面
    _data = [self loadFilePages];;
    [_gmGridView reloadData];
}

/**
 *  B1 点击文件[详细]时，该文件ID写入CONFIG_DIRNAME/REORGANIZE_CONFIG_DIRNAME[@"DetailID"]
 *
 *  @return fileId
 */
- (NSString *) currentFileId {
    NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:REORGANIZE_CONFIG_FILENAME];
    NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
    return config[@"DetailId"];

}

//////////////////////////////////////////////////////////////
#pragma mark 加载文件各页面
//////////////////////////////////////////////////////////////

// B2 读取DetailId/desc.json[@"order"]并按该顺序写入_data
- (NSMutableArray*) loadFilePages {
    NSString *fileName = [FileUtils getPathName:FILE_DIRNAME FileName:self.detailId];
    NSString *descPath = [fileName stringByAppendingPathComponent:@"desc.json"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if([FileUtils checkFileExist:descPath isDir:false]) {
        NSMutableDictionary *descJSON = [[NSMutableDictionary alloc]init];
        
        NSString *descContent = [NSString stringWithContentsOfFile:descPath usedEncoding:NULL error:NULL];
        descJSON = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingMutableContainers
                                                     error:NULL];
        NSMutableArray *pagesOrder = descJSON[@"order"];

        NSString *pageName;
        for(pageName in pagesOrder) {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
            [tmpDict setObject:[NSString stringWithFormat:@"%@", pageName] forKey:@"pageName"];
            [array addObject:tmpDict];
        }
    } else {
        NSLog(@"%s#%d <#fileNotFound: %@>", __FILE__, __LINE__, descPath);
    }
    
    return array;
}

- (void)viewTapped:(UIGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void) switchSelectable {
    self.selectable = !self.selectable;
    if(self.selectable) {
        NSLog(@"TODO#switchSelect DealWith %@", _select);
        [self.selectItem setTitle:BTN_CANCEL];
    }
    if([[self.selectItem title] isEqualToString:BTN_SAVE]) {
        NSString *message = @"已存在内容重组文件:\n";
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for(dict in [self reorganizeNames])
            message = [message stringByAppendingString:[NSString stringWithFormat:@"%@\n", dict[@"fileName"]]];
        
        message = [message stringByAppendingString:@"\n请输入内容重组后文件名称"];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"收藏" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    if([[self.selectItem title] isEqualToString:BTN_CANCEL]) {
        [self.selectItem setTitle:BTN_SELECT];
        self.editItem.enabled = !self.selectable;
        _gmGridView.selecting = self.selectable;
    }
}

- (void) switchEditable {
    self.editabled = !self.editabled;
    
    self.selectItem.enabled = !self.editabled;
    _gmGridView.editing = self.editabled;
}

/**
 *  内容重组的文件列表
 *
 *  @return [{fileName: filename, fileId: fileid}]
 */
- (NSMutableArray *) reorganizeNames {
    NSMutableArray *fileNames = [[NSMutableArray alloc]init];
    
    // 重组内容文件名称格式: r150501
    NSString *filesPath = [FileUtils getPathName:FILE_DIRNAME];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:filesPath error:&error];
    
    // 过滤出原重组内容的文件列表进行匹配
    NSPredicate *rPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] 'r'"];
    NSArray *reorganizeFiles = [files filteredArrayUsingPredicate:rPredicate];

    NSString *fileId, *filePath, *descPath, *descContent;

    for(fileId in reorganizeFiles) {
        filePath = [filesPath stringByAppendingPathComponent:fileId];
        descPath = [filePath stringByAppendingPathComponent:FILE_CONFIG_FILENAME];
        
        // 配置档不存在，跳过
        if(![FileUtils checkFileExist:descPath isDir:false])
            continue;
        
        // 解析字符串为JSON
        descContent = [NSString stringWithContentsOfFile:descPath usedEncoding:NULL error:NULL];
        id desc = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:NSJSONReadingMutableContainers
                                                    error:NULL];

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:desc[@"name"], @"fileName", fileId, @"fileId", nil];
        [fileNames addObject:dict];
    }
    
    return fileNames;
}

/**
 *  拷贝文件fromFileId的页面pageName至文件toFileId下
 *
 *  @param pageName   页面名称fildId_pageId.html
 *  @param fromFileId 源文件id
 *  @param toFileId   目标文件id
 */
- (void)copyFilePage:(NSString *)pageName
          FromFileId:(NSString *)fromFileId
            ToFileId:(NSString *)toFileId {
    // FILE_DIRNAME/fileId/{fileId_pageId.html, fileId_pageId.gif, desc.json}
    
    NSError *error;
    NSString *filePath, *newFilePath, *pagePath, *newPagePath, *imagePath, *newImagePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filesPath = [FileUtils getPathName:FILE_DIRNAME];
    
    filePath      = [filesPath stringByAppendingPathComponent:fromFileId];
    newFilePath   = [filesPath stringByAppendingPathComponent:toFileId];
    // 复制html文件
    pagePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", pageName, PAGE_HTML_FORMAT]];
    newPagePath = [newFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", pageName, PAGE_HTML_FORMAT]];
    [fileManager copyItemAtPath:pagePath toPath:newPagePath error:&error];
    if(error) NSLog(@"%s#%d <#copy %@\n to\n %@\n failed for %@>", __FILE__, __LINE__, pagePath, newPagePath, [error localizedDescription]);
    // 复制图片
    imagePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", pageName, PAGE_IMAGE_FORMAT]];
    newImagePath = [newFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", pageName, PAGE_IMAGE_FORMAT]];
    [fileManager copyItemAtPath:imagePath toPath:newImagePath error:&error];
    if(error) NSLog(@"%s#%d <#copy %@\n to\n %@\n failed for %@>", __FILE__, __LINE__, imagePath, newImagePath, [error localizedDescription]);
}

/**
 *  交换文件fildId的页面序号index1与index2的顺序，并修改FILE_COFNIG_FILENAME文件
 *
 *  @param fileId 文件id
 *  @param index1 exchangePageIndex
 *  @param index2 withPageIndex
 */
- (void) excangePageOrder:(NSString *)fileId
                FromIndex:(NSInteger)index1
                  ToIndex:(NSInteger)index2 {
    
    NSError *error;
    NSString *filesPath = [FileUtils getPathName:FILE_DIRNAME];
    NSString *filePath = [filesPath stringByAppendingPathComponent:fileId];
    NSString *descPath = [filePath stringByAppendingPathComponent:FILE_CONFIG_FILENAME];
    
    NSString *descContent = [NSString stringWithContentsOfFile:descPath usedEncoding:NULL error:NULL];
    id descData = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingMutableContainers
                                                 error:&error];
    if(error) NSLog(@"<# parse json error: %@>", [error localizedDescription]);
    
    NSMutableArray *pageOrder = descData[@"order"];
    [pageOrder exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    
    // 重置order内容并写入配置档
    [descData setObject:pageOrder forKey:@"order"];
    [self writeJSON:descData Into:descPath];
}

/**
 *  移除文件页面序号为index的页面
 *
 *  @param fileId 文件id
 *  @param index  页面序号
 */
- (void) removePage:(NSString *)fileId
              Index:(NSInteger)index {
    
    NSError *error;
    NSString *filesPath = [FileUtils getPathName:FILE_DIRNAME];
    NSString *filePath = [filesPath stringByAppendingPathComponent:fileId];
    NSString *descPath = [filePath stringByAppendingPathComponent:@"desc.json"];
    
    NSString *descContent = [NSString stringWithContentsOfFile:descPath usedEncoding:NULL error:NULL];
    id descData = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:NSJSONReadingMutableContainers
                                                    error:&error];
    if(error) NSLog(@"<# parse json error: %@>", [error localizedDescription]);
    
    NSMutableArray *pageOrder = descData[@"order"];
    [pageOrder removeObjectAtIndex:index];
    
    // 重置order内容并写入配置档
    [descData setObject:pageOrder forKey:@"order"];
    [self writeJSON:descData Into:descPath];
}

/**
 *  修改后的配置档写入文件
 *
 *  @param data     JSON配置信息
 *  @param filePath 配置档路径
 */
- (void) writeJSON:(NSMutableDictionary *)data Into:(NSString *) filePath {
    NSError *error;
    if ([NSJSONSerialization isValidJSONObject:data]) {
        // NSMutableDictionary convert to JSON Data
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        // JSON Data convert to NSString
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if(!error) {
            [jsonStr writeToFile:filePath atomically:true encoding:NSUTF8StringEncoding error:&error];
            if(error) NSLog(@"<# config write failed: %@>", [error localizedDescription]);
        } else {
            NSLog(@"<# parse data into json failed: %@>", [error localizedDescription]);
        }
    }
}

// TODO 已经创建重组夹列表
// 名称、描述
/**
 *  选择页面后，点击[保存]按钮后，弹出对话框选择内容重组文件名称列表，或新建文件名称及描述
 *
 *  @param alertView   弹出框实现
 *  @param buttonIndex 弹出框按钮序号
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *searchFileName = [[alertView textFieldAtIndex:0] text];
    searchFileName = [searchFileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // 输入文件名称为空，不做操作
    if(!searchFileName.length) return;
    
    // step1: 判断name=text是否存在
    // 重组内容文件名称格式: r150501
    NSError *error;
    NSString *searchFileId;
    NSMutableArray *reorganizeNames = [self reorganizeNames];
    NSString *filesPath = [FileUtils getPathName:FILE_DIRNAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 检测已经内容重组的文件名称
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    for(dict in reorganizeNames) {
        if([dict[@"fileName"] isEqualToString:searchFileName]) {
            searchFileId = dict[@"fileId"];
            break;
        }
    }
    
    // 重组内容文件的配置档
    NSMutableDictionary *descData = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // step2.1 若不存在,则创建
    NSString *descPath;
    
    NSNumber *pageIndex;
    NSString *pageName;
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    
    if(![searchFileId length]) {
        // 内容重组文件新名称，名称格式: r150501010101
        NSString *newFileId = [NSString stringWithFormat:@"r%@", [ViewUtils dateToStr:[NSDate date] Format:REORGANIZE_FORMAT]];
        NSString *newFilePath = [filesPath stringByAppendingPathComponent:newFileId];
        descPath = [newFilePath stringByAppendingPathComponent:FILE_CONFIG_FILENAME];
        
        // 创建前文件路径前，测试是否不存在
        if(![FileUtils checkFileExist:newFilePath isDir:true])
            [fileManager createDirectoryAtPath:newFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        
        // 创建配置档内容
        [descData setObject:newFileId forKey:@"id"];
        [descData setObject:searchFileName forKey:@"name"];
        [descData setObject:searchFileName forKey:@"desc"];
        
        // 把选中的页面复制到内容重组文件中
        // _select存放的为GridView序号
        for(pageIndex in _select) {
            pageName = [_data objectAtIndex:[pageIndex intValue]][@"pageName"];
            // 拷贝文件page/image
            [self copyFilePage:pageName FromFileId:self.detailId ToFileId:newFileId];
            
            [pages addObject:pageName];
        }
        [descData setObject:pages forKey:@"order"];
        
    // step2.2 收藏夹中原已存在，修改原配置档，复制页面
    } else {
        // 读取原有配置档信息
        NSString *searchFilePath = [filesPath stringByAppendingPathComponent:searchFileId];
        descPath = [searchFilePath stringByAppendingPathComponent:FILE_CONFIG_FILENAME];
        
        NSString *descContent = [NSString stringWithContentsOfFile:descPath usedEncoding:NULL error:NULL];
        descData = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingMutableContainers
                                                     error:&error];
        if(error) NSLog(@"<# parse json data failed: %@>", [error localizedDescription]);

        pages = descData[@"order"];
        for(pageIndex in _select) {
            pageName = [_data objectAtIndex:[pageIndex intValue]][@"pageName"];
            
            // 如果该页面已经存在，则跳过。
            // pageName格式: fileId_pageId
            if([pages containsObject:pageName])
                continue;
            
            // 拷贝文件page/image
            [self copyFilePage:pageName FromFileId:self.detailId ToFileId:searchFileId];
            
            [pages addObject:pageName];
        }
        // 重新赋值order
        [descData setObject:pages forKey:@"order"];
    }
    
    // 配置信息写入文件
    [self writeJSON:descData Into:descPath];
}

//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    _gmGridView = nil;
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

// GridViewCell界面 - 文件各页面展示界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        cell.selectButtonIcon = [UIImage imageNamed:@"overlay.png"];
        cell.selectButtonOffset = CGPointMake(0, 0);
        
        // FILE_DIRNAME/fileId/{fileId_pageId.html, fileId_pageId.gif, desc.json}
        // _data数组来自desc.json字段order
        NSMutableDictionary *mutableDictionary = [_data objectAtIndex:index];
        
        NSString *filePath = [FileUtils getPathName:FILE_DIRNAME FileName:self.detailId];
        // imageName与pageName相同，命名格式为fileId_pageId
        NSString *imageName = [NSString stringWithFormat:@"%@.%@", mutableDictionary[@"pageName"], PAGE_IMAGE_FORMAT];
        NSString *imagePath = [filePath stringByAppendingPathComponent:imageName];
        
        UIImageView *imageView = [UIImageView alloc];
        UIImage* image = [UIImage alloc];
        if([FileUtils checkFileExist:imagePath isDir:false])
            image = [UIImage imageWithContentsOfFile:imagePath];
        else {
            image = [UIImage imageNamed:PAGE_IMAGE_NOT_FOUND];
            NSLog(@"<#imageNotFound: %@>", imagePath);
        }
        
        imageView = [imageView initWithImage:image];
        // TODO 界面SIZE需要宏定义
        imageView = [imageView initWithFrame:CGRectMake(0, 0, 230, 150)];
        
        
        [cell setContentView: imageView];
    }
    
    return cell;
}

// B5 页面移除 - 点击导航栏中的[移除], 各页面左上角出现[x]按钮，点击[x]则会移除fileId_pageId.{html,gif}，并修改desc.json[@"order"]
- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
    [self removePage:[self currentFileId] Index:index];
    [_data removeObjectAtIndex:index];
}

// B6 内容重组 - 点击导航栏中的[选择], 点击指定页面，页面会出现[V]表示选中，选择想要的页面后，再点击导航栏中的[保存] ->
//   弹出选择框有已经重组文件名称，选择指定文件名称，则会把页面拷贝至选择的fileId/下并修改desc.json[@"order"]
//   如果新建内容重组文件，则输入文件名称、文件描述，然后生成新的fileId(ryyMMddHHmmSS), 把页面拷贝至新的fileId/下，并创建desc.json
- (void)GMGridView:(GMGridView *)gridView selectItemAtIndex:(NSInteger)index {
    NSNumber *i = [NSNumber numberWithInteger:index];
    // 未记录该cell的状态，只能过判断_select是否包含i
    if([_select containsObject:i])
        [_select removeObject:i];
    else
        [_select addObject:i];
    
    if([_select count])
        [self.selectItem setTitle:BTN_SAVE];
    else
        [self.selectItem setTitle:BTN_CANCEL];
    
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

// 页面位置互换
// B4 页面顺序 - 长按[页面]至颤动，搬动至指定位置，重置fileId/desc[@"order"]
- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2 {
    NSLog(@"%s#%d <# %ld => %ld in %@>", __FILE__, __LINE__, (long)index1, (long)index2, [self currentFileId]);
    [self excangePageOrder:[self currentFileId] FromIndex:index1 ToIndex:index2];
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

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell { }

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

