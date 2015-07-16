//
//  ViewController.m
//  WebView-1
//
//  Created by lijunjie on 15-4-1.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "DisplayViewController.h"
#import "SSZipArchive.h"
#import <JavaScriptCore/JavaScriptCore.h>

#import "MainViewController.h"

#import "OfflineCell.h"
#import "ViewSlide.h"
#import "MainViewController.h"
#import "MainAddNewTagView.h"
#import "ReViewController.h"

#import "const.h"
#import "Slide.h"
#import "message.h"
#import "FileUtils.h"
#import "FileUtils+Slide.h"
#import "ActionLog.h"
#import "MBProgressHUD.h"
#import "ExtendNSLogFunctionality.h"
#import "UIViewController+CWPopup.h"

@interface DisplayViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView; // 演示pdf/视频/html
@property (weak, nonatomic) IBOutlet UIView *viewEditPanelBg;
@property (weak, nonatomic) IBOutlet UIView *viewColorChoice; // 作笔记，选择颜色
@property (weak, nonatomic) IBOutlet UIView *viewAutoPlay;    // 自动播放状态
@property (weak, nonatomic) IBOutlet UIView *viewEditPanel;   // 编辑状态面板
@property (weak, nonatomic) IBOutlet UIImageView *iconTriangleImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoPlaySwitch;
@property (weak, nonatomic) IBOutlet UIButton *btnColorSwitch; // 作笔记颜色选择面板的显示状态
@property (weak, nonatomic) IBOutlet UIButton *btnEditPanelSwitch; // 编辑面板的显示状态
@property (weak, nonatomic) IBOutlet UIButton *btnRedNote;   // 笔记 - 红色
@property (weak, nonatomic) IBOutlet UIButton *btnGreenNote; // 笔记 - 绿色
@property (weak, nonatomic) IBOutlet UIButton *btnBlueNote;  // 笔记 - 蓝色
@property (weak, nonatomic) IBOutlet UIButton *btnClearNote; // 消除笔记

@property (weak, nonatomic) IBOutlet UISwitch *switchLaser;  // 激光笔状态切换
@property (weak, nonatomic) IBOutlet UISwitch *switchAutoPlay; // 自动播放状态
@property (weak, nonatomic) IBOutlet UISwitch *switchLoopPlay; // 循环播放状态
@property (weak, nonatomic) IBOutlet UILabel *labelAutoPlayInterval; // 自动播放间隔

@property (weak, nonatomic) IBOutlet UIButton *btnScanPages; // 浏览
@property (weak, nonatomic) IBOutlet UIButton *btnLastPage;  // 上一页
@property (weak, nonatomic) IBOutlet UIButton *btnNextPage;  // 下一页
@property (weak, nonatomic) IBOutlet UIButton *btnDimiss;    // 关闭
@property (weak, nonatomic) IBOutlet UISlider *sliderAutoPlayInterval; // 浏览
@property (strong, nonatomic)  NSTimer *timerAutoPlay;

@property (nonatomic, nonatomic) BOOL  isFavorite; // 收藏文件、正常下载文件
@property (nonatomic, nonatomic) BOOL  isDrawing;  // 作笔记状态
@property (nonatomic, nonatomic) BOOL  isLasering; // 激光笔状态
@property (nonatomic, nonatomic) BOOL  isAutoPlay; // 自动播放状态
@property (nonatomic, nonatomic) BOOL  isLoopPlay; // 自动播放状态,无限循环播放
@property (nonatomic, nonatomic) NSTimeInterval  timeIntervalAutoPlay;// 自动播放状态,间隔时间
@property (nonatomic, strong) NSString *slideID;
@property (nonatomic, strong) NSString *dirName;
@property (nonatomic, strong) NSString *forbidCss;
@property (nonatomic, strong) NSNumber *displayFrom;
@property (nonatomic, strong) NSNumber *currentPageIndex;
@property (nonatomic, strong) Slide *slide;
@property (nonatomic, nonatomic) PaintView  *paintView; // 笔记、激光笔画布

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, nonatomic) MainAddNewTagView *mainAddNewTagView;
@property (nonatomic, nonatomic) ReViewController *reViewController;

@end

@implementation DisplayViewController
@synthesize  paintView;

