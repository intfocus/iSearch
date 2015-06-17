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
//      3. 重组
//      4. 恢复 -> 上述操作
//
//  已下载文件的目录结构:
//      FILE_DIRNAME/fileId/{fileId_pageId.html, desc.json, fileId_pageId/fileId_pageId{.pdf,.gif}}
//
//  界面初始化:
//      扫描FILE_DIRNAME，如果存在配置档fileId/desc.json，则显示该文件信息
//      点击文件[编辑]进入文档页面界面，拷贝desc.json一份，命名为desc.json.swp，同时把fileId/pageId写入CONFIG_DIRNAME/REORGANIZE_CONFIG_DIRNAME中
//
//  文档页面详情:
//      从文档界面跳转至页面界面时
//      读取配置档desc.json.swp[@"order"] 并按该顺序加载界面
//
//  文件页面功能:
//      交换顺序: 长按拖拉, 实时写回desc.json.swp
//      编辑状态: 点击导航栏[编辑]
//          至少选择一个页面时，可以操作[保存][移除]
//          选择页面另存在: 选择状态，选择页面，[保存]为新文件或合并至已存在文件（已存在的页面不会复制）
//
//          移除: desc.json.swp[@"order"] 数组操作，并写回
//          保存: 选择已选择的标签文件，则直接复制过去；新创建标签，先创建文件夹，再复制文件
//      恢复: 比较desc.json与desc.json.swp若不相同则处于激活状态，使用desc.json覆盖desc.json.swp并刷新界面
//
//      返回: 对比desc.json.swp[@order]物理删除文档页面，并写回desc.json, 最后删除desc.json.swp配置档
//
//   **重点**
//   1. 当前viewController功能代码中操作的配档为desc.json.swp
//   2.
//
//  w:427  h:375 margin:20
//  w:2048 h:1536
//  w:1024 h:768

#import "ReViewController.h"
#import "ViewFilePage.h"
#import "GMGridView.h"
#import "TagListView.h"
#import "UIViewController+CWPopup.h"

#import "const.h"
#import "message.h"
#import "FileUtils.h"
#import "ViewUtils.h"
#import "ExtendNSLogFunctionality.h"

@interface ReViewController () <GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate> {
    __gm_weak GMGridView *_gmGridView;
    UIImageView          *changeBigImageView;
    NSMutableArray       *_data; // 文件的页面信息
    NSMutableArray       *_select; // 内容重组选择的页面序号
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // GridView Container
@property (weak, nonatomic) IBOutlet UINavigationItem *navigation;
@property (nonatomic, assign) BOOL selectState;   // 编辑状态
@property (nonatomic, nonatomic) NSString  *fileID;
@property (nonatomic, nonatomic) NSString  *pageID; // 由展示文档页面跳至本页时需要使用
@property (nonatomic, nonatomic) UIBarButtonItem *barItemEdit; // 是否切换至编辑状态
@property (nonatomic, nonatomic) UIBarButtonItem *barItemRestore; // 恢复至初始状态，desc.json覆盖desc.json.swp
@property (nonatomic, nonatomic) UIBarButtonItem *barItemSave;   // 编辑状态下至少选择一个页面时激活
@property (nonatomic, nonatomic) UIBarButtonItem *barItemRemove; // 编辑状态下至少选择一个页面时激活
@property (nonatomic, nonatomic) NSMutableDictionary *pageInfoTmp;   // 文档页面信息: 自来那个文档，遍历页面时减少本地IO

@end

@implementation ReViewController
@synthesize fileID;
@synthesize pageID;
@synthesize barItemRestore;
@synthesize barItemEdit;
@synthesize barItemSave;
@synthesize barItemRemove;
@synthesize pageInfoTmp;
@synthesize selectState;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 任何@property对象都需要初始化,否则直接赋值失败
    self.pageInfoTmp = [[NSMutableDictionary alloc] init];
    _data = [[NSMutableArray alloc] init];
    _select = [[NSMutableArray alloc] init];
    self.selectState = false;
    // 必须放前排 for 后面一些设置需要用到fileID/pageID
    [self loadConfigInfo];
    
    NSLog(@"structureView: %@",NSStringFromCGRect(self.scrollView.bounds));

