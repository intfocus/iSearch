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
@property (weak, nonatomic) IBOutlet UIView *editPanel; // 编辑状态面板
@property (weak, nonatomic) IBOutlet UIButton *drawBtn;
@property (weak, nonatomic) IBOutlet UISwitch *laserSwitch; // 激光笔状态切换
@property (weak, nonatomic) IBOutlet UIButton *redNoteBtn;  // 笔记 - 红色
@property (weak, nonatomic) IBOutlet UIButton *greenNoteBtn;// 笔记 - 绿色
@property (weak, nonatomic) IBOutlet UIButton *blueNoteBtn; // 笔记 - 蓝色

@property (nonatomic, nonatomic) NSInteger  currentPageIndex;
@property (nonatomic, nonatomic) BOOL  isFavorite;// 收藏文件、正常下载文件
@property (nonatomic, nonatomic) BOOL  isDrawing; // 作笔记状态
@property (nonatomic, nonatomic) BOOL  isLasering;// 激光笔状态
@property (nonatomic, nonatomic) PaintView  *paintView; // 笔记、激光笔画布
@property (nonatomic, nonatomic) NSString *fileID;
@property (nonatomic, nonatomic) NSString *filePath;
@property (nonatomic, nonatomic) NSMutableDictionary *fileDesc;
@property (nonatomic, nonatomic) NSString *forbidCss;

@end

@implementation DisplayViewController
@synthesize  paintView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self loadConfigInfo];
    
    self.currentPageIndex    = 0;
    self.isDrawing           = false;
    self.paintView           = nil;
    self.editPanel.layer.zPosition = MAXFLOAT;
    //[self.editPanel setTranslatesAutoresizingMaskIntoConstraints:NO];
   
    self.editPanel.backgroundColor = [UIColor blackColor];
    [self.editPanel setHidden: true];
    
    [self.editBtn setTag: SlideEditPanelShow]; // 当前状态是hidden，再点击就是Show操作
    [self.editBtn addTarget:self action:@selector(toggleShowEditPanel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.laserSwitch setOn: false];
    [self.laserSwitch addTarget:self action:@selector(changeLaserSwitch:) forControlEvents:UIControlEventValueChanged];
    
    
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
    
//    [self demoExtract];
    [self extractResource];
    
    [self loadHtml];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  控件事件
 */
- (void) loadHtml {
    NSString *htmlName = [self.fileDesc[FILE_DESC_ORDER] objectAtIndex: self.currentPageIndex];
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
    self.fileID = configDict[CONTENT_KEY_DISPLAYID];
    self.isFavorite = ([configDict[SLIDE_DISPLAY_TYPE] intValue] == SlideTypeFavorite);
    
    if([self.fileID length] == 0) {
        NSLog(@"CONTENT_CONFIG_FILENAME#CONTENT_KEY_DISPLAYID Is Empty!");
        abort();
    }
    
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : FILE_DIRNAME;
    self.filePath = [FileUtils getPathName:dirName FileName:self.fileID];
    NSString *descPath = [self.filePath stringByAppendingPathComponent:FILE_CONFIG_FILENAME];
    NSError *error;
    NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
    BOOL isYES = NSErrorPrint(error, @"read slide desc content#%@", descPath);
    if(!isYES) { abort(); }
    
    self.fileDesc = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    isYES = NSErrorPrint(error, @"desc content convert into json");
    if(!isYES) { abort(); }
    
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
- (IBAction)toggleShowEditPanel:(UIButton *)sender {
    NSInteger tag = [sender tag];
    [UIView animateWithDuration:.5f animations:^{
        [self.editPanel setHidden:(tag != SlideEditPanelShow)];
    }];
    
    switch(tag) {
        case SlideEditPanelHiden: {
            [self.editBtn setTag:SlideEditPanelShow];
            [self.editBtn setTitle:@"<<" forState:UIControlStateNormal];
        }
        break;
            
        case SlideEditPanelShow: {
            [self stopNote];
            [self stopLaser];
            
            [self.editBtn setTag:SlideEditPanelHiden];
            [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
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
- (void)changeLaserSwitch:(id)sender{
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
        self.paintView.backgroundColor = [UIColor purpleColor];
        self.paintView.paintColor = [UIColor blackColor];
        self.paintView.alpha = 0.6;
        self.paintView.laser = true;
        self.paintView.erase = false;
        [self.view addSubview:self.paintView];
        self.isLasering = !self.isLasering;
        [self.drawBtn setEnabled:false];
    }
    
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
    [self startNote];
    self.paintView.paintColor = sender.backgroundColor;
}

/**
 *  激活作笔记
 */
- (void) startNote {
    if(!self.isDrawing) {
        self.paintView = [[PaintView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.paintView.backgroundColor = [UIColor purpleColor];
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
    }
}

/**
 *  浏览文档时[下一页], 触发手势: 向左滑动
 *
 *  @param sender UIButton
 */
- (IBAction)nextPage: (id)sender {
    self.currentPageIndex = (self.currentPageIndex + 1) % [[self.fileDesc objectForKey:@"order"] count];
    [self loadHtml];
    NSLog(@"next - current page index: %ld", (long)self.currentPageIndex);
}
/**
 *  浏览文档时[上一页], 触发手势: 向右滑动
 *
 *  @param sender UIButton
 */
- (IBAction)lastPage: (id)sender {
    NSInteger pageCount = [[self.fileDesc objectForKey:@"order"] count];
    self.currentPageIndex = (self.currentPageIndex - 1 + pageCount) % pageCount;
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
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : FILE_DIRNAME;
    if([FileUtils checkSlideExist:self.fileID Dir:dirName Force:YES]) {
        // 界面跳转需要传递fileID，通过写入配置文件来实现交互
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:EDITPAGES_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        
        NSString *pageID = [self.fileDesc[FILE_DESC_ORDER] objectAtIndex:self.currentPageIndex];
        [config setObject:self.fileID forKey:CONTENT_KEY_EDITID1];
        [config setObject:pageID forKey:CONTENT_KEY_EDITID2];
        [config setObject:pageID forKey:CONTENT_KEY_EDITID2];
        NSNumber *slideType = [NSNumber numberWithInteger:SlideTypeSlide];
        if(self.isFavorite) {
            slideType = [NSNumber numberWithInteger:SlideTypeFavorite];
        }
        [config setObject:slideType forKey:SLIDE_EDIT_TYPE];
        [config writeToFile:pathName atomically:YES];
        
        NSString *fileDescSwpPath = [FileUtils fileDescPath:self.fileID Klass:FILE_CONFIG_SWP_FILENAME];
        if([FileUtils checkFileExist:fileDescSwpPath isDir:false]) {
            NSLog(@"Config SWP file Exist! last time must be CRASH!");
        } else {
            // 拷贝一份文档描述配置
            [FileUtils copyFileDescContent:self.fileID];
        }
        
        // 界面跳转至文档页面编辑界面
        ReViewController *showVC = [[ReViewController alloc] init];
        [self presentViewController:showVC animated:NO completion:nil];
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
        [self.drawBtn setTitle:@"取消" forState:UIControlStateNormal];
        
    } else {
        [self.paintView removeFromSuperview];
        self.isDrawing = false;
        [self.drawBtn setTitle:@"作笔记" forState:UIControlStateNormal];
        
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

@end
