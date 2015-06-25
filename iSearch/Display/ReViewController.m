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
#import "ViewSlidePage.h"
#import "GMGridView.h"

#import "const.h"
#import "Slide.h"
#import "message.h"
#import "FileUtils.h"
#import "ViewUtils.h"
#import "ExtendNSLogFunctionality.h"

#import "MainAddNewTagView.h"
#import "UIViewController+CWPopup.h"

@interface ReViewController () <GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewActionDelegate> {
    __gm_weak GMGridView *_gmGridView;
    NSMutableArray       *_dataList;   // 文件的页面信息
    NSMutableArray       *_selectedList; // 内容重组选择的页面序号
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // GridView Container
@property (weak, nonatomic) IBOutlet UINavigationItem *navigation;

@property (weak, nonatomic) IBOutlet UIView *navBarContainerView;
@property (nonatomic, nonatomic) BOOL isFavorite; // 收藏文件、正常下载文件
@property (nonatomic, nonatomic) BOOL selectState; // 编辑状态
@property (nonatomic, strong) Slide  *slide;
@property (nonatomic, nonatomic) NSString  *slideID;
@property (nonatomic, nonatomic) NSString  *pageID; // 由展示文档页面跳至本页时需要使用
@property (nonatomic, nonatomic) UIBarButtonItem *barItemEdit; // 是否切换至编辑状态
@property (nonatomic, nonatomic) UIBarButtonItem *barItemRestore; // 恢复至初始状态，desc.json覆盖desc.json.swp
@property (nonatomic, nonatomic) UIBarButtonItem *barItemSave;   // 编辑状态下至少选择一个页面时激活
//@property (nonatomic, nonatomic) UIBarButtonItem *barItemRemove; // 编辑状态下至少选择一个页面时激活
@property (nonatomic, nonatomic) NSMutableDictionary *pageInfoTmp;   // 文档页面信息: 自来那个文档，遍历页面时减少本地IO
@property (nonatomic, nonatomic) MainAddNewTagView *mainAddNewTagView;

@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIButton *saveToButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;


@end

@implementation ReViewController
@synthesize slideID;
@synthesize pageID;
@synthesize barItemRestore;
@synthesize barItemEdit;
@synthesize barItemSave;
@synthesize pageInfoTmp;
@synthesize selectState;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * 实例变量初始化
     */
    self.selectState = false;
    self.pageInfoTmp = [[NSMutableDictionary alloc] init];
    _dataList = [[NSMutableArray alloc] init];
    _selectedList = [[NSMutableArray alloc] init];
    // 必须放前排 for 后面一些设置需要用到slideID/pageID
    [self loadConfigInfo];

    /**
     *  导航栏控件
     */
    // 编辑状态-切换
    self.barItemEdit = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:BTN_EDIT]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(actionEditPages:)];
    self.barItemEdit.possibleTitles = [NSSet setWithObjects:BTN_EDIT, BTN_CANCEL, nil];
    
    // 恢复按钮 - desc.json覆盖desc.json.swp
    self.barItemRestore = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:BTN_RESTORE]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(actionRestorePages:)];
    // 对比是否有修改，以此设置[恢复]状态
    [self checkDescSwpContent];
    
    // 保存 - 编辑状态下，至少选择一页面时，激活
    self.barItemSave = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:BTN_SAVE]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                  action:@selector(actionSavePages:)];
    self.barItemSave.enabled = NO;
    
//    // 移除 - 编辑状态下，至少选择一页面时，激活
//    self.barItemRemove = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:BTN_REMOVE]
//                                                    style:UIBarButtonItemStylePlain
//                                                   target:self
//                                                   action:@selector(actionRemovePages:)];
//    self.barItemRemove.enabled = NO;
    self.navigation.rightBarButtonItems = @[self.barItemEdit,self.barItemRestore,self.barItemSave];
    
    /**
     *  CWPopup 事件
     */
    self.useBlurForPopup = YES;
    
    [self configGridView];
    [self refreshGridView];
}

- (void) configGridView {
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.scrollView.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollView addSubview:gmGridView];
    _gmGridView = gmGridView;
    
    _gmGridView.style = GMGridViewStylePush;
    _gmGridView.itemSpacing = 50;  // 页面横向间隔
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(30, 10, -5, 10);
    _gmGridView.centerGrid = YES;
    _gmGridView.actionDelegate = self;
    _gmGridView.sortingDelegate = self;
    _gmGridView.dataSource = self;
    
    _gmGridView.mainSuperView = self.scrollView;
    _gmGridView.selectState = self.selectState;
}
- (void) refreshGridView {
    [_gmGridView reloadData];
    
    [self checkDescSwpContent];
}

/**
 *  B1 点击文件[编辑]时，该fileID写入CONFIG_DIRNAME/REORGANIZE_CONFIG_DIRNAME[@"FileID"]
 *
 */
