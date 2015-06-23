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

#import "const.h"
#import "message.h"
#import "FileUtils.h"
#import "ExtendNSLogFunctionality.h"

@interface DisplayViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView; // 展示html5
@property (weak, nonatomic) IBOutlet UIButton *editBtn; // 切换显示编辑状态面板的显示
@property (weak, nonatomic) IBOutlet UIView *editPanelBgView;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIImageView *iconTriangleImageView;
@property (weak, nonatomic) IBOutlet UIView *editPanel; // 编辑状态面板
@property (weak, nonatomic) IBOutlet UIButton *drawBtn;
@property (weak, nonatomic) IBOutlet UISwitch *laserSwitch; // 激光笔状态切换
@property (weak, nonatomic) IBOutlet UIButton *redNoteBtn;  // 笔记 - 红色
@property (weak, nonatomic) IBOutlet UIButton *greenNoteBtn;// 笔记 - 绿色
@property (weak, nonatomic) IBOutlet UIButton *blueNoteBtn; // 笔记 - 蓝色
@property (nonatomic, nonatomic) PopupView      *popupView;

@property (nonatomic, nonatomic) NSNumber *currentPageIndex;
@property (nonatomic, nonatomic) BOOL  isFavorite;// 收藏文件、正常下载文件
@property (nonatomic, nonatomic) BOOL  isDrawing; // 作笔记状态
@property (nonatomic, nonatomic) BOOL  isLasering;// 激光笔状态
@property (nonatomic, nonatomic) PaintView  *paintView; // 笔记、激光笔画布
@property (nonatomic, nonatomic) NSString *slideID;
@property (nonatomic, nonatomic) NSString *filePath;
@property (nonatomic, nonatomic) NSMutableDictionary *fileDesc;
@property (nonatomic, nonatomic) NSString *forbidCss;
@property (nonatomic, nonatomic) ReViewController *reViewController;

@end

