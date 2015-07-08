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

#import "DisplayViewController.h"
#import "ReViewController.h"
#import "MainAddNewTagView.h"
#import "UIViewController+CWPopup.h"

@interface ReViewController () <GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewActionDelegate> {
    __gm_weak GMGridView *_gmGridView;
    NSMutableArray       *_dataList;     // 文件的页面信息
    NSMutableArray       *_selectedList; // 内容重组选择的页面序号
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // GridView Container
@property (weak, nonatomic) IBOutlet UINavigationItem *navigation;

@property (weak, nonatomic) IBOutlet UIView *navBarContainerView;
@property (weak, nonatomic) IBOutlet UILabel *labelNavSlideTitle;
@property (nonatomic, nonatomic) BOOL isFavorite; // 收藏文件、正常下载文件
@property (nonatomic, nonatomic) BOOL selectState; // 编辑状态
@property (nonatomic, strong) Slide  *slide;
@property (nonatomic, strong) NSString  *slideID;
@property (nonatomic, strong) NSString  *pageName; // 由展示文档页面跳至本页时需要使用
@property (nonatomic, strong) NSMutableDictionary *pageInfoTmp;   // 文档页面信息: 自来那个文档，遍历页面时减少本地IO
@property (nonatomic, nonatomic) MainAddNewTagView *mainAddNewTagView;


@property (weak, nonatomic) IBOutlet UIButton *btnNavEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnNavRemove;
@property (weak, nonatomic) IBOutlet UIButton *btnNavRestore;
@property (weak, nonatomic) IBOutlet UIButton *btnNavRefresh;
@property (weak, nonatomic) IBOutlet UIButton *btnNavSaveTo;
@property (weak, nonatomic) IBOutlet UIButton *btnNavDismiss;
@end

@implementation ReViewController
@synthesize slideID;
@synthesize pageName;
@synthesize pageInfoTmp;
@synthesize selectState;

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     * 实例变量初始化
     */
    self.selectState = false;
    self.pageInfoTmp = [[NSMutableDictionary alloc] init];
    _dataList        = [[NSMutableArray alloc] init];
    _selectedList    = [[NSMutableArray alloc] init];
    
    /**
     *  CWPopup 事件
     */
    self.useBlurForPopup = YES;
    
    [self configGridView];
    
