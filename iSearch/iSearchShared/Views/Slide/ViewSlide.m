//
//  FileSlide.m
//  WebStructure
//
//  Created by lijunjie on 15-4-14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewSlide.h"
#import "const.h"
#import "Slide.h"
#import "message.h"

#import "FileUtils.h"
#import "SSZipArchive.h"
#import "PopupView.h"
#import "ExtendNSLogFunctionality.h"

#import "MainViewController.h"
#import "DisplayViewController.h"

@interface ViewSlide()
@property (nonatomic, nonatomic) DisplayViewController *displayViewController;
@property (nonatomic, nonatomic) PopupView *popupView;

// http download variables begin
@property (strong, nonatomic) NSURLConnection *downloadConnection;
@property (strong, nonatomic) NSMutableData   *downloadConnectionData;
// http download variables end
@end

@implementation ViewSlide
@synthesize labelTitle;
@synthesize btnDownloadOrDisplay;
@synthesize btnSlideInfo;
@synthesize webViewThumbnail;

# pragma mark - rewrite setter

- (void)setDict:(NSMutableDictionary *)dict {
    self.slide = [[Slide alloc] initWith:dict Favorite:self.isFavorite];
    self.slideID = self.slide.ID;
    self.dirName = self.slide.dirName;
    self.labelTitle.text = self.slide.title;
    _dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    if(self.slideID == nil) {
        NSLog(@"self.slideID is necessary! %@", self.slide.to_s);
        abort();
    }
    
    [self loadThumbnail];
    [self updateBtnDownloadOrDisplayIcon];
    [self bringSubviewToFront:self.btnDownloadOrDisplay];
}

- (IBAction)setMasterViewController:(MainViewController *)masterViewController {
    _masterViewController = masterViewController;
    
    [self.btnSlideInfo addTarget:self action:@selector(actionDisplaySlideInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnDownloadOrDisplay addTarget:self action:@selector(actionDownloadOrDisplaySlide:) forControlEvents:UIControlEventTouchUpInside];
}



#pragma mark - control action
- (IBAction)actionDownloadOrDisplaySlide:(UIButton *)sender {
    if(self.slide.isDownloading) {
        [self showPopupView:@"下载中,请稍等."];
    } else if(self.slide.isDownloaded) {
        [self performSelector:@selector(actionDisplaySlide:) withObject:self afterDelay:0.0f];
    } else {
        NSString *downloadUrl = [NSString stringWithFormat:@"%@%@?%@=%@",
                                 BASE_URL, CONTENT_DOWNLOAD_URL_PATH, CONTENT_PARAM_FILE_DWONLOADID, self.slideID];
        [self downloadZip:downloadUrl];
    }
    [self updateBtnDownloadOrDisplayIcon];
}

- (IBAction)actionDisplaySlideInfo:(UIButton *)sender {
    MainViewController *mainViewController = [self masterViewController];
//    [mainViewController poupSlideInfo:self.slideID Dir:self.dirName];
    [mainViewController poupSlideInfo:[self.slide refreshFields] isFavorite:self.isFavorite];
}


- (IBAction)actionDisplaySlide:(UIButton *)sender {
    //  this slide display or not;
    if(!self.slide.isDisplay) {
        self.slide.isDisplay = YES;
        [self.slide save];
    }
    
    // tell DisplayViewController somthing it need.
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    NSNumber *displayType = [NSNumber numberWithInt:(self.isFavorite ? SlideTypeFavorite : SlideTypeSlide)];
    NSNumber *displayFrom = [NSNumber numberWithInt:(DisplayFromSlide)];
    [configDict setObject:self.slideID forKey:CONTENT_KEY_DISPLAYID];
    [configDict setObject:displayType forKey:SLIDE_DISPLAY_TYPE];
    [configDict setObject:displayFrom forKey:SLIDE_DISPLAY_FROM];
    [FileUtils writeJSON:configDict Into:configPath];
    
    if(self.displayViewController == nil) {
        self.displayViewController = [[DisplayViewController alloc] init];
        self.displayViewController.callingController2 = self;
    }
    [self.masterViewController presentViewController:self.displayViewController animated:NO completion:nil];
}
/**
 *  释放DisplayViewController内存
 */
- (void)dismissDisplayViewController {
    _displayViewController = nil;
    NSLog(@"dismissed here - ViewSlide");
}

#pragma mark - assistant methods

- (void)showPopupView:(NSString*) text {
    if(self.popupView == nil) {
        self.popupView = [[PopupView alloc]initWithFrame:CGRectMake(self.masterViewController.view.frame.size.width/4, self.masterViewController.view.frame.size.height/4, self.masterViewController.view.frame.size.width/2, self.masterViewController.view.frame.size.height/2)];
        
        self.popupView.ParentView = self.masterViewController.view;
    }
    
    [self.popupView setText: text];
    // [self.popupView removeFromSuperview];
    [self.masterViewController.view addSubview:self.popupView];
}


/**
 *  图标 - 需求
 *  未下载: slideToDownload.png
 *  已下载:
 *      未曾演示: slideUnDisplay.png
 *      演示过: slideToDisplay.png
 */
- (void) updateBtnDownloadOrDisplayIcon {
    UIImage *image = [UIImage imageNamed:@"coverSlideToDownload"];
    if(self.slide.isDownloaded) {
        if(self.slide.isDisplay) {
            image = [UIImage imageNamed:@"coverSlideToDisplay"];
        } else {
            image = [UIImage imageNamed:@"coverSlideUnDisplay"];
        }
    } else if(self.slide.isDownloading) {
        image = [UIImage imageNamed:@"coverSlideDownloading"];
    }
    [self.btnDownloadOrDisplay setImage:image forState:UIControlStateNormal];
}

/**
 *  UIWebView浏览PDF或GIF文档
 *
 *  @param documentName PDF文档路径
 *  @param webView      UIWebView
 */
- (void)loadThumbnail {
    self.webViewThumbnail.hidden = NO;
    NSString *thumbnailName = [NSString stringWithFormat:@"%@.png", self.slideID];
    NSString *slidePath = [FileUtils getPathName:self.dirName FileName:self.slideID];
    NSString *thumbanilPath = [slidePath stringByAppendingPathComponent:thumbnailName];
    
    NSString *htmlContent, *basePath = slidePath;
    NSURL *baseURL;
    if(![FileUtils checkFileExist:thumbanilPath isDir:NO]) {
        thumbnailName = @"thumbnailSlideDefault.png";
        basePath =  [[NSBundle mainBundle] bundlePath];
    }
    baseURL = [NSURL fileURLWithPath:basePath];
    htmlContent = [NSString stringWithFormat:@"<html><body><img src ='%@'></body></html>", thumbnailName];
    [self.webViewThumbnail loadHTMLString:htmlContent baseURL:baseURL];
}


//////////////////////////////////////////////////////////////
#pragma mark - 下载文档 格式为zip压缩包
//////////////////////////////////////////////////////////////

/**
 *  传递下载zip链接: 下载zip，保存，解压。
 *  注意: 下载操作为异步，后续操作应该写在[完成回调]函数中，而非该方法调用后面。
 *
 *  @param urlString 下载zip链接
 */
#warning 监测下载进程及进程
- (void) downloadZip: (NSString *) urlString {
    [FileUtils slideToDownload:self.slideID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableData *data = [[NSMutableData alloc] init];
    self.downloadConnectionData = data;
    NSURLConnection *newConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.downloadConnection = newConnection;
    if (self.downloadConnection != nil){
        NSLog(@"Successfully created the connection");
    } else {
        NSLog(@"Could not create the connection");
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"An error happened");
    NSLog(@"%@", error);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"Received data: %@", self.slideID);
    [self.downloadConnectionData appendData:data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection{
    /* 下载的数据 */
    NSLog(@"%@", [NSString stringWithFormat:@"下载<#id:%@ url:%@> 成功", self.slideID, self.dict[CONTENT_FIELD_URL]]);
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.slideID];
    NSString *pathName = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    
    BOOL state = [self.downloadConnectionData writeToFile:pathName atomically:YES];
    NSLog(@"%@", [NSString stringWithFormat:@"保存<#id:%@ url:%@> %@", self.slideID, self.dict[CONTENT_FIELD_URL], state ? @"成功" : @"失败"]);
    
#warning 服务器端响应文字处理：文件不存在
    // 下载zip动作为异步，解压动作应该放在此处
    if(state) {
        [self extractZipFile];
        [self reloadSlideDesc];
        
        [self.slide downloaded];
    }
    
    [self updateBtnDownloadOrDisplayIcon];
}
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self.downloadConnectionData setLength:0];
}