@implementation DisplayViewController
@synthesize  paintView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadConfigInfo];
    
    self.currentPageIndex    = [NSNumber numberWithInt:0];
    self.isDrawing           = false;
    self.paintView           = nil;
    self.editPanel.layer.zPosition = MAXFLOAT;
    //[self.editPanel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //self.editPanel.backgroundColor = [UIColor blackColor];
    [self.editPanel setHidden: true];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.editPanel.frame.size.width, self.editPanel.frame.size.height)];
    self.editPanel.layer.masksToBounds = NO;
    self.editPanel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.editPanel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    self.editPanel.layer.shadowOpacity = 0.8;
    self.editPanel.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.colorView.frame.size.width, self.colorView.frame.size.height)];
    self.colorView.layer.masksToBounds = NO;
    self.colorView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.colorView.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    self.colorView.layer.shadowOpacity = 0.8;
    self.colorView.layer.shadowPath = shadowPath2.CGPath;
    
    UIBezierPath *shadowPath3 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.editBtn.frame.size.width, self.editBtn.frame.size.height)];
    self.editBtn.layer.masksToBounds = NO;
    self.editBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    self.editBtn.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    self.editBtn.layer.shadowOpacity = 0;
    self.editBtn.layer.shadowPath = shadowPath3.CGPath;
    
    self.editPanel.layer.cornerRadius = 4;
    self.colorView.layer.cornerRadius = 4;
    self.colorButton.layer.cornerRadius = 4;
    self.blueNoteBtn.layer.cornerRadius = 4;
    self.redNoteBtn.layer.cornerRadius = 4;
    self.greenNoteBtn.layer.cornerRadius = 4;
    
    [self.editBtn setTag: SlideEditPanelShow]; // 当前状态是hidden，再点击就是Show操作
    [self.editBtn addTarget:self action:@selector(actionToggleShowEditPanel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.laserSwitch setOn: false];
    [self.laserSwitch addTarget:self action:@selector(actionChangeLaserSwitch:) forControlEvents:UIControlEventValueChanged];
    
    
    self.forbidCss = @"<style type='text/css'>          \
    body { background: black; }     \
    * {                             \
    -webkit-touch-callout: none;\
    -webkit-user-select: none;  \
    }                               \
    </style>                        \
    </head>";
    
    
    // webView添加手势，向左即上一页，向右即下一页
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(lastPage:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.webView addGestureRecognizer:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextPage:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.webView addGestureRecognizer:gestureLeft];
    // webView按手势放大或缩小
    self.webView.scalesPageToFit = YES;
    
    
    // 作笔记的入口，可切换笔记颜色
    [self.redNoteBtn setBackgroundColor:[UIColor redColor]];
    [self.redNoteBtn addTarget:self action:@selector(noteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.greenNoteBtn setBackgroundColor:[UIColor greenColor]];
    [self.greenNoteBtn addTarget:self action:@selector(noteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.blueNoteBtn setBackgroundColor:[UIColor blueColor]];
    [self.blueNoteBtn addTarget:self action:@selector(noteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // [self demoExtract];
    [self extractResource];
    
    [self loadHtml];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  控件事件
 */
- (void) loadHtml {
    NSString *htmlName = [self.fileDesc[SLIDE_DESC_ORDER] objectAtIndex: [self.currentPageIndex intValue]];
    NSString *htmlFile = [NSString stringWithFormat:@"%@/%@.%@", self.filePath, htmlName, PAGE_HTML_FORMAT];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    //htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</head>" withString:self.forbidCss];
    //NSLog(@"%@", htmlFile);
    NSString *basePath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];;
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
}

- (void) loadConfigInfo {
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    
    // Basic Key Check
    if(configDict[CONTENT_KEY_DISPLAYID] == nil) {
        NSLog(@"CONTENT_CONFIG_FILENAME#CONTENT_KEY_DISPLAYID Not Set!");
        abort();
    }
    if(configDict[SLIDE_DISPLAY_TYPE] == nil) {
        NSLog(@"CONTENT_CONFIG_FILENAME#SLIDE_DISPLAY_TYPE Not Set!");
        abort();
    }
    self.slideID = configDict[CONTENT_KEY_DISPLAYID];
    self.isFavorite = ([configDict[SLIDE_DISPLAY_TYPE] intValue] == SlideTypeFavorite);
    
    if([self.slideID length] == 0) {
        NSLog(@"CONTENT_CONFIG_FILENAME#CONTENT_KEY_DISPLAYID Is Empty!");
        abort();
    }
    
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    self.filePath = [FileUtils getPathName:dirName FileName:self.slideID];
    NSString *descPath = [self.filePath stringByAppendingPathComponent:SLIDE_CONFIG_FILENAME];
    NSError *error;
    NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
    BOOL isYES = NSErrorPrint(error, @"read slide desc content#%@", descPath);
    if(!isYES) { abort(); }
    
    self.fileDesc = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    isYES = NSErrorPrint(error, @"desc content convert into json");
    if(!isYES) { abort(); }
}

- (IBAction)addSlideToFavorite:(UIButton *)sender {
    BOOL isSuccessfully = [FileUtils copySlideToFavorite:self.slideID Block:^(NSMutableDictionary *dict) {
        [DateUtils updateSlideTimestamp:dict];
    }];
    
    // 信息提示
    if(self.popupView == nil) {
        self.popupView = [[PopupView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/4, self.view.frame.size.width/2, self.view.frame.size.height/2)];
        
        self.popupView.ParentView = self.view;
    }
    NSString *popupInfo = [NSString stringWithFormat:@"拷贝%@", isSuccessfully ? @"成功" : @"失败"];
    [self showPopupView: popupInfo];
    
}
- (void) showPopupView: (NSString*) text {
    [self.popupView setText: text];
    [self.view addSubview:self.popupView];
}

- (void) extractResource {
    NSString *zipName = @"pdfJS";
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    // pdfJS
    NSString *resPath = [documentPath stringByAppendingPathComponent:@"Resources"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //[fileManager removeItemAtPath:resPath error:nil];
    BOOL isDir = TRUE;
    BOOL isDirExist = [fileManager fileExistsAtPath:resPath isDirectory:&isDir];
    if(!isDirExist)
        [fileManager createDirectoryAtPath:resPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *pdfJSPath = [resPath stringByAppendingPathComponent:@"pdfJS"];
    isDirExist = [fileManager fileExistsAtPath:pdfJSPath isDirectory:&isDir];
    if(!isDirExist) {
        NSString *pdfJSZip = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", zipName]];
        BOOL state = [SSZipArchive unzipFileAtPath:pdfJSZip toDestination:resPath];
        NSLog(@"%@", [NSString stringWithFormat:@"pdfJS解压zip: %@", state ? @"成功" : @"失败"]);
    }
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
        [self.editPanel setHidden:(tag != SlideEditPanelShow)];
    }];
    
    switch(tag) {
        case SlideEditPanelHiden: {
            [self.editBtn setTag:SlideEditPanelShow];
            [self.editBtn setBackgroundImage:[UIImage imageNamed:@"iconPen"] forState:UIControlStateNormal];
            self.editPanelBgView.hidden = YES;
            self.colorView.hidden = YES;
            self.editBtn.layer.shadowOpacity = 0;
            [self stopLaser];
            [self stopNote];
        }
            break;
            
        case SlideEditPanelShow: {
            [self.editBtn setTag:SlideEditPanelHiden];
            [self.editBtn setBackgroundImage:[UIImage imageNamed:@"iconPenBack"] forState:UIControlStateNormal];
            self.editPanelBgView.hidden = NO;
            self.editBtn.layer.shadowOpacity = 0.5;
            
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
        [self.drawBtn setEnabled:false];
    }
    
    [self.view sendSubviewToBack:self.colorView];
    self.colorView.hidden = YES;
    [self.view bringSubviewToFront:self.editPanel];
    [self.view bringSubviewToFront:self.editBtn];
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

// 笔记颜色
-(void)noteBtnClick:(UIButton*) sender{
    // 关闭switch控件，并触发自身函数
    [self.laserSwitch setOn:false];
    [self stopLaser];
    [self startNote];
    self.paintView.paintColor = sender.backgroundColor;
    self.colorButton.backgroundColor = sender.backgroundColor;
    
    [self.view sendSubviewToBack:self.colorView];
    self.colorView.hidden = YES;
    
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
        
        [self.view bringSubviewToFront:self.editPanel];
        [self.view bringSubviewToFront:self.editBtn];
    }
}

/**
 *  停用作笔记
 */
- (void) stopNote {
    if(self.isDrawing) {
        [self.paintView removeFromSuperview];
        self.isDrawing = !self.isDrawing;
        self.colorButton.backgroundColor = [UIColor whiteColor];
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
    
    NSInteger pageCount = [[self.fileDesc objectForKey:SLIDE_DESC_ORDER] count];
    NSInteger index = ([self.currentPageIndex intValue] + 1) % pageCount;
    self.currentPageIndex = [NSNumber numberWithInteger:index];
    [self loadHtml];
    NSLog(@"next - current page index: %ld", (long)self.currentPageIndex);
}
/**
 *  浏览文档时[上一页], 触发手势: 向右滑动
 *
 *  @param sender UIButton
 */
- (IBAction)lastPage: (id)sender {
    [self stopLaser];
    [self stopNote];
    
    NSInteger pageCount = [[self.fileDesc objectForKey:SLIDE_DESC_ORDER] count];
    NSInteger index =  ([self.currentPageIndex intValue]- 1 + pageCount) % pageCount;
    self.currentPageIndex = [NSNumber numberWithInteger:index];
    [self loadHtml];
    NSLog(@"next - current page index: %ld", (long)self.currentPageIndex);
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
- (IBAction) enterFilePagesView:(id)sender {
    // 如果文档已经下载，可以查看文档内部详细信息，
    // 否则需要下载，该功能在FileSlide内部处理
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    if([FileUtils checkSlideExist:self.slideID Dir:dirName Force:YES]) {
        // 界面跳转需要传递fileID，通过写入配置文件来实现交互
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:EDITPAGES_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        
        NSString *pageID = [self.fileDesc[SLIDE_DESC_ORDER] objectAtIndex:[self.currentPageIndex integerValue]];
        [config setObject:self.slideID forKey:CONTENT_KEY_EDITID1];
        [config setObject:pageID forKey:CONTENT_KEY_EDITID2];
        NSNumber *slideType = [NSNumber numberWithInteger:SlideTypeSlide];
        if(self.isFavorite) {
            slideType = [NSNumber numberWithInteger:SlideTypeFavorite];
        }
        [config setObject:slideType forKey:SLIDE_EDIT_TYPE];
        [FileUtils writeJSON:config Into:pathName];
        
        NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
        NSString *fileDescSwpPath = [FileUtils slideDescPath:self.slideID Dir:dirName Klass:SLIDE_CONFIG_SWP_FILENAME];
        if([FileUtils checkFileExist:fileDescSwpPath isDir:false]) {
            NSLog(@"Config SWP file Exist! last time must be CRASH!");
        } else {
            // 拷贝一份文档描述配置
            [FileUtils copyFileDescContent:self.slideID Dir:dirName];
        }
        
        // 界面跳转至文档页面编辑界面
        if(self.reViewController == nil) {
            self.reViewController = [[ReViewController alloc] init];
        }
        [self presentViewController:self.reViewController animated:NO completion:nil];
    }
}



- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Disable user selection
    NSLog(@"webViewDidFinishLoad");
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
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
 *  关闭presentViewController
 *
 *  @param sender
 */
- (IBAction)actionDismiss:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)colorButtonTouched:(UIButton *)sender {
    self.colorView.hidden = !self.colorView.hidden;
    self.iconTriangleImageView.hidden = !self.iconTriangleImageView.hidden;
    if(!self.colorView.hidden) {
        [self.view bringSubviewToFront:self.colorView];
    }
}


@end