- (void)viewDidLoad {
    [super viewDidLoad];

    // 作笔记的入口，可切换笔记颜色
    [self.btnRedNote setBackgroundColor:[UIColor redColor]];
    [self.btnGreenNote setBackgroundColor:[UIColor greenColor]];
    [self.btnBlueNote setBackgroundColor:[UIColor blueColor]];
    
    /**
     *  控件布局、属性
     */
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.viewEditPanel.frame.size.width, self.viewEditPanel.frame.size.height)];
    self.viewEditPanel.layer.masksToBounds = NO;
    self.viewEditPanel.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.viewEditPanel.layer.shadowOffset  = CGSizeMake(0.5f, 0.5f);
    self.viewEditPanel.layer.shadowOpacity = 0.8;
    self.viewEditPanel.layer.shadowPath    = shadowPath.CGPath;
    
    UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.viewColorChoice.frame.size.width, self.viewColorChoice.frame.size.height)];
    self.viewColorChoice.layer.masksToBounds = NO;
    self.viewColorChoice.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.viewColorChoice.layer.shadowOffset  = CGSizeMake(0.5f, 0.5f);
    self.viewColorChoice.layer.shadowOpacity = 0.8;
    self.viewColorChoice.layer.shadowPath    = shadowPath2.CGPath;
    
    UIBezierPath *shadowPath3 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.btnEditPanelSwitch.frame.size.width, self.btnEditPanelSwitch.frame.size.height)];
    self.btnEditPanelSwitch.layer.masksToBounds = NO;
    self.btnEditPanelSwitch.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.btnEditPanelSwitch.layer.shadowOffset  = CGSizeMake(0.5f, 0.5f);
    self.btnEditPanelSwitch.layer.shadowOpacity = 0;
    self.btnEditPanelSwitch.layer.shadowPath    = shadowPath3.CGPath;
    
    self.viewEditPanel.layer.cornerRadius   = 4;
    self.viewColorChoice.layer.cornerRadius = 4;
    self.btnColorSwitch.layer.cornerRadius  = 4;
    self.btnBlueNote.layer.cornerRadius     = 4;
    self.btnRedNote.layer.cornerRadius      = 4;
    self.btnGreenNote.layer.cornerRadius    = 4;
    [self.viewEditPanel setHidden: true];
    
    /**
     *  控件事件
     */
    [self.btnEditPanelSwitch setTag:SlideEditPanelShow]; // 当前状态是hidden，再点击就是Show操作
    [self.btnEditPanelSwitch addTarget:self action:@selector(actionToggleShowEditPanel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.switchLaser setOn: false];
    [self.switchLaser addTarget:self action:@selector(actionChangeLaserSwitch:) forControlEvents:UIControlEventValueChanged];
    
    self.forbidCss = @"<style type='text/css'>          \
                        body { background: black; }     \
                        * {                             \
                        -webkit-touch-callout: none;    \
                        -webkit-user-select: none;      \
                        }                               \
                        </style>                        \
                        </head>";
    
    /**
     * webView添加手势，向左即上一页，向右即下一页
     */
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionLastPage:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.webView addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionNextPage:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.webView addGestureRecognizer:gestureLeft];
    // webView按手势放大或缩小
    self.webView.scalesPageToFit = YES;
    //self.webView.userInteractionEnabled = NO;
    
    self.dataList                      = [[NSMutableArray alloc] init];
    self.currentPageIndex              = [NSNumber numberWithInt:0];
    self.isDrawing                     = NO;
    self.isLasering                    = NO;
    self.paintView                     = nil;
    self.viewEditPanel.layer.zPosition = MAXFLOAT;

    // 默认循环播放
    self.isLoopPlay        = YES;
    self.switchLoopPlay.on = YES;
    [self.switchLoopPlay addTarget:self action:@selector(actionChangeSwithLoopPlay:) forControlEvents:UIControlEventValueChanged];
    
    self.isAutoPlay        = NO;
    self.switchAutoPlay.on = NO;
    [self.switchAutoPlay addTarget:self action:@selector(actionChangeSwithAutoPlay:) forControlEvents:UIControlEventValueChanged];
    
    self.timeIntervalAutoPlay         = 10.0;
    self.sliderAutoPlayInterval.value = 10.0;
    self.sliderAutoPlayInterval.enabled = NO;
    [self.sliderAutoPlayInterval addTarget:self action:@selector(actionChangeSlideAutoPlayInterval:) forControlEvents:UIControlEventValueChanged];
    
    self.iconTriangleImageView.hidden = YES;
    self.viewColorChoice.hidden       = YES;
    self.viewAutoPlay.hidden          = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view, typically from a nib.
    
    /**
     *  CWPopup 事件
     */
    self.useBlurForPopup = YES;
    
    if(self.hud) { [self.hud removeFromSuperview]; }
    
    [self loadSlideInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self stopNote];
    [self.switchLaser setOn:NO];
    
    [self checkLastNextPageBtnState];
    if([self.dataList count] > 0) {
        [self loadHtml];
    } else {
        [self.webView loadHTMLString:@" \
         <html>                         \
           <body>                       \
             <div style = 'position:fixed;left:40%;top:40%;font-size:20px;'> \
             文档内容为空.                \
             </div>                     \
           </body>                      \
         </html>" baseURL:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSString *html = [NSString stringWithFormat:@"<html><body></body></html>"];
    [self.webView loadHTMLString:html baseURL:nil];
    
    if(self.hud) { [self.hud removeFromSuperview]; }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.slide     = nil;
    self.webView   = nil;
    self.dataList  = nil;
    self.paintView = nil;
}

/**
 *  控件事件
 */
- (void) loadHtml {
    if([self.currentPageIndex integerValue] > [self.dataList count]-1) {
        self.currentPageIndex = [NSNumber numberWithInteger:0];
        NSLog(@"Bug: DisplayViewController set Jumpto %@", self.currentPageIndex);
    }
    NSString *pageName = [self.dataList objectAtIndex: [self.currentPageIndex intValue]];
    
    NSString *filePath;
    BOOL isHTML = YES;
    for(NSString *format in @[@"pdf", @"mp4", @"gif"]) {
        filePath = [NSString stringWithFormat:@"%@/%@/%@.%@", self.slide.path, pageName, pageName, format];
        if([FileUtils checkFileExist:filePath isDir:NO]) {
            isHTML = NO; break;
        }
    }
    if(isHTML) {
        filePath = [NSString stringWithFormat:@"%@/%@.%@", self.slide.path, pageName, PAGE_HTML_FORMAT];
        NSString *htmlString;
        if([FileUtils checkFileExist:filePath isDir:NO]) {
            htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            [htmlString stringByReplacingOccurrencesOfString:@"</head>" withString:self.forbidCss];
        } else {
            htmlString = @" \
            <html>                         \
              <body>                       \
                <div style = 'position:fixed;left:40%;top:40%;font-size:20px;'> \
                  该页面为空.                \
                </div>                     \
              </body>                      \
            </html>";
        }
        NSURL *baseURL = [NSURL fileURLWithPath:self.slide.path];
        [self.webView loadHTMLString:htmlString baseURL:baseURL];
    } else {
        NSURL *targetURL = [NSURL fileURLWithPath:filePath];
        // NSLog(@"isHTML:%@, %@", (isHTML ? @"true" : @"false"), filePath);
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [self.webView loadRequest:request];
    }
}

#pragma mark - MBProgressHUD methods
- (MBProgressHUD *)showPopupView:(NSString *)text {
    return [self showPopupView:text Delay:1.0];
}
- (MBProgressHUD *)showPopupView:(NSString *)text Delay:(NSTimeInterval)delay {
    return [self showPopupView:text Mode:MBProgressHUDModeText Delay:delay];
}
- (MBProgressHUD *)showPopupView:(NSString *)text Mode:(NSInteger)mode Delay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode                      = mode;
    hud.labelText                 = text;
    hud.margin                    = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    if(delay > 0.0) { [hud hide:YES afterDelay:delay]; }
    return hud;
}