    // 导航左侧按钮区
    NSMutableArray* array = [NSMutableArray array];
    UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"< 返回"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:@selector(actionDismiss:)];
    [array addObject:item];
    self.navigation.leftBarButtonItems = array;
    
    // 导航右侧按钮区
    [array removeAllObjects];
    
    
    // 编辑状态-切换
    self.barItemEdit = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:BTN_EDIT]
                                                       style:UIBarButtonItemStylePlain
                                                      target:nil
                                                      action:@selector(actionEditPages:)];
    self.barItemEdit.possibleTitles = [NSSet setWithObjects:BTN_EDIT, BTN_CANCEL, nil];
    [array addObject:self.barItemEdit];
    
    // 恢复按钮 - desc.json覆盖desc.json.swp
    self.barItemRestore = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:BTN_RESTORE]
                                                          style:UIBarButtonItemStylePlain
                                                         target:nil
                                                         action:@selector(actionRestorePages:)];
    // 对比是否有修改，以此设置[恢复]状态
    [self checkDescSwpContent];
    [array addObject:self.barItemRestore];
    
    // 保存 - 编辑状态下，至少选择一页面时，激活
    self.barItemSave = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:BTN_SAVE]
                                                    style:UIBarButtonItemStylePlain
                                                   target:nil
                                                  action:@selector(actionSavePages:)];
    self.barItemSave.enabled = false;
    [array addObject:self.barItemSave];
    
    // 移除 - 编辑状态下，至少选择一页面时，激活
    self.barItemRemove = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:BTN_REMOVE]
                                                    style:UIBarButtonItemStylePlain
                                                   target:nil
                                                   action:@selector(actionRemovePages:)];
    self.barItemRemove.enabled = false;
    [array addObject:self.barItemRemove];
    self.navigation.rightBarButtonItems = [[array reverseObjectEnumerator] allObjects];
    
    // 选择页面后，保存
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
    self.useBlurForPopup = YES;
    
    // 配置创建 GMGridView
    [self configGridView];
    
    [self refreshGridView];
}

- (void) configGridView {
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.scrollView.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:gmGridView];
    _gmGridView = gmGridView;
    
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.itemSpacing = 50;  // 页面横向间隔
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(30, 10, -5, 10);
    _gmGridView.centerGrid = YES;
    _gmGridView.actionDelegate = self;
    _gmGridView.sortingDelegate = self;
    _gmGridView.transformDelegate = self;
    _gmGridView.dataSource = self;
    self.scrollView.backgroundColor = [UIColor redColor];
    _gmGridView.backgroundColor = [UIColor greenColor];
    
    _gmGridView.mainSuperView = self.scrollView;
    self.view.backgroundColor = [UIColor blueColor];
    _gmGridView.selectState = self.selectState;
}
- (void) refreshGridView {
    // 加载文件各页面
    _data = [self loadFilePages];;
    [_gmGridView reloadData];
    
    [self checkDescSwpContent];
}

/**
 *  B1 点击文件[编辑]时，该fileID写入CONFIG_DIRNAME/REORGANIZE_CONFIG_DIRNAME[@"FileID"]
 *
 */
- (void) loadConfigInfo {
    NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:REORGANIZE_CONFIG_FILENAME];
    NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
    
    self.fileID = config[@"FileID"];
    self.pageID = config[@"PageID"];
    //NSLog(@"reorganize:\n%@", config);
}

//////////////////////////////////////////////////////////////
#pragma mark 编辑状态，选择页面，[保存]
//////////////////////////////////////////////////////////////
- (IBAction)btnPresentPopup:(UIButton *)sender {
    TagListView *tagListView = [[TagListView alloc] init];
    [self presentPopupViewController:tagListView animated:YES completion:^(void) {
        NSLog(@"popup view presented");
    }];
}

- (void)dismissPopup {
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissed");
        }];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark 加载文件各页面
//////////////////////////////////////////////////////////////

/**
 *  B2 读取fileID/desc.json.swp[@"order"]并按该顺序写入_data
 *
 *  @return @[{pageName: fileID_pageID}]
 */