- (void) loadConfigInfo {
    NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:EDITPAGES_CONFIG_FILENAME];
    NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
    
    self.slideID = config[CONTENT_KEY_EDITID1];
    self.pageID = config[CONTENT_KEY_EDITID2];
    self.isFavorite = ([config[SLIDE_EDIT_TYPE] intValue] == SlideTypeFavorite);
    
    self.slide = [Slide findById:self.slideID isFavorite:self.isFavorite];
    _dataList = self.slide.dictSwp[SLIDE_DESC_ORDER];
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
    // 此处必须读取swp文件
    // 如果在编辑文档页面界面，移动页面顺序、移除页面时，把app关闭，则再次进入编辑页面界面时是与原配置信息不一样的
    // 用户可以通过[恢复]实现还原最原始的状态
    NSString *descSwpPath = [FileUtils slideDescPath:self.slide.ID Dir:self.slide.dirName Klass: SLIDE_CONFIG_SWP_FILENAME];
    NSMutableDictionary *descDict = [FileUtils readConfigFile:descSwpPath];
    NSMutableArray *pagesOrder = [[NSMutableArray alloc] init];

    if(descDict[SLIDE_DESC_ORDER] != nil) {
        pagesOrder = descDict[SLIDE_DESC_ORDER];
    }
    return pagesOrder;
}

/**
 *  导航栏按钮[返回], 关闭当前文档编辑界面。
 *  读取desc.json.swp写回desc.json, 并物理删除swp文件
 *
 *  bad方法: copy then remove or move; 各种问题
 *  @param gesture UIGestureRecognizer
 */
- (IBAction)actionDismiss:(UIGestureRecognizer *)gesture {
    NSError *error;
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    NSString *descPath = [FileUtils slideDescPath:self.slideID Dir:dirName Klass:SLIDE_CONFIG_FILENAME];
    NSString *descSwpPath = [FileUtils slideDescPath:self.slideID Dir:dirName Klass:SLIDE_CONFIG_SWP_FILENAME];
    NSString *descSwpContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:&error];
    
    [descSwpContent writeToFile:descPath atomically:true encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"desc swp info write into desc");
    
    if(!error) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:descSwpPath error:&error];
        NSErrorPrint(error, @"remove desc swp file");
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
    
    }];
}

/**
 *  对比desc.json与desc.json.swp是否一致
 *  TODO: 转成NSMutableDirectory对比
 *
 */
- (void)checkDescSwpContent {
    self.restoreButton.enabled = ![self.slide.pages isEqualToArray:_dataList];
}

/**
 *  导航栏按钮[恢复], desc.json -> desc.json.swp -> reload view
 *
 *  @param sender UIBarButtonItem
 */
- (IBAction)actionRestorePages:(UIBarButtonItem *)sender {
    _dataList = self.slide.pages;

    [self refreshGridView];
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
        //self.barItemSave.enabled = false;
        self.saveToButton.enabled = NO;
        //self.barItemRemove.enabled = false;
        self.removeButton.enabled = NO;
    } else {
        self.selectState = false;
        _gmGridView.selectState = self.selectState;
        
        [self.barItemEdit setTitle: BTN_EDIT];
        // 在有选择多个页面情况下，[保存][移除]是激活的，
        // 但直接[取消]编辑状态时, 就需要手工禁用
        //self.barItemSave.enabled = false;
        self.saveToButton.enabled = NO;
        //self.barItemRemove.enabled = false;
        self.removeButton.enabled = NO;
    }
    
}

/**
 *  导航栏[保存]事件；[编辑]选择页面后，该按钮为激活状态。
 *  弹出MainAddNewTagView来处理[新建标签][选择标签]逻辑
 *  masterViewController为必设置项，否则MainAddNewTagView无法获取当前Context。
 *
 *  @param sender UIBarButtonItem
 */
- (IBAction)actionSavePages:(UIBarButtonItem *)sender {
    if(self.mainAddNewTagView == nil) {
        self.mainAddNewTagView = [[MainAddNewTagView alloc] init];
        self.mainAddNewTagView.masterViewController = self;
    }
    [self presentPopupViewController:self.mainAddNewTagView animated:YES completion:^(void) {
        NSLog(@"popup view presented");
    }];
}

/**
 *  导航栏[移除]事件；[编辑]选择页面后，该按钮为激活状态。
 *  操作desc.json.swp文件，可执行[恢复]
 *
 *  @param sender UIBarButtonItem
 */
- (IBAction)actionRemovePages:(UIBarButtonItem *)sender {
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [_dataList count];
}


- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(213, 234);
}