/**
 *  编辑面板功能代码
 */

/**
 *  编辑按钮, 回调函数 - 编辑面板切换显示、隐藏
 *  编辑按钮的tag值，指示当前状态: 0 隐藏编辑面板(默认值), 1 显示编辑面板
 *
 *  @param sender UIButton
 */
- (IBAction)actionToggleShowEditPanel:(UIButton *)sender {
    NSInteger tag = [sender tag];
    [UIView animateWithDuration:.5f animations:^{
        [self.viewEditPanel setHidden:(tag != SlideEditPanelShow)];
    }];
    
    switch(tag) {
        case SlideEditPanelHiden: {
            [self.btnEditPanelSwitch setTag:SlideEditPanelShow];
            [self.btnEditPanelSwitch setBackgroundImage:[UIImage imageNamed:@"iconPen"] forState:UIControlStateNormal];
            self.viewEditPanelBg.hidden = YES;
            self.viewColorChoice.hidden = YES;
            self.btnEditPanelSwitch.layer.shadowOpacity = 0;
            [self stopLaser];
            [self stopNote];
        }
            break;
            
        case SlideEditPanelShow: {
            [self.btnEditPanelSwitch setTag:SlideEditPanelHiden];
            [self.btnEditPanelSwitch setBackgroundImage:[UIImage imageNamed:@"iconPenBack"] forState:UIControlStateNormal];
            self.viewEditPanelBg.hidden = NO;
            self.btnEditPanelSwitch.layer.shadowOpacity = 0.5;
            
        }
            break;
        default:
            break;
    }
}
/**
 *  激光笔状态控件
 *
 *  @param sender UISwitch
 */