- (NSMutableArray*) loadFilePages {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableDictionary *descJSON = [[NSMutableDictionary alloc] init];
    
    // 此处必须读取swp文件
    // 如果在编辑文档页面界面，移动页面顺序、移除页面时，把app关闭，则再次进入编辑页面界面时是与原配置信息不一样的
    // 用户可以通过[恢复]实现还原最原始的状态
    NSError *error;
    NSString *descSwpPath = [FileUtils fileDescPath:self.fileID Klass: FILE_CONFIG_SWP_FILENAME];
    NSString *descSwpContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read desc.swp file");
    descJSON = [NSJSONSerialization JSONObjectWithData:[descSwpContent dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingMutableContainers
                                                 error:&error];
    NSErrorPrint(error, @"desc.swp content convert into json");
    NSMutableArray *pagesOrder = descJSON[@"order"];

    NSString *pageName = [[NSString alloc] init];
    for(pageName in pagesOrder) {
        [array addObject:pageName];
    }
    
    return array;
}

/**
 *  导航栏按钮[返回], 关闭当前文档编辑界面。
 *  读取desc.json.swp写回desc.json, 并物理删除swp文件
 *
 *  bad方法: copy then remove or move; 各种问题
 *  @param gesture UIGestureRecognizer
 */
- (void)actionDismiss:(UIGestureRecognizer *)gesture {
    NSError *error;
    NSString *descPath = [FileUtils fileDescPath:self.fileID Klass:FILE_CONFIG_FILENAME];
    NSString *descSwpPath = [FileUtils fileDescPath:self.fileID Klass:FILE_CONFIG_SWP_FILENAME];
    NSString *descSwpContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:&error];
    
    [descSwpContent writeToFile:descPath atomically:true encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"desc swp info write into desc");
    
    if(!error) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:descSwpPath error:&error];
        NSErrorPrint(error, @"remove desc swp file");
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

/**
 *  对比desc.json与desc.json.swp是否一致
 *  TODO: 转成NSMutableDirectory对比
 *
 */