/**
 *  DOWNLOAD_DIRNAME/id.zip 解压至 CONTENT_DIRNAME/id
 */
- (void) extractZipFile {
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.slide.ID];
    NSString *zipPath = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    
    // 解压
    BOOL state = [SSZipArchive unzipFileAtPath:zipPath toDestination:self.slide.path];
    NSLog(@"%@", [NSString stringWithFormat:@"解压<#id:%@.zip> %@", self.slide.ID, state ? @"成功" : @"失败"]);
    // make sure not nest
    if(!self.slide.isDownloaded) {
        NSString *slidePath = [self.slide.path stringByAppendingPathComponent:self.slide.ID];
        if([FileUtils checkFileExist:slidePath isDir:YES]) {
            NSString *tmpPath = [NSString stringWithFormat:@"%@-tmp", self.slide.path];
            NSError *error;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager moveItemAtPath:slidePath toPath:tmpPath error:&error];
            NSErrorPrint(error, @"move file# %@ => %@", slidePath, tmpPath);
            [fileManager removeItemAtPath:self.slide.path error:&error];
            NSErrorPrint(error, @"remove file %@", self.slide.path);
            [fileManager moveItemAtPath:tmpPath toPath:self.slide.path error:&error];
            NSErrorPrint(error, @"move file %@ => %@", tmpPath, self.slide.path);
        }
    }
}

/**
 *  文档下载后，把文档页面排序重新赋值，
 *  其他信息都以目录中获取的信息为主
 */
- (void) reloadSlideDesc {
    NSMutableDictionary *descDict = [FileUtils readConfigFile:self.slide.descPath];
    if(descDict[SLIDE_DESC_ORDER] != nil) {
        self.slide.pages = descDict[SLIDE_DESC_ORDER];
        [self.slide save];
    } else {
        NSLog(@"Bug Slide#order is nil, %@", self.slide.descPath);
    }
}
@end