- (void)actionChangeLaserSwitch:(UISwitch *)sender{
    if([sender isOn]){
        [self stopNote];
        [self startLaser];
    } else {
        [self stopLaser];
    }
}
/**
 *  自动播放状态控件
 *
 *  @param sender UISwitch
 */
- (void)actionChangeSwithAutoPlay:(UISwitch *)sender {
    self.sliderAutoPlayInterval.enabled = [sender isOn];
    self.isAutoPlay                     = [sender isOn];
    
    if([sender isOn]) {
        if(!self.timerAutoPlay || ![self.timerAutoPlay isValid]) {
            self.timerAutoPlay = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalAutoPlay target:self selector:@selector(actionAutoPlayer) userInfo:nil repeats:YES];
        }
        [self.timerAutoPlay fire];
    } else {
        if(self.timerAutoPlay) {
            [self.timerAutoPlay invalidate];
        }
    }
}
/**
 *  循环播放状态控件
 *
 *  @param sender UISwitch
 */
- (void)actionChangeSwithLoopPlay:(UISwitch *)sender {
    self.isLoopPlay = [sender isOn];
    [self checkLastNextPageBtnState];
}

/**
 *  自动播放状态，设置间隔时间回调函数
 *
 *  @param sender UISlider
 */
- (void)actionChangeSlideAutoPlayInterval:(UISlider *)sender {
    self.timeIntervalAutoPlay       = sender.value;
    self.labelAutoPlayInterval.text = [NSString stringWithFormat:@"间隔 %i 秒", (int)sender.value];
    
    // refire timer
    if(self.timerAutoPlay) {
        [self.timerAutoPlay invalidate];
    }
    self.timerAutoPlay = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalAutoPlay target:self selector:@selector(actionAutoPlayer) userInfo:nil repeats:YES];
    [self.timerAutoPlay fire];
}

/**
 *  自动播放状态，定时器执行操作
 */
- (void)actionAutoPlayer {
    if(!self.isAutoPlay) { return; }
    
    if(self.isLoopPlay ||
      (!self.isLoopPlay && [self.currentPageIndex intValue] < [self.dataList count]-1)) {
        [self performSelector:@selector(actionNextPage:) withObject:self.btnNextPage afterDelay:self.timeIntervalAutoPlay];
    }
}

/**
 *  启用激光笔；激光笔与作笔记互斥；
 *  **重点** 编辑面板及其控制按钮在激光笔或作笔记状态下放置最顶层，否则无法设置当前编辑状态。
 */
- (void)startLaser {
    if(!self.isLasering) {
        self.paintView = [[PaintView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-30)];
        self.paintView.backgroundColor = [UIColor clearColor];
        self.paintView.paintColor = [UIColor blackColor];
        self.paintView.alpha = 0.6;
        self.paintView.laser = true;
        self.paintView.erase = false;
        [self.view addSubview:self.paintView];
        self.isLasering = !self.isLasering;
    }
    
    [self.view sendSubviewToBack:self.viewColorChoice];
    self.viewColorChoice.hidden = YES;
    [self.view bringSubviewToFront:self.viewEditPanel];
    [self.view bringSubviewToFront:self.btnEditPanelSwitch];
}
/**
 *  停用激光笔；
 */
- (void)stopLaser {
    if(self.isLasering) {
        [self.paintView removeFromSuperview];
        self.isLasering = !self.isLasering;
    }
}

/**
 *  激活作笔记
 */