    /**
     *  导航栏
     */
    [self.btnNavEdit addTarget:self action:@selector(actionEdit:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnNavRefresh addTarget:self action:@selector(actionRefresh:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnNavRestore addTarget:self action:@selector(actionRestore:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnNavSaveTo addTarget:self action:@selector(actionSaveTo:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnNavDismiss addTarget:self action:@selector(actionDismissReViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnNavRemove addTarget:self action:@selector(actionRemovePages:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.selectState) {
        [self performSelector:@selector(actionEdit:) withObject:self.btnNavEdit];
    }
    self.btnNavRemove.enabled = NO;
    self.btnNavSaveTo.enabled = NO;
    
    [_dataList removeAllObjects];
    [_selectedList removeAllObjects];
    
    [self loadConfigInfo];
    
    if(![FileUtils checkFileExist:[self.slide dictSwpPath] isDir:NO]) {
        [self.slide enterDisplayOrScanState];
    }
    _dataList = [self.slide dictSwp][SLIDE_DESC_ORDER];

    [self checkDescSwpContent];
    [_gmGridView reloadData];
}

//////////////////////////////////////////////////////////////
#pragma mark - memory management
//////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"receive memory warning.");
    _gmGridView = nil;
}

#pragma mark - release
- (void)dealloc {
    self.pageInfoTmp = nil;
    _dataList        = nil;
    _selectedList    = nil;
}

#pragma mark - configuration

- (void) configGridView {
    GMGridView *gmGridView      = [[GMGridView alloc] initWithFrame:self.scrollView.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor  = [UIColor clearColor];
    [self.scrollView addSubview:gmGridView];
    _gmGridView                 = gmGridView;

    _gmGridView.style           = GMGridViewStylePush;
    _gmGridView.itemSpacing     = 50;
    _gmGridView.minEdgeInsets   = UIEdgeInsetsMake(30, 10, -5, 10);
    _gmGridView.centerGrid      = YES;
    _gmGridView.actionDelegate  = self;
    _gmGridView.sortingDelegate = self;
    _gmGridView.dataSource      = self;

    _gmGridView.mainSuperView   = self.scrollView;
    _gmGridView.selectState     = self.selectState;
}

- (void) loadConfigInfo {
    NSString *pathName          = [FileUtils getPathName:CONFIG_DIRNAME FileName:EDITPAGES_CONFIG_FILENAME];
    NSMutableDictionary *config = [FileUtils readConfigFile:pathName];

    self.slideID                = config[SCAN_SLIDE_ID];
    self.pageName               = config[SCAN_SLIDE_PAGEID];
    self.isFavorite             = ([config[SCAN_SLIDE_FROM] intValue] == SlideTypeFavorite);

    self.slide                  = [Slide findById:self.slideID isFavorite:self.isFavorite];
    self.labelNavSlideTitle.text = self.slide.title;
}

//////////////////////////////////////////////////////////////
#pragma mark - controls action
//////////////////////////////////////////////////////////////
/**
 *  导航栏按钮[返回], 关闭当前文档编辑界面。
 *  读取desc.json.swp写回desc.json, 并物理删除swp文件
 *
 *  bad方法: copy then remove or move; 各种问题
 *  @param gesture UIGestureRecognizer
 */
- (IBAction)actionDismissReViewController:(UIButton *)sender {
    NSMutableDictionary *slideDictSwp = [NSMutableDictionary dictionaryWithDictionary:[self.slide dictSwp]];
    if(![slideDictSwp[SLIDE_DESC_ORDER] isEqualToArray:_dataList]) {
        slideDictSwp[SLIDE_DESC_ORDER] = _dataList;
        [self writeJSON:slideDictSwp Into:[self.slide dictSwpPath]];
    }

    [self performSelector:@selector(dismissReViewController)];
}


- (IBAction)actionSaveTo:(UIButton *)sender {
    if(!self.mainAddNewTagView || !self.mainAddNewTagView.masterViewController) {
        self.mainAddNewTagView = [[MainAddNewTagView alloc] init];
        self.mainAddNewTagView.masterViewController = self;
    }
    self.mainAddNewTagView.closeMainViewAfterDone = NO;
    self.mainAddNewTagView.fromViewControllerName = @"ReViewController";
    [self presentPopupViewController:self.mainAddNewTagView animated:YES completion:^(void) {
        NSLog(@"mainAddNewTagView popup view presented");
    }];
}

- (IBAction)actionRemovePages:(UIButton *)sender {
    if(!self.selectState) return;
    
    for(NSString *pName in _selectedList) { [_dataList removeObject:pName]; }
    [_selectedList removeAllObjects];
    [_gmGridView reloadData];
    
    
    [self actionEdit:self.btnNavEdit];
    [self actionEdit:self.btnNavEdit];
}

- (IBAction)actionRefresh:(id)sender {
    [_gmGridView reloadData];
}

- (IBAction)actionRestore:(UIButton *)sender {
    if(self.selectState) { [self actionEdit:self.btnNavEdit]; }
    
    _dataList = [NSMutableArray arrayWithArray:self.slide.pages];
    [_gmGridView reloadData];
    
    
    [self actionEdit:self.btnNavEdit];
    [self actionEdit:self.btnNavEdit];
}

- (IBAction)actionEdit:(UIButton *)sender {
    [self.btnNavEdit setImage:[UIImage imageNamed:(self.selectState ? @"iconNavEdit2" : @"iconNavCancel")] forState:UIControlStateNormal];

    self.selectState = !self.selectState;
    _gmGridView.selectState = self.selectState;
    [self checkBtnNavState];
}

/**
 *  编辑状态下，选择多个页面后[保存].（自动归档为收藏）
 *  弹出[添加标签]， 选择标签或创建标签，返回标签文件的配置档
 *
 *  并把当前选择的页面拷贝到目标文件ID(FAVORITE_DIRNAME)文件夹下
 *
 *  @param dict 目标文件配置
 */
- (void)actionSavePagesAndMoveFiles:(Slide *)targetSlide {
    for(NSString *pName in _selectedList) {
        // skip when not exist
        if([targetSlide.pages containsObject:pName]) continue;
        // copy page/image
        [FileUtils copyFilePage:pName FromSlide:self.slide ToSlide:targetSlide];
        
        [targetSlide.pages addObject:pName];
    }
    [targetSlide updateTimestamp];
    [targetSlide save];
}


/**
 *  对比desc.json与desc.json.swp是否一致
 *  TODO: 转成NSMutableDirectory对比
 *
 */
- (void)checkDescSwpContent {
    self.btnNavRestore.enabled = ![self.slide.pages isEqualToArray:_dataList];
}


-(void)dismissReViewController {
    [self performSelector:@selector(dismissPopupAddToTag)];
    [self.masterViewController dismissReViewController];
}
- (void) dismissPopupAddToTag {
    if (self.popupViewController) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissPopupAddToTag dismissed");
        }];
    }
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
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.selectingButtonIcon   = [UIImage imageNamed:@"coverSlideSelecting"];
        cell.selectingButtonOffset = CGPointMake(0, 0);
        cell.selectedButtonIcon    = [UIImage imageNamed:@"coverSlideSelected"];
        cell.selectedButtonOffset  = CGPointMake(0, 0);
    }
    
    ViewSlidePage *viewSlidePage = [[[NSBundle mainBundle] loadNibNamed:@"ViewSlidePage" owner:self options:nil] objectAtIndex: 0];
    NSString *currentPageName = [_dataList objectAtIndex:index];

    
    if([currentPageName isEqualToString: self.pageName]) {
        [viewSlidePage hightLight];
    }
    viewSlidePage.labelFrom.text = [NSString stringWithFormat:@"来自: %@", self.slide.title];
    viewSlidePage.labelPageNum.text = [NSString stringWithFormat:@"第%ld页", (long)(index + 1)];
    
    viewSlidePage.slidePageName = currentPageName;
    viewSlidePage.reViewController = self;
    
    NSString *thumbnailPath = [FileUtils slideThumbnail:self.slideID PageID:currentPageName Dir:self.slide.dirName];
    [viewSlidePage loadThumbnail: thumbnailPath];
    // NSLog(@"%ld, %@", (long)index, thumbnailPath);
    
    // enter display view when double click
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionJumpToDisplay:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.delegate = self;
    tapGesture.view.tag = index;
    [viewSlidePage.btnMask setTag:index];
    [viewSlidePage.btnMask addGestureRecognizer:tapGesture];

    [cell setContentView:viewSlidePage];
    if(self.selectState) { [cell setSelected:NO]; }
    
    return cell;
}

/**
 *  非编辑状态下，双击直接进入演示该页面
 *  编辑状态下，会有selectButton在最外层，不会触发此处双击事件
 *  双击后，跳转至播放页面，传递页面名称，而非序号。
 *  写回前，_dataList一直在变，但[self.slide dictSwp][SLIDE_DESC_ORDER]未变,[tapRecognizer.view tag]存放的序号与后者一致
 *
 *  @param gestureRecognizer gestureRecognizer
 */
- (IBAction)actionJumpToDisplay:(UITapGestureRecognizer*)tapRecognizer {
    NSInteger pageIndex = [tapRecognizer.view tag];
    NSMutableDictionary *slideDictSwp = [NSMutableDictionary dictionaryWithDictionary:[self.slide dictSwp]];
    
    NSString *pName                 = slideDictSwp[SLIDE_DESC_ORDER][pageIndex];
    NSString *configPath            = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    configDict[SLIDE_DISPLAY_JUMPTO] = pName;
    [FileUtils writeJSON:configDict Into:configPath];
    
    if(![slideDictSwp[SLIDE_DESC_ORDER] isEqualToArray:_dataList]) {
        slideDictSwp[SLIDE_DESC_ORDER] = _dataList;
        [self writeJSON:slideDictSwp Into:[self.slide dictSwpPath]];
    }

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
    
    GMGridViewCell *cell = [gridView cellForItemAtIndex:index];
    ViewSlidePage *viewSlidePage = (ViewSlidePage *)cell.contentView;

    // 未记录该cell的状态，只能过判断_select是否包含i
    if([_selectedList containsObject:viewSlidePage.slidePageName]) {
        [_selectedList removeObject:viewSlidePage.slidePageName];
    } else {
        [_selectedList addObject:viewSlidePage.slidePageName];
    }
    NSLog(@"click %@, [%@]", viewSlidePage.slidePageName, [_selectedList componentsJoinedByString:@","]);
    
    // 至少选择一个页面，[保存]/[移除]按钮处于激活状态
    [self checkBtnNavState];
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {}

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
    NSString *pName = [_dataList objectAtIndex:oldIndex];
    [_dataList removeObjectAtIndex:oldIndex];
    [_dataList insertObject:pName atIndex:newIndex];
    NSLog(@"----------%ld => %ld------------",(long)oldIndex, (long)newIndex);
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

- (void) checkBtnNavState {
    if(self.selectState) {
        self.btnNavRemove.enabled = ([_selectedList count] > 0);
        self.btnNavSaveTo.enabled = ([_selectedList count] > 0);
    }
    
    self.btnNavRestore.enabled = ![_dataList isEqualToArray:[self.slide dictSwp][SLIDE_DESC_ORDER]];
}

@end

