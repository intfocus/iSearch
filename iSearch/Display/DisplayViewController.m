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

#import "ReViewController.h"
#import "MainViewController.h"

#import "OfflineCell.h"
#import "ViewSlide.h"

#import "const.h"
#import "Slide.h"
#import "message.h"
#import "FileUtils.h"
#import "ExtendNSLogFunctionality.h"

@interface DisplayViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView; // 展示html5
@property (weak, nonatomic) IBOutlet UIButton *btnEditPanelSwitch; // 切换显示编辑状态面板的显示
@property (weak, nonatomic) IBOutlet UIView *viewEditPanelBg;
@property (weak, nonatomic) IBOutlet UIButton *btnColorSwitch;
@property (weak, nonatomic) IBOutlet UIView *viewColorChoice;
@property (weak, nonatomic) IBOutlet UIImageView *iconTriangleImageView;
@property (weak, nonatomic) IBOutlet UIView   *viewEditPanel; // 编辑状态面板
@property (weak, nonatomic) IBOutlet UISwitch *switchLaser;  // 激光笔状态切换
@property (weak, nonatomic) IBOutlet UIButton *btnRedNote;   // 笔记 - 红色
@property (weak, nonatomic) IBOutlet UIButton *btnGreenNote; // 笔记 - 绿色
@property (weak, nonatomic) IBOutlet UIButton *btnBlueNote;  // 笔记 - 蓝色
@property (weak, nonatomic) IBOutlet UIButton *btnClearNote; // 消除笔记

@property (weak, nonatomic) IBOutlet UIButton *btnScanPages; // 浏览
@property (weak, nonatomic) IBOutlet UIButton *btnLastPage;  // 上一页
@property (weak, nonatomic) IBOutlet UIButton *btnNextPage;  // 下一页
@property (weak, nonatomic) IBOutlet UIButton *btnDimiss;    // 关闭
@property (nonatomic, nonatomic) PopupView    *popupView;

@property (nonatomic, strong) NSNumber *currentPageIndex;
@property (nonatomic, nonatomic) BOOL  isFavorite;// 收藏文件、正常下载文件
@property (nonatomic, nonatomic) BOOL  isDrawing; // 作笔记状态
@property (nonatomic, nonatomic) BOOL  isLasering;// 激光笔状态
@property (nonatomic, nonatomic) PaintView  *paintView; // 笔记、激光笔画布
@property (nonatomic, strong) NSString *slideID;
@property (nonatomic, strong) NSString *dirName;
@property (nonatomic, strong) NSString *forbidCss;
@property (nonatomic, nonatomic) ReViewController *reViewController;
@property (nonatomic, strong) Slide *slide;
@property (nonatomic, strong) NSNumber *displayFrom;

@end