- (void)startNote {
    if(!self.isDrawing) {
        self.paintView = [[PaintView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.paintView.backgroundColor = [UIColor clearColor];
        self.paintView.alpha = 0.6;
        self.paintView.erase = false;
        self.paintView.laser = false;
        [self.view addSubview:self.paintView];
        self.isDrawing = !self.isDrawing;
        
        [self.view bringSubviewToFront:self.viewEditPanel];
        [self.view bringSubviewToFront:self.btnEditPanelSwitch];
    }
    self.btnClearNote.enabled = YES;
}

/**
 *  控制颜色选择面板显示状态
 *
 *  @param sender UIButton
 */
- (IBAction)actionToggleShowViewColorChoice:(UIButton *)sender {
    self.viewColorChoice.hidden       = !self.viewColorChoice.hidden;
    self.iconTriangleImageView.hidden = !self.iconTriangleImageView.hidden;
    if(!self.viewColorChoice.hidden) {
        [self.view bringSubviewToFront:self.iconTriangleImageView];
        [self.view bringSubviewToFront:self.viewColorChoice];
    }
}
/**
 *  颜色选择面板，选择颜色，进入作笔记状态
 *
 *  @param IBAction UIButton
 *
 *  @return void
 */
-(IBAction)actionColorChoice:(UIButton*)sender{
    // 关闭switch控件，并触发自身函数
    [self.switchLaser setOn:NO];
    [self stopLaser];
    [self startNote];
    self.paintView.paintColor           = sender.backgroundColor;
    self.btnColorSwitch.backgroundColor = sender.backgroundColor;
    
    [self.view sendSubviewToBack:self.viewColorChoice];
    self.viewColorChoice.hidden = YES;
}

/**
 *  停用作笔记
 */
- (void)stopNote {
    if(self.isDrawing) {
        [self.paintView removeFromSuperview];
        self.isDrawing = !self.isDrawing;
        self.btnColorSwitch.backgroundColor = [UIColor whiteColor];
    }
    self.btnClearNote.enabled = NO;
}

- (IBAction)actionClearNote:(id)sender {
    if(self.isDrawing) {
        [self.paintView clearDrawRect];
        [self.paintView setNeedsDisplay];
    }
}

/**
 *  浏览文档时[下一页], 触发手势: 向左滑动
 *
 *  @param sender UIButton
 */
- (IBAction)actionNextPage: (id)sender {
    [self stopNote];
    
    NSInteger pageCount = [self.dataList count];
    if(!self.isLoopPlay && [self.currentPageIndex intValue] == pageCount - 1) {
        //[self showPopupView:@"最后一页了"];
        [self checkLastNextPageBtnState];
        return;
    }
    
    NSInteger index = ([self.currentPageIndex intValue] + 1) % pageCount;
    self.currentPageIndex = [NSNumber numberWithInteger:index];
    [self loadHtml];
    
    if([self.currentPageIndex intValue] == 0) {
        [self showPopupView:@"进入第一页了"];
    }
    [self checkLastNextPageBtnState];
}

/**
 *  浏览文档时[上一页], 触发手势: 向右滑动
 *
 *  @param sender UIButton
 */
- (IBAction)actionLastPage: (id)sender {
    [self stopNote];
    
    NSInteger pageCount   = [self.dataList count];
    if(!self.isLoopPlay && [self.currentPageIndex intValue] == 0) {
        //[self showPopupView:@"第一页了"];
        [self checkLastNextPageBtnState];
        return;
    }
    
    NSInteger index       = ([self.currentPageIndex intValue]- 1 + pageCount) % pageCount;
    self.currentPageIndex = [NSNumber numberWithInteger:index];
    [self loadHtml];
    
    if([self.currentPageIndex intValue] == pageCount - 1) {
        [self showPopupView:@"进入最后一页了"];
    }
    [self checkLastNextPageBtnState];
}


/**
 *  只有文档已经下载; 文档演示过程中，可以直接进入编辑文档页面界面；
 *  当前演示页，应该在编辑文档页面界面高亮。
 *  如果已经存在desc.json.swp说明上次crash了，不需要再拷贝
 *  在编辑文档页面时
 *      情况一: 把当前演示页给移除了，则跳至第一页。
 *      情况二；把当前演示页调换顺序，则跳至对应位置
 *
 *  @param sender 无返回
 */
- (IBAction)actionScanSlide:(id)sender {
    // 如果文档已经下载，可以查看文档内部详细信息，
    // 否则需要下载，该功能在FileSlide内部处理
    if(![FileUtils checkSlideExist:self.slideID Dir:self.dirName Force:YES])
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hud = [self showPopupView:@"加载中..." Mode:MBProgressHUDModeIndeterminate Delay:0];
        });
        
        // 界面跳转需要传递slideID，通过写入配置文件来实现交互
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:EDITPAGES_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        
        NSString *currentPageName = ([self.dataList count] > [self.currentPageIndex integerValue]) ? self.dataList[[self.currentPageIndex integerValue]] : @"empty slide's pages";
        config[SCAN_SLIDE_ID]     = self.slideID;
        config[SCAN_SLIDE_PAGEID] = currentPageName;
        config[SCAN_SLIDE_FROM]   = [NSNumber numberWithInt:(self.isFavorite ? SlideTypeFavorite : SlideTypeSlide)];
        [FileUtils writeJSON:config Into:pathName];
        
        NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
        configDict[SLIDE_DISPLAY_JUMPTO] = currentPageName;
        [FileUtils writeJSON:configDict Into:configPath];
        
        // 界面跳转至文档页面编辑界面
        if(!self.reViewController) {
            self.reViewController = [[ReViewController alloc] init];
            self.reViewController.masterViewController = self;
        }
        [self presentViewController:self.reViewController animated:NO completion:nil];
        
    });
}