- (void)checkDescSwpContent {
    NSError *error;
    NSString *descPath = [FileUtils fileDescPath:self.fileID Klass:FILE_CONFIG_FILENAME];
    NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read desc file");
    NSMutableDictionary *descDict = [NSMutableDictionary alloc];
    descDict = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSErrorPrint(error, @"desc content convert to json");
    
    NSString *descSwpPath = [FileUtils fileDescPath:self.fileID Klass:FILE_CONFIG_SWP_FILENAME];
    NSString *descSwpContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read desc swp file");
    NSMutableDictionary *descSwpDict = [NSMutableDictionary alloc];
    descSwpDict = [NSJSONSerialization JSONObjectWithData:[descSwpContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSErrorPrint(error, @"desc swp content convert to json");
    
    BOOL isSame = [descDict isEqualToDictionary:descSwpDict];
    self.barItemRestore.enabled = !isSame;
}

/**
 *  导航栏按钮[恢复], desc.json -> desc.json.swp -> reload view
 *
 *  @param sender UIBarButtonItem
 */
- (IBAction)actionRestorePages:(UIBarButtonItem *)sender {
    NSError *error;
    NSString *descPath = [FileUtils fileDescPath:self.fileID Klass:FILE_CONFIG_FILENAME];
    NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read desc file");
    NSString *descSwpPath = [FileUtils fileDescPath:self.fileID Klass:FILE_CONFIG_SWP_FILENAME];

    [descContent writeToFile:descSwpPath atomically:true encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"[restore] desc content write into desc swp file");
    // 重新加载文档页面
    if(!error) {
        [self refreshGridView];
        [self checkDescSwpContent];
    }
}

/**
 *  导航栏按钮[编辑], 编辑状态切换。
 *
 *  @param sender UIBarButtonItem
 */
- (IBAction)actionEditPages:(UIBarButtonItem*)sender {
    if(!self.selectState) {
        self.selectState = true;
        _gmGridView.selectState = self.selectState;
        
        // 导航栏按钮样式
        [self.barItemEdit setTitle: BTN_CANCEL];
        self.barItemSave.enabled = false;
        self.barItemRemove.enabled = false;
    } else {
        self.selectState = false;
        _gmGridView.selectState = self.selectState;
        
        [self.barItemEdit setTitle: BTN_EDIT];
        // 在有选择多个页面情况下，[保存][移除]是激活的，
        // 但直接[取消]编辑状态时, 就需要手工禁用
        self.barItemSave.enabled = false;
        self.barItemRemove.enabled = false;
    }
    
}

- (IBAction)actionSavePages:(UIBarButtonItem*)sender {
    NSString *message = @" 已存在内容重组文件:\n";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    for(dict in [FileUtils favoriteFileList])
        message = [message stringByAppendingString:[NSString stringWithFormat:@"%@\n", dict[FILE_DESC_NAME]]];
    
    message = [message stringByAppendingString:@"\n 请输入内容重组后文件名称 "];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@" 添加标签 "
                                                         message:message
                                                        delegate:self
                                               cancelButtonTitle:BTN_CANCEL
                                               otherButtonTitles:BTN_SURE, nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 100; // 区分 alwrtView, for 所有 alertView 共用同一个回调函数
    
    [alertView show];
//    [self performSelector:@selector(btnPresentPopup:) withObject:self afterDelay:0];
//    TagListView *tagListView = [[TagListView alloc] init];
//    [self presentPopupViewController:tagListView animated:YES completion:^(void) {
//        NSLog(@"popup view presented");
//    }];
}

- (IBAction)actionRemovePages:(UIBarButtonItem*)sender {
    NSString *message = @"确认移除以下页面:\n";
    NSNumber *i = [[NSNumber alloc] init];
    for(i in _select)
        message = [message stringByAppendingString:[NSString stringWithFormat:@"第%@页 ", i]];
    
    message = [message stringByAppendingString:@"\n未关闭当前界面时，可选择[恢复]此操作。"];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"移除"
                                                         message:message
                                                        delegate:self
                                               cancelButtonTitle:BTN_CANCEL
                                               otherButtonTitles:BTN_SURE, nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    alertView.tag = 101; // 区分alwrtView, for 所有alertView共用同一个回调函数
    
    [alertView show];
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
    NSString *input = [[alertView textFieldAtIndex:0] text];
    
    // buttonIndex == 0 -> cancel
    // tag == 100 => [保存]
    if(alertView.tag == 100 && buttonIndex == 1) {
        [self selectAndSavePages:input];
        
    // tag == 101 => [移除]
    } else if(alertView.tag == 101 && buttonIndex == 1) {
        [self removePagesFromDescSwpFile];
    } else {
        NSLog(@"BUG: alertView.tag=%d; buttonIndex: %d", alertView.tag, buttonIndex);
    }
}

/**
 *  选择页面后，点击[移除]按钮后，确认后，重置desc.swp[@order]
 *  **重点** 必须倒序removeObjectAtIndex
 */
- (void)removePagesFromDescSwpFile {
    NSNumber *pageIndex = [[NSNumber alloc] init];
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSLog(@"before sort: %@", _select);
    [_select sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    NSLog(@"after sort: %@", _select);
    
    NSLog(@"before remove: %@", _data);
    for(pageIndex in _select)
        [_data removeObjectAtIndex:[pageIndex integerValue]];
    NSLog(@"after remove: %@", _data);
    
    NSError *error;
    NSMutableDictionary *descJSON = [[NSMutableDictionary alloc] init];
    NSString *descSwpPath = [FileUtils fileDescPath:self.fileID Klass:FILE_CONFIG_SWP_FILENAME];
    NSString *descSwpContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"[移除] read desc.swp file");
    descJSON = [NSJSONSerialization JSONObjectWithData:[descSwpContent dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingMutableContainers
                                                 error:&error];
    NSErrorPrint(error, @"[移除] desc.swp convert into json");
    descJSON[@"order"] = _data;
    [self writeJSON:descJSON Into:descSwpPath];
    [self refreshGridView];
}
/**
 *  编辑状态下，选择多个页面后[保存].（自动归档为收藏）
 *
 // step1: 判断name=text是否存在
 // 重组内容文件名称格式: r150501010101
 *      检测已经内容重组的文件名称
 *      初始化重组内容文件的配置档
 *  step2.1 若不存在,则创建
 *  @param tagName 输入的新标签名称
 */
- (void)selectAndSavePages: (NSString*)tagName {
    NSString *searchFileName = tagName;
    searchFileName = [searchFileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 输入文件名称为空，不做操作
    if(!searchFileName.length) return;
    
    // step1: 判断name=text是否存在
    // 重组内容文件名称格式: r150501010101
    NSError *error;
    NSString *searchFileID;
    NSMutableArray *reorganizeNames = [FileUtils favoriteFileList];
    NSString *filesPath = [FileUtils getPathName:FAVORITE_DIRNAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 检测扫描收藏目录，检测是否存在
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    for(dict in reorganizeNames) {
        if([dict[FILE_DESC_NAME] isEqualToString:searchFileName]) {
            searchFileID = dict[FILE_DESC_ID];
            break;
        }
    }
    
    // 初始化重组内容文件的配置档
    NSMutableDictionary *descData = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *descPath  = [[NSString alloc] init];
    NSNumber *pageIndex = [[NSNumber alloc] init];
    NSString *pageName  = [[NSString alloc] init];
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    
    // step1.1 若不存在,则创建
    if(![searchFileID length]) {
        // 内容重组文件新名称，名称格式: r150501010101
        NSString *newFileID = [NSString stringWithFormat:@"r%@", [ViewUtils dateToStr:[NSDate date] Format:NEW_TAG_FORMAT]];
        NSString *newFilePath = [filesPath stringByAppendingPathComponent:newFileID];
        descPath = [newFilePath stringByAppendingPathComponent:FILE_CONFIG_FILENAME];
        
        // 检测newFileID路径是否不存在，否则创建
        if(![FileUtils checkFileExist:newFilePath isDir:true])
            [fileManager createDirectoryAtPath:newFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        
        // 创建配置档内容
        [descData setObject:newFileID forKey:FILE_DESC_ID];
        [descData setObject:searchFileName forKey:FILE_DESC_NAME];
        [descData setObject:searchFileName forKey:FILE_DESC_DESC];
        
        // 把选中的页面复制到内容重组文件中
        // _select存放的为GridView序号
        for(pageIndex in _select) {
            pageName = [_data objectAtIndex:[pageIndex intValue]];
            // 拷贝文件page/image
            [self copyFilePage:pageName FromFileId:self.fileID ToFileId:newFileID];
            
            [pages addObject:pageName];
        }
        [descData setObject:pages forKey:FILE_DESC_ORDER];
        
        // step2.2 收藏夹中原已存在，修改原配置档，复制页面
    } else {
        // 读取原有配置档信息
        NSString *searchFilePath = [filesPath stringByAppendingPathComponent:searchFileID];
        descPath = [searchFilePath stringByAppendingPathComponent:FILE_CONFIG_FILENAME];
        
        NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
        NSErrorPrint(error, @"read desc file");
        descData = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingMutableContainers
                                                     error:&error];
        NSErrorPrint(error, @"desc content convert into json");
        
        pages = descData[FILE_DESC_ORDER];
        for(pageIndex in _select) {
            pageName = [_data objectAtIndex:[pageIndex intValue]];
            
            // 如果该页面已经存在，则跳过。
            if([pages containsObject:pageName]) continue;
            
            // 拷贝文件page/image
            [self copyFilePage:pageName FromFileId:self.fileID ToFileId:searchFileID];
            
            [pages addObject:pageName];
        }
        // 重新赋值order
        [descData setObject:pages forKey:FILE_DESC_ORDER];
    }
    
    // 配置信息写入文件
    [self writeJSON:descData Into:descPath];
}

/**
 *  拷贝文件fromFileId的页面pageName至文件toFileId下
 *  FILE_DIRNAME/fileId/{fileId_pageId.html, desc.json, fileID_pageID/}
 *
 *  @param pageName   页面名称fildId_pageId.html
 *  @param fromFileId 源文件id
 *  @param toFileId   目标文件id
 */
- (void)copyFilePage:(NSString *)pageName
          FromFileId:(NSString *)fromFileId
            ToFileId:(NSString *)toFileId {
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
    NSErrorPrint(error, @"copy page html from %@ -> %@", fromFileId, toFileId);
    // 复制文件夹
    imagePath = [filePath stringByAppendingPathComponent:pageName];
    newImagePath = [newFilePath stringByAppendingPathComponent:pageName];
    [fileManager copyItemAtPath:imagePath toPath:newImagePath error:&error];
    NSErrorPrint(error, @"copy page folder from %@ -> %@", fromFileId, toFileId);
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
    NSString *descSwpPath = [FileUtils fileDescPath:fileID Klass:FILE_CONFIG_SWP_FILENAME];
    
    NSString *descSwpContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read desc.swp file");
    id descData = [NSJSONSerialization JSONObjectWithData:[descSwpContent dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingMutableContainers
                                                    error:&error];
    NSErrorPrint(error, @"desc.swp content convert into json");
    
    NSMutableArray *pageOrder = descData[@"order"];
    [pageOrder exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    
    // 重置order内容并写入配置档
    [descData setObject:pageOrder forKey:@"order"];
    [self writeJSON:descData Into:descSwpPath];
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
    NSString *descSwpPath = [FileUtils fileDescPath:fileID Klass:FILE_CONFIG_SWP_FILENAME];
    
    NSString *descSwpContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read desc.swp file");
    id descData = [NSJSONSerialization JSONObjectWithData:[descSwpContent dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:NSJSONReadingMutableContainers
                                                    error:&error];
    NSErrorPrint(error, @"desc.swp content convert into json");
    
    NSMutableArray *pageOrder = descData[@"order"];
    [pageOrder removeObjectAtIndex:index];
    
    // 重置order内容并写入配置档
    [descData setObject:pageOrder forKey:@"order"];
    [self writeJSON:descData Into:descSwpPath];
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
        NSErrorPrint(error, @"NsMutableDict convert to json");
        // JSON Data convert to NSString
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if(!error) {
            [jsonStr writeToFile:filePath atomically:true encoding:NSUTF8StringEncoding error:&error];
            NSErrorPrint(error, @"json string write into desc file#%@", [filePath lastPathComponent]);
            
            // 检测desc.swp文件内容，设置导航栏按钮[恢复]是否禁用
            if(!error) [self checkDescSwpContent];
        }
    }
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


- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(SIZE_GRID_VIEW_PAGE_WIDTH, SIZE_GRID_VIEW_PAGE_WIDTH);
}

// GridViewCell界面 - 文件各页面展示界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    
    if(index >= [_data count]) {
        NSLog(@"BUG: index beyound bounds");
    }
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.selectingButtonIcon = [UIImage imageNamed:@"overlay_selecting.png"];
        cell.selectingButtonOffset = CGPointMake(0, 0);
        cell.selectedButtonIcon = [UIImage imageNamed:@"overlay_selected.png"];
        cell.selectedButtonOffset = CGPointMake(0, 0);
        
        // FILE_DIRNAME/fileId/{fileId_pageId.html, fileId_pageId.gif, desc.json}
        // _data数组来自desc.json字段order

        // imageName与pageName相同，命名格式为fileId_pageId
        ViewFilePage *filePage = [[[NSBundle mainBundle] loadNibNamed:@"ViewFilePage" owner:self options:nil] objectAtIndex: 0];
        // TODO: 根据fileID_pageID分解出fileID，然后到CONTENT/fileID/desc.json中读取name;
        // 文档页面可能是从其他文档重组过来的，所以fileID_pageID中的fileID不一定与文档ID一致;

        NSString *currentFileID = self.fileID;
        NSString *keyName = [NSString stringWithFormat:@"page-%@", currentFileID];
        // self.tmpPageInfo - 为了减少重复扫描本地信息
        if(![[self.pageInfoTmp allKeys] containsObject:keyName]) {
            NSString *descSwpPath = [FileUtils fileDescPath:self.fileID Klass:FILE_CONFIG_SWP_FILENAME];
            NSString *descContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:NULL];
            NSMutableDictionary *descSwpDict = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:NULL];
            
            [self.pageInfoTmp setObject:descSwpDict forKey:keyName];
        }
        
        NSDictionary *currentDescSwpDict = [NSDictionary dictionaryWithDictionary: self.pageInfoTmp[keyName]];
        NSString *currentPageID = [currentDescSwpDict[@"order"] objectAtIndex:index];
        
        if([currentPageID isEqualToString: self.pageID]) {
            [filePage hightLight];
            //NSLog(@"hightLight: %@, %@", self.pageID, currentDescSwpDict);
        }
        filePage.labelFrom.text = [NSString stringWithFormat:@"来自: %@", currentDescSwpDict[@"name"]];
        filePage.labelPageNum.text = [NSString stringWithFormat:@"第%ld页#%@", (long)index, [currentDescSwpDict[@"order"] objectAtIndex:index]];
        
        NSString *thumbnailPath = [self fileThumbnail:self.fileID pageID:currentPageID];
        [filePage loadThumbnail: thumbnailPath];
        
        
        
        [cell setContentView: filePage];
    }
    
    return cell;
}

/**
 *  获取文档的缩略图，即文档中的pdf/gif文件; 文件名为PageID, 后缀应该小写
 *
 *  @param FileID fileID
 *  @param PageID pageID
 *
 *  @return pdf/gif文档路径
 */
- (NSString*) fileThumbnail: (NSString*)FileID
                     pageID:(NSString*) PageID {
    NSString *filePath = [FileUtils getPathName:FILE_DIRNAME FileName:FileID];
    NSString *pagePath = [filePath stringByAppendingPathComponent:PageID];
    NSString *thumbnailPath = [pagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", PageID]];
    
    if(![FileUtils checkFileExist:thumbnailPath isDir:false]) {
        thumbnailPath = [pagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif", PageID]];
    }
    //NSLog(@"thumbnail: %@", thumbnailPath);
    return thumbnailPath;
}
/**
 *  读取文档描述
 *
 *  @param filePath 文档路径CONTENT/fileID
 *
 *  @return NSMutableDirectory
 */
- (NSMutableDictionary*)readFileDesc: (NSString*) filePath {
    NSMutableDictionary *desc = [NSMutableDictionary alloc];
    NSString *descPath = [filePath stringByAppendingPathComponent:@"desc.json"];
    if([FileUtils checkFileExist:descPath isDir:false]) {
        NSError *error;
        NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
        if(error) NSLog(@"read desc failed: %@", [error localizedDescription]);
        
        desc = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if(error) NSLog(@"string to json: %@", [error localizedDescription]);
    } else {
        desc = [desc init];
        desc[@"name"] = @"未找到";
    }
    return desc;
}

// B5 页面移除 - 点击导航栏中的[移除], 各页面左上角出现[x]按钮，点击[x]则会移除fileId_pageId.{html,gif}，并修改desc.json[@"order"]
- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
//    [self removePage:[self currentFileId] Index:index];
//    [_data removeObjectAtIndex:index];
}

// B6 内容重组 - 点击导航栏中的[选择], 点击指定页面，页面会出现[V]表示选中，选择想要的页面后，再点击导航栏中的[保存] ->
//   弹出选择框有已经重组文件名称，选择指定文件名称，则会把页面拷贝至选择的fileId/下并修改desc.json[@"order"]
//   如果新建内容重组文件，则输入文件名称、文件描述，然后生成新的fileId(ryyMMddHHmmSS), 把页面拷贝至新的fileId/下，并创建desc.json
/**
 *  编辑状态下，选择页面时回调函数。
 *
 *  @param gridView GridView
 *  @param index    选择的页面序号
 */
- (void)GMGridView:(GMGridView *)gridView selectItemAtIndex:(NSInteger)index {
    // 仅处理编辑状态下
    if(!self.selectState) return;
    
    NSNumber *i = [NSNumber numberWithInteger:index];
    // 未记录该cell的状态，只能过判断_select是否包含i
    if([_select containsObject:i])
        [_select removeObject:i];
    else
        [_select addObject:i];
    
    // 至少选择一个页面，[保存]/[移除]按钮处于激活状态
    if([_select count]) {
        self.barItemSave.enabled = true;
        self.barItemRemove.enabled = true;
    } else {
        self.barItemSave.enabled = false;
        self.barItemRemove.enabled = false;
    }
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

/**
 *  文档页面编辑，使用不到该功能
 *
 *  GridView中各cell点击响应处理，
 *  如果是目录，点击cell则加载该目录下的数据结构；
 *  如果是文件，则点击cell上的功能按钮
 *
 *  @param gridView GridView
 *  @param position 该cell在GridView中的序号
 */
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    // 根据服务器返回的JSON数据显示文件夹或文档。
    //NSMutableDictionary *mutableDictionary = [_data objectAtIndex:position];
    //NSLog(@"click data - name: %@, type: %@", [mutableDictionary objectForKey:@"name"],[mutableDictionary objectForKey:@"type"]);
}



//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////

/**
 *  长按后，cell开始移动
 *
 *  @param gridView <#gridView description#>
 *  @param cell     <#cell description#>
 */
- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell {
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

/**
 *  长按后，cell结束移动
 *
 *  @param gridView <#gridView description#>
 *  @param cell     <#cell description#>
 */
- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor greenColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index {
    return YES;
}

/**
 *  长按结束后，cell的移动信息
 *
 *  @param gridView <#gridView description#>
 *  @param oldIndex 原始位置
 *  @param newIndex 称动后位置
 */
- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex {
    NSObject *object = [_data objectAtIndex:oldIndex];
    [_data removeObject:object];
    [_data insertObject:object atIndex:newIndex];
}

// 页面位置互换
// B4 页面顺序 - 长按[页面]至颤动，搬动至指定位置，重置fileId/desc[@"order"]
- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2 {
    NSLog(@"%ld => %ld",(long)index1, (long)index2);
    [self excangePageOrder:self.fileID FromIndex:index1 ToIndex:index2];
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
                         cell.contentView.backgroundColor = [UIColor purpleColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell { }

@end