@implementation DisplayViewController
@synthesize  paintView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    /**
     *  控件布局、属性
     */
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.viewEditPanel.frame.size.width, self.viewEditPanel.frame.size.height)];
    self.viewEditPanel.layer.masksToBounds = NO;
    self.viewEditPanel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.viewEditPanel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    self.viewEditPanel.layer.shadowOpacity = 0.8;
    self.viewEditPanel.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.viewColorChoice.frame.size.width, self.viewColorChoice.frame.size.height)];
    self.viewColorChoice.layer.masksToBounds = NO;
    self.viewColorChoice.layer.shadowColor = [UIColor blackColor].CGColor;
    self.viewColorChoice.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    self.viewColorChoice.layer.shadowOpacity = 0.8;
    self.viewColorChoice.layer.shadowPath = shadowPath2.CGPath;
    
    UIBezierPath *shadowPath3 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.btnEditPanelSwitch.frame.size.width, self.btnEditPanelSwitch.frame.size.height)];
    self.btnEditPanelSwitch.layer.masksToBounds = NO;
    self.btnEditPanelSwitch.layer.shadowColor = [UIColor blackColor].CGColor;
    self.btnEditPanelSwitch.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    self.btnEditPanelSwitch.layer.shadowOpacity = 0;
    self.btnEditPanelSwitch.layer.shadowPath = shadowPath3.CGPath;
    
    self.viewEditPanel.layer.cornerRadius = 4;
    self.viewColorChoice.layer.cornerRadius = 4;
    self.btnColorSwitch.layer.cornerRadius = 4;
    self.btnBlueNote.layer.cornerRadius = 4;
    self.btnRedNote.layer.cornerRadius = 4;
    self.btnGreenNote.layer.cornerRadius = 4;
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
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(lastPage:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.webView addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextPage:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.webView addGestureRecognizer:gestureLeft];
    // webView按手势放大或缩小
    self.webView.scalesPageToFit = YES;
    
    
    // 作笔记的入口，可切换笔记颜色
    [self.btnRedNote setBackgroundColor:[UIColor redColor]];
    [self.btnRedNote addTarget:self action:@selector(noteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnGreenNote setBackgroundColor:[UIColor greenColor]];
    [self.btnGreenNote addTarget:self action:@selector(noteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnBlueNote setBackgroundColor:[UIColor blueColor]];
    [self.btnBlueNote addTarget:self action:@selector(noteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnClearNote addTarget:self action:@selector(actionClearNote:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnLastPage addTarget:self action:@selector(lastPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnNextPage addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnScanPages addTarget:self action:@selector(actionScanSlide:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnDimiss addTarget:self action:@selector(actionDismiss:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.currentPageIndex = [NSNumber numberWithInt:0];
    self.isDrawing        = NO;
    self.isLasering       = NO;
    self.paintView        = nil;
    self.viewEditPanel.layer.zPosition = MAXFLOAT;
    //[self.editPanel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self stopNote];
    [self.switchLaser setOn:NO];
    
    [self loadSlideInfo];
    [self checkLastNextPageBtnState];
    [self loadHtml];
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"see you later.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - webview 
//开始加载数据
- (void)webViewDidStartLoad:(UIWebView *)webView {
//    [activityIndicator startAnimating];
    NSLog(@"start.");
}

//数据加载完
- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [activityIndicator stopAnimating];
//    UIView *view = (UIView *)[self.view viewWithTag:103];
    //    [view removeFromSuperview];
    NSLog(@"finish.");
}

/**
 *  控件事件
 */
- (void) loadHtml {
    if([self.currentPageIndex integerValue] > [self.slide.pages count]-1) {
        self.currentPageIndex = [NSNumber numberWithInteger:0];
        NSLog(@"Bug: DisplayViewController set Jumpto %@", self.currentPageIndex);
    }
    NSString *htmlName = [self.slide.pages objectAtIndex: [self.currentPageIndex intValue]];
    
    NSString *filePath;
    BOOL isHTML = YES;
    for(NSString *format in @[@"pdf", @"gif", @"mp4"]) {
        filePath = [NSString stringWithFormat:@"%@/%@/%@.%@", self.slide.path, htmlName, htmlName, format];
        if([FileUtils checkFileExist:filePath isDir:NO]) {
            isHTML = NO; break;
        }
    }
    if(isHTML) {
        filePath = [NSString stringWithFormat:@"%@/%@.%@", self.slide.path, htmlName, PAGE_HTML_FORMAT];
        NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSString *basePath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSURL *baseURL = [NSURL fileURLWithPath:basePath];
        [self.webView loadHTMLString:htmlString baseURL:baseURL];
    } else {
        NSLog(@"isHTML:%@, %@", (isHTML ? @"true" : @"false"), filePath);
        NSURL *targetURL = [NSURL fileURLWithPath:filePath];
        NSLog(@"isHTML:%@, %@", (isHTML ? @"true" : @"false"), filePath);
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [self.webView loadRequest:request];
    }
}

- (void) showPopupView: (NSString*) text {
    if(self.popupView == nil) {
        self.popupView = [[PopupView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/4, self.view.frame.size.width/2, self.view.frame.size.height/2)];
        
        self.popupView.ParentView = self.view;
    }
    
    [self.popupView setText: text];
    [self.view addSubview:self.popupView];
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
 *  激光笔状态切换控件，回调函数。
 *
 *  @param sender UISwitch
 */
- (void)actionChangeLaserSwitch:(id)sender{
    if([sender isOn]){
        [self stopNote];
        [self startLaser];
    } else {
        [self stopLaser];
    }
}

/**
 *  启用激光笔；激光笔与作笔记互斥；
 *  **重点** 编辑面板及其控制按钮在激光笔或作笔记状态下放置最顶层，否则无法设置当前编辑状态。
 */
- (void) startLaser {
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
- (void) stopLaser {
    if(self.isLasering) {
        [self.paintView removeFromSuperview];
        self.isLasering = !self.isLasering;
    }
}

/**
 *  激活作笔记
 */
- (void) startNote {
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


// 笔记颜色
-(void)noteBtnClick:(UIButton*) sender{
    // 关闭switch控件，并触发自身函数
    [self.switchLaser setOn:NO];
    [self stopLaser];
    [self startNote];
    self.paintView.paintColor = sender.backgroundColor;
    self.btnColorSwitch.backgroundColor = sender.backgroundColor;
    
    [self.view sendSubviewToBack:self.viewColorChoice];
    self.viewColorChoice.hidden = YES;
    
}

/**
 *  停用作笔记
 */
- (void) stopNote {
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
- (IBAction)nextPage: (id)sender {
    [self stopLaser];
    [self stopNote];
    
    NSInteger pageCount = [self.slide.pages count];
    if([self.currentPageIndex intValue] < pageCount -1) {
        NSInteger index = ([self.currentPageIndex intValue] + 1) % pageCount;
        self.currentPageIndex = [NSNumber numberWithInteger:index];
        [self loadHtml];
    }
    [self checkLastNextPageBtnState];
}

/**
 *  浏览文档时[上一页], 触发手势: 向右滑动
 *
 *  @param sender UIButton
 */
- (IBAction)lastPage: (id)sender {
    [self stopLaser];
    [self stopNote];
    
    NSInteger pageCount = [self.slide.pages count];
    if([self.currentPageIndex intValue] != 0) {
        NSInteger index =  ([self.currentPageIndex intValue]- 1 + pageCount) % pageCount;
        self.currentPageIndex = [NSNumber numberWithInteger:index];
        [self loadHtml];
    }
    [self checkLastNextPageBtnState];
}


- (IBAction)drawing:(id)sender {
    [self toggleDrawing];
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
    if([FileUtils checkSlideExist:self.slideID Dir:self.dirName Force:YES]) {
        // 界面跳转需要传递fileID，通过写入配置文件来实现交互
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:EDITPAGES_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        
        NSString *pageID = [self.slide.pages objectAtIndex:[self.currentPageIndex integerValue]];
        [config setObject:self.slideID forKey:SCAN_SLIDE_ID];
        [config setObject:pageID forKey:SCAN_SLIDE_PAGEID];
        NSNumber *slideType = [NSNumber numberWithInt:(self.isFavorite ? SlideTypeFavorite : SlideTypeSlide)];
        [config setObject:slideType forKey:SCAN_SLIDE_FROM];
        [FileUtils writeJSON:config Into:pathName];
        
        // 界面跳转至文档页面编辑界面
        if(self.reViewController == nil) {
            self.reViewController = [[ReViewController alloc] init];
        }
        [self presentViewController:self.reViewController animated:NO completion:nil];
    }
}

// 做笔记
- (void)toggleDrawing {
    if(!self.isDrawing) {
        self.paintView = [[PaintView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.paintView.backgroundColor = [UIColor whiteColor];
        self.paintView.alpha = 0.3;
        self.paintView.erase = false;
        self.paintView.laser = false;
        [self.view addSubview:self.paintView];
        self.isDrawing = true;
    } else {
        [self.paintView removeFromSuperview];
        self.isDrawing = false;
        
    }
}

/**
 *  关闭演示界面；
 *  内存管理: 谁开启，谁负责；
 *
 *  @param sender
 */
- (IBAction)actionDismiss:(id)sender {
    if([self.displayFrom intValue] == DisplayFromOfflineCell) {
        if(self.callingController1 != nil) {
            [self.callingController1 dismissDisplayViewController];
        } else {
            NSLog(@"Bug#not set DisplayViewController#callingController1");
        }
    }
    if([self.displayFrom intValue] == DisplayFromSlide) {
        if(self.callingController2 != nil) {
            [self.callingController2 dismissDisplayViewController];
        } else {
            NSLog(@"Bug#not set DisplayViewController#callingController2");
        }
    }
    self.webView = nil;
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)colorButtonTouched:(UIButton *)sender {
    self.viewColorChoice.hidden = !self.viewColorChoice.hidden;
    self.iconTriangleImageView.hidden = !self.iconTriangleImageView.hidden;
    if(!self.viewColorChoice.hidden) {
        [self.view bringSubviewToFront:self.viewColorChoice];
    }
}


#pragma mark - assistant methods

- (void) checkLastNextPageBtnState {
    [self enabledLastNextPageBtn:self.btnLastPage Enabeld:([self.currentPageIndex intValue] != 0)];
    [self enabledLastNextPageBtn:self.btnNextPage Enabeld:([self.currentPageIndex intValue] != [self.slide.pages count]-1)];
}
- (void) enabledLastNextPageBtn:(UIButton *)sender
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
- (void) loadSlideInfo {
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    
    // Basic Key Check
    if(!configDict[CONTENT_KEY_DISPLAYID]) {
        NSLog(@"CONTENT_CONFIG_FILENAME#CONTENT_KEY_DISPLAYID Not Set!");
        abort();
    }
    if(!configDict[SLIDE_DISPLAY_TYPE]) {
        NSLog(@"CONTENT_CONFIG_FILENAME#SLIDE_DISPLAY_TYPE Not Set!");
        abort();
    }
    self.isFavorite = ([configDict[SLIDE_DISPLAY_TYPE] intValue] == SlideTypeFavorite);
    self.slideID = configDict[CONTENT_KEY_DISPLAYID];
    self.dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    
    if([self.slideID length] == 0) {
        NSLog(@"CONTENT_CONFIG_FILENAME#CONTENT_KEY_DISPLAYID Is Empty!");
        abort();
    }
    self.displayFrom = configDict[SLIDE_DISPLAY_FROM];
    NSString *dictPath = [FileUtils slideDescPath:self.slideID Dir:self.dirName Klass:SLIDE_DICT_FILENAME];
    NSMutableDictionary *dict = [FileUtils readConfigFile:dictPath];
    
    self.slide = [[Slide alloc] initSlide:dict isFavorite:self.isFavorite];
    NSString *pageNum = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:[self.slide.pages count]]];
    if(self.slide.pages == nil || ![pageNum isEqualToString:self.slide.pageNum]) {
        NSLog(@"Bug: Slide#Pages is nil or pageNum not match");
    }
    
    NSString *jumpToPageIndex = configDict[SLIDE_DISPLAY_JUMPTO];
    if(jumpToPageIndex) {
        NSInteger jumpToIndex = [jumpToPageIndex integerValue];
        if( jumpToIndex < 0 || jumpToIndex > [self.slide.pages count] -1) {
            jumpToIndex = 0;
        }
        self.currentPageIndex = [NSNumber numberWithInteger:jumpToIndex];
    } else {
        self.currentPageIndex = [NSNumber numberWithInteger:0];
    }
}

@end