- (IBAction)actionToggleShowViewAutoPlay:(UIButton *)sender {
    self.viewAutoPlay.hidden = !self.viewAutoPlay.hidden;
    if(!self.viewAutoPlay.hidden) {
        [self.view bringSubviewToFront:self.viewAutoPlay];
    }
}

//// 做笔记
//- (void)toggleDrawing {
//    if(!self.isDrawing) {
//        self.paintView = [[PaintView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//        self.paintView.backgroundColor = [UIColor whiteColor];
//        self.paintView.alpha = 0.3;
//        self.paintView.erase = false;
//        self.paintView.laser = false;
//        [self.view addSubview:self.paintView];
//        self.isDrawing = true;
//    } else {
//        [self.paintView removeFromSuperview];
//        self.isDrawing = false;
//        
//    }
//}

/**
 *  关闭演示界面；
 *  内存管理: 谁开启，谁负责；
 *
 *  @param sender
 */
- (IBAction)actionDismissDisplayViewController:(id)sender {
    if(self.slide.isFavorite) {
        [self dismissDisplayViewController];
    } else {
        if(![self.dataList isEqualToArray:self.slide.pages]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"文档页面有调整，是否保存？" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"保存",nil];
            [alert show];
        } else {
            [self dismissDisplayViewController];
        }
    }
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    configDict[SLIDE_DISPLAY_JUMPTO] = [NSNumber numberWithInteger:0];
    [FileUtils writeJSON:configDict Into:configPath];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [self dismissDisplayViewController];
        }
            break;
        case 1: {
            if(!self.mainAddNewTagView || !self.mainAddNewTagView.masterViewController) {
                self.mainAddNewTagView = [[MainAddNewTagView alloc] init];
                self.mainAddNewTagView.masterViewController = self;
            }
            self.mainAddNewTagView.closeMainViewAfterDone = YES;
            self.mainAddNewTagView.fromViewControllerName = @"DisplayViewController";
            [self presentPopupViewController:self.mainAddNewTagView animated:YES completion:^(void) {
                NSLog(@"mainAddNewTagView popup view presented");
            }];
        }
            break;
        default:
            break;
    }
}


#pragma mark - assistant methods

- (void)checkLastNextPageBtnState {
    if(self.isLoopPlay) {
        [self enabledLastNextPageBtn:self.btnLastPage Enabeld:YES];
        [self enabledLastNextPageBtn:self.btnNextPage Enabeld:YES];
    } else {
        [self enabledLastNextPageBtn:self.btnLastPage Enabeld:([self.currentPageIndex intValue] != 0)];
        [self enabledLastNextPageBtn:self.btnNextPage Enabeld:([self.currentPageIndex intValue] != [self.dataList count]-1)];
    }
}
- (void)enabledLastNextPageBtn:(UIButton *)sender
                       Enabeld:(BOOL)enabled {
    if(enabled == sender.enabled) return;
    
    sender.enabled = enabled;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:sender.titleLabel.text];
    NSRange strRange = {0,[str length]};
    if(enabled) {
        [str removeAttribute:NSStrikethroughStyleAttributeName range:strRange];
        
    } else {
        [str addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    }
    [sender setAttributedTitle:str forState:UIControlStateNormal];
}