// GridViewCell界面 - 文件各页面展示界面
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    
    if(index >= [_dataList count]) {
        NSLog(@"BUG: index beyound bounds");
    }
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.selectingButtonIcon   = [UIImage imageNamed:@"overlay_selecting.png"];
        cell.selectingButtonOffset = CGPointMake(0, 0);
        cell.selectedButtonIcon    = [UIImage imageNamed:@"overlay_selected.png"];
        cell.selectedButtonOffset  = CGPointMake(0, 0);
    }
    
    ViewSlidePage *viewSlidePage = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlidePage" owner:self options:nil] objectAtIndex: 0];
    NSString *keyName = [NSString stringWithFormat:@"page-%@", self.slideID];
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    // self.tmpPageInfo - 为了减少重复扫描本地信息
    if(![[self.pageInfoTmp allKeys] containsObject:keyName]) {
        NSString *descSwpPath = [FileUtils slideDescPath:self.slideID Dir:dirName Klass:SLIDE_CONFIG_SWP_FILENAME];
        NSString *descContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:NULL];
        NSMutableDictionary *descSwpDict = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:NULL];
        
        [self.pageInfoTmp setObject:descSwpDict forKey:keyName];
    }
    
    NSDictionary *currentDescSwpDict = [NSDictionary dictionaryWithDictionary: self.pageInfoTmp[keyName]];
    NSString *currentPageID = [currentDescSwpDict[SLIDE_DESC_ORDER] objectAtIndex:index];
    
    if([currentPageID isEqualToString: self.pageID]) {
        [viewSlidePage hightLight];
    }
    viewSlidePage.labelFrom.text = [NSString stringWithFormat:@"来自: %@", currentDescSwpDict[SLIDE_DESC_NAME]];
    viewSlidePage.labelPageNum.text = [NSString stringWithFormat:@"第%ld页#%@", (long)index, [currentDescSwpDict[SLIDE_DESC_ORDER] objectAtIndex:index]];
    
    NSString *thumbnailPath = [FileUtils fileThumbnail:self.slideID PageID:currentPageID Dir:dirName];
    if([FileUtils checkFileExist:thumbnailPath isDir:NO]) {
        [viewSlidePage loadThumbnail: thumbnailPath];
    }
    
    [viewSlidePage bringSubviewToFront:viewSlidePage.btnMask];
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionJumpToDisplay:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [viewSlidePage.btnMask setTag:index];
    [viewSlidePage.btnMask addGestureRecognizer:doubleTapGestureRecognizer];
    
    [cell setContentView: viewSlidePage];
    
    return cell;
}

/**
 *  非编辑状态下，双击直接进入演示该页面
 *  编辑状态下，会有selectButton在最外层，不会触发此处双击事件
 *
 *  @param gestureRecognizer gestureRecognizer
 */
