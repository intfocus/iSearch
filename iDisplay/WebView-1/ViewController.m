//
//  ViewController.m
//  WebView-1
//
//  Created by lijunjie on 15-4-1.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewController.h"
#import "SSZipArchive.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView; // 展示html5
@property (weak, nonatomic) IBOutlet UIButton *editBtn; // 切换显示编辑状态面板的显示
@property (weak, nonatomic) IBOutlet UIView *editPanel; // 编辑状态面板
@property (weak, nonatomic) IBOutlet UIButton *drawBtn;
@property (weak, nonatomic) IBOutlet UISwitch *laserSwitch; // 激光笔状态切换
@property (weak, nonatomic) IBOutlet UIButton *redNoteBtn;  // 笔记 - 红色
@property (weak, nonatomic) IBOutlet UIButton *greenNoteBtn;// 笔记 - 绿色
@property (weak, nonatomic) IBOutlet UIButton *blueNoteBtn; // 笔记 - 蓝色

@property (nonatomic, nonatomic) NSInteger  htmlFileCount;
@property (nonatomic, nonatomic) NSInteger  htmlCurrentIndex;
@property (nonatomic, nonatomic) BOOL  isDrawing; // 作笔记状态
@property (nonatomic, nonatomic) BOOL  isLasering;// 激光笔状态
@property (nonatomic, nonatomic) PaintView  *paintView; // 笔记、激光笔画布
@property (nonatomic, nonatomic) NSString *fileID;
@property (nonatomic, nonatomic) NSString *filePath;
@property (nonatomic, nonatomic) NSMutableDictionary *fileDesc;
@property (nonatomic, nonatomic) NSString *forbidCss;

@end

@implementation ViewController
@synthesize  paintView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"device: %@", NSStringFromCGRect([[UIScreen mainScreen] bounds]))
    self.htmlCurrentIndex    = 0;
    self.isDrawing           = false;
    self.paintView            = nil;
    self.editPanel.layer.zPosition = MAXFLOAT;
    //[self.editPanel setTranslatesAutoresizingMaskIntoConstraints:NO];
   
    self.editPanel.backgroundColor = [UIColor blackColor];
    [self.editPanel setHidden: true];
    
    [self.editBtn setTag: 0]; // 1为编辑状态
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
    
    [self demoExtract];
    [self extractResource];
    
    [self loadHtml];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"welcome come back, it's viewWillApper.");
}
- (void) demoExtract {
    // Files
    self.fileID = @"1";
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filesPath = [documentPath stringByAppendingPathComponent:@"Files"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Remove ExtractPath clear cache
    // [fileManager removeItemAtPath:filesPath error:nil];
    BOOL isDir = TRUE;
    BOOL isDirExist = [fileManager fileExistsAtPath:filesPath isDirectory:&isDir];
    if(!isDirExist)
        [fileManager createDirectoryAtPath:filesPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *zipPathName = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", self.fileID]];
    self.filePath = [filesPath stringByAppendingPathComponent:self.fileID];
    
    
    isDirExist = [fileManager fileExistsAtPath:self.filePath isDirectory:&isDir];
    if(!isDirExist) {
        // 解压
        BOOL state = [SSZipArchive unzipFileAtPath:zipPathName toDestination:filesPath];
        NSLog(@"%@", [NSString stringWithFormat:@"File解压zip: %@", state ? @"成功" : @"失败"]);
    }
    NSError *error;
    NSString *descPath = [self.filePath stringByAppendingPathComponent:@"desc.json"];
    NSString *descContent = [NSString stringWithContentsOfFile:descPath encoding:NSUTF8StringEncoding error:&error];
    if(error)
        NSLog(@"read desc failed: %@", [error localizedDescription]);
    self.fileDesc = [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(error)
        NSLog(@"string to json: %@", [error localizedDescription]);
    
    NSLog(@"file desc: %@", self.fileDesc);
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
 *  编辑按钮, 回调函数 - 编辑面板切换显示、隐藏
 *  编辑按钮的tag值，指示当前状态: 0 隐藏编辑面板(默认值), 1 显示编辑面板
 *
 *  @param sender UIButton
 */
- (void) toggleShowEditPanel: (UIButton*) sender {
    if(sender.tag == 0) {
        [UIView animateWithDuration:.5f animations:^{
            [self.editPanel setHidden:false];
        }];
        
        [self.editBtn setTag:1];
        [self.editBtn setTitle:@"<<" forState:UIControlStateNormal];
    } else {
        [UIView animateWithDuration:.5f animations:^{
            [self.editPanel setHidden:true];
        }];
        
        [self stopNote];
        [self stopLaser];
        
        [self.editBtn setTag:0];
        [self.editBtn setTitle:@">>" forState:UIControlStateNormal];
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
        self.paintView.backgroundColor = [UIColor whiteColor];
        self.paintView.paintColor = [UIColor blackColor];
        self.paintView.alpha = 0.2;
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
        self.paintView.backgroundColor = [UIColor whiteColor];
        self.paintView.alpha = 0.3;
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
    self.htmlCurrentIndex = (self.htmlCurrentIndex + 1) % [[self.fileDesc objectForKey:@"order"] count];
    [self loadHtml];
    NSLog(@"next - current page index: %ld", (long)self.htmlCurrentIndex);
}
/**
 *  浏览文档时[上一页], 触发手势: 向右滑动
 *
 *  @param sender UIButton
 */
- (IBAction)lastPage: (id)sender {
    NSInteger pageCount = [[self.fileDesc objectForKey:@"order"] count];
    self.htmlCurrentIndex = (self.htmlCurrentIndex - 1 + pageCount) % pageCount;
    [self loadHtml];
    NSLog(@"next - current page index: %ld", (long)self.htmlCurrentIndex);
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
    if([FileUtils checkSlideExist:self.fileID]) {
        // 界面跳转需要传递fileID，通过写入配置文件来实现交互
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:REORGANIZE_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        
        NSString *pageID = [[self.fileDesc objectForKey:@"order"] objectAtIndex:self.htmlCurrentIndex];
        [config setObject:self.fileID forKey:@"FileID"];
        [config setObject:pageID forKey:@"PageID"];
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
        NSLog(@"Come back from pages.");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadHtml {
    NSString *htmlName = [[self.fileDesc objectForKey:@"order"] objectAtIndex: self.htmlCurrentIndex];
    NSString *htmlFile = [NSString stringWithFormat:@"%@/%@.html", self.filePath, htmlName];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    //htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</head>" withString:self.forbidCss];
    //NSLog(@"%@", htmlFile);
    NSString *basePath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];;
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Disable user selection
    NSLog(@"webViewDidFinishLoad");
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    //[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

// 做笔记
- (void) toggleDrawing {
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

@end