/**
 *  core method
 */
- (void) loadSlideInfo {
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    
    // Basic Key Check
    self.isFavorite = ([configDict[SLIDE_DISPLAY_TYPE] intValue] == SlideTypeFavorite);
    self.slideID = configDict[CONTENT_KEY_DISPLAYID];
    self.dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    
    self.displayFrom = configDict[SLIDE_DISPLAY_FROM];
    NSString *dictPath = [FileUtils slideDescPath:self.slideID Dir:self.dirName Klass:SLIDE_DICT_FILENAME];
    NSMutableDictionary *dict = [FileUtils readConfigFile:dictPath];
    
    self.slide = [[Slide alloc] initSlide:dict isFavorite:self.isFavorite];
    NSString *pageNum = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:[self.slide.pages count]]];
    if(self.slide.pages == nil || ![pageNum isEqualToString:self.slide.pageNum]) {
        NSLog(@"Bug: Slide#Pages is nil or pageNum not match");
    }
    
    if(![FileUtils checkFileExist:[self.slide dictSwpPath] isDir:NO]) {
        [self.slide enterDisplayOrScanState];
    }
    _dataList = [self.slide dictSwp][SLIDE_DESC_ORDER];
    
    // 浏览页面调整页面顺序，播放实时更新
    NSString *jumpToPageName = configDict[SLIDE_DISPLAY_JUMPTO];
    NSInteger jumpToPageIndex = [self.dataList indexOfObject:jumpToPageName];
    if(jumpToPageIndex && (jumpToPageIndex < 0 || jumpToPageIndex > [self.slide.pages count] -1)) {
        jumpToPageIndex = 0;
    }
    self.currentPageIndex = [NSNumber numberWithInteger:jumpToPageIndex];
    
    ActionLog *actionLog = [[ActionLog alloc] init];
    [actionLog recordSlide:self.slide Action:ACTION_DISPLAY];
}


#pragma mark - save slide to favorite
/**
 *  编辑状态下，选择多个页面后[保存].（自动归档为收藏）
 *  弹出[添加标签]， 选择标签或创建标签，返回标签文件的配置档
 *
 *  并把当前选择的页面拷贝到目标文件ID(FAVORITE_DIRNAME)文件夹下
 *
 *  @param dict 目标文件配置
 */
- (void)actionSavePagesAndMoveFiles:(Slide *)targetSlide {
    NSMutableDictionary *dictSwp = [self.slide dictSwp];
    
    for(NSString *pName in dictSwp[SLIDE_DESC_ORDER]) {
        // skip when not exist
        if([targetSlide.pages containsObject:pName]) continue;
        // copy page/image
        [FileUtils copyFilePage:pName FromSlide:self.slide ToSlide:targetSlide];
        
        [targetSlide.pages addObject:pName];
    }
    [targetSlide updateTimestamp];
    [targetSlide save];
}

-(void)dismissDisplayViewController {
    [self performSelector:@selector(dismissPopupAddToTag)];
    
    if(self.slide.isFavorite) {
        self.slide.pages = [self.slide dictSwp][SLIDE_DESC_ORDER];
        [self.slide save];
    }
    [self.slide removeDictSwp];
    [self.masterViewController dismissViewDisplayViewController];
}
- (void) dismissPopupAddToTag {
    if (self.popupViewController) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissPopupAddToTag dismissed");
        }];
    }
}
-(void)dismissReViewController {
    if(self.reViewController) {
        [self.reViewController dismissViewControllerAnimated:NO completion:^{
            _reViewController = nil;
            NSLog(@"dismiss present view ReViewController.");
        }];
    }
}

#pragma mark - present view ReViewController
//- (void)presentViewReViewController {
//    if(!self.reViewController) {
//        self.reViewController = [[ReViewController alloc] init];
//        self.reViewController.masterViewController = self;
//    }
//    [self presentViewController:self.reViewController animated:NO completion:nil];
//}
//- (void)dismissViewReViewController {
//    if(self.reViewController) {
//        [self.reViewController dismissViewControllerAnimated:NO completion:^{
//            _reViewController = nil;
//            NSLog(@"dismiss ReViewController.");
//        }];
//    }
//}
@end