- (IBAction)actionJumpToDisplay:(UIGestureRecognizer*)gestureRecognizer {
    NSInteger index = gestureRecognizer.view.tag;
    NSLog(@"jump to %ld",(long)index);
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    configDict[SLIDE_DISPLAY_JUMPTO] = [NSNumber numberWithInteger:index];
    [FileUtils writeJSON:configDict Into:configPath];
    
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

// B5 页面移除 - 点击导航栏中的[移除], 各页面左上角出现[x]按钮，点击[x]则会移除fileId_pageId.{html,gif}，并修改desc.json[@"order"]
- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index {
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
    if([_selectedList containsObject:i])
        [_selectedList removeObject:i];
    else
        [_selectedList addObject:i];
    
    // 至少选择一个页面，[保存]/[移除]按钮处于激活状态
    if([_selectedList count]) {
        //self.barItemSave.enabled = true;
        self.saveToButton.enabled = YES;
        //self.barItemRemove.enabled = true;
        self.removeButton.enabled = YES;
    } else {
        //self.barItemSave.enabled = false;
        self.saveToButton.enabled = NO;
        //self.barItemRemove.enabled = false;
        self.removeButton.enabled = NO;
    }
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
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
                         cell.contentView.backgroundColor = [UIColor clearColor];
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
                         cell.contentView.backgroundColor = [UIColor clearColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index {
    return !self.selectState;
}

// B4 页面顺序 - 长按[页面]至颤动，搬动至指定位置，重置fileId/desc[@"order"]
- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex {
    NSLog(@"%ld => %ld",(long)oldIndex, (long)newIndex);
    NSString *pageName = [_dataList objectAtIndex:oldIndex];
    [_dataList insertObject:pageName atIndex:newIndex];
    if(oldIndex > newIndex) {
        [_dataList removeObjectAtIndex:(oldIndex+1)];
    } else {
        [_dataList removeObjectAtIndex:oldIndex];
    }
    [self checkDescSwpContent];
}
- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2 {
}

#pragma mark - Private methods
/**
 *  封装自己的writeJSON，需要操作DateUtils/FileUtils
 *
 *  @param dict desc config information with NSMutableDictionary format
 *  @param path the path that write into
 */
- (void) writeJSON:(NSMutableDictionary *)dict Into:(NSString *)path {
    dict = [DateUtils updateSlideTimestamp:dict];
    [FileUtils writeJSON:dict Into:path];
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
    // tag == 101 => [移除]
    if(alertView.tag == 101 && buttonIndex == 1) {
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
    NSLog(@"before sort: %@", _selectedList);
    [_selectedList sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    NSLog(@"after sort: %@", _selectedList);
    
    NSLog(@"before remove: %@", _dataList);
    for(pageIndex in _selectedList)
        [_dataList removeObjectAtIndex:[pageIndex integerValue]];
    NSLog(@"after remove: %@", _dataList);
    
    NSError *error;
    NSMutableDictionary *descDict = [[NSMutableDictionary alloc] init];
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    NSString *descSwpPath = [FileUtils slideDescPath:self.slideID Dir:dirName Klass:SLIDE_CONFIG_SWP_FILENAME];
    NSString *descSwpContent = [NSString stringWithContentsOfFile:descSwpPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"[移除] read desc.swp file");
    descDict = [NSJSONSerialization JSONObjectWithData:[descSwpContent dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingMutableContainers
                                                 error:&error];
    NSErrorPrint(error, @"[移除] desc.swp convert into json");
    descDict[@"order"] = _dataList;
    [self writeJSON:descDict Into:descSwpPath];
    [self refreshGridView];
}

/**
 *  拷贝文件FILE_DIRNAME/fromFileId的页面pageName至文件FAVORITE_DIRNAME/toFileId下
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
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    NSString *filesPath = [FileUtils getPathName:dirName];
    NSString *favoritePath = [FileUtils getPathName:FAVORITE_DIRNAME];
    
    filePath      = [filesPath stringByAppendingPathComponent:fromFileId];
    newFilePath   = [favoritePath stringByAppendingPathComponent:toFileId];
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


- (IBAction)back:(UIButton *)sender {
    NSError *error;
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    NSString *descPath = [FileUtils slideDescPath:self.slideID Dir:dirName Klass:SLIDE_CONFIG_FILENAME];
    NSString *descSwpPath = [FileUtils slideDescPath:self.slideID Dir:dirName Klass:SLIDE_CONFIG_SWP_FILENAME];
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

- (IBAction)remove:(UIButton *)sender {
    NSString *message = @"确认移除以下页面:\n";
    NSNumber *i = [[NSNumber alloc] init];
    for(i in _selectedList)
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

- (IBAction)saveTo:(UIButton *)sender {
    MainAddNewTagView *popupView = [[MainAddNewTagView alloc] init];
    popupView.masterViewController = self;
    [self presentPopupViewController:popupView animated:YES completion:^(void) {
        NSLog(@"popup view presented");
    }];
}

- (IBAction)restore:(UIButton *)sender {
    NSError *error;
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    NSString *descPath = [FileUtils slideDescPath:self.slideID Dir:dirName Klass:SLIDE_CONFIG_FILENAME];
    NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"read desc file");
    NSString *descSwpPath = [FileUtils slideDescPath:self.slideID Dir:dirName Klass:SLIDE_CONFIG_SWP_FILENAME];
    
    [descContent writeToFile:descSwpPath atomically:true encoding:NSUTF8StringEncoding error:&error];
    NSErrorPrint(error, @"[restore] desc content write into desc swp file");
    // 重新加载文档页面
    if(!error) {
        [self refreshGridView];
        [self checkDescSwpContent];
    }
}

- (IBAction)editButtonTouched:(UIButton *)sender {
    if(!self.selectState) {
        self.selectState = true;
        _gmGridView.selectState = self.selectState;
        
        // 导航栏按钮样式
        //[self.barItemEdit setTitle: BTN_CANCEL];
        //self.barItemSave.enabled = false;
        self.saveToButton.enabled = NO;
        //self.barItemRemove.enabled = false;
        self.removeButton.enabled = NO;
        [self.editButton setImage:[UIImage imageNamed:@"iconCancel"] forState:UIControlStateNormal];
    } else {
        self.selectState = false;
        _gmGridView.selectState = self.selectState;
        
        //[self.barItemEdit setTitle: BTN_EDIT];
        // 在有选择多个页面情况下，[保存][移除]是激活的，
        // 但直接[取消]编辑状态时, 就需要手工禁用
        //self.barItemSave.enabled = false;
        self.saveToButton.enabled = NO;
        //self.barItemRemove.enabled = false;
        self.removeButton.enabled = NO;
        [self.editButton setImage:[UIImage imageNamed:@"iconEdit2"] forState:UIControlStateNormal];
    }
}

@end

