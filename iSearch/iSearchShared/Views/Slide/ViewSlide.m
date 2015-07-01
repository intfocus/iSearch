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

#import "ApiUtils.h"
#import "FileUtils.h"
#import "HttpUtils.h"
#import "SSZipArchive.h"
#import "PopupView.h"
#import "ExtendNSLogFunctionality.h"

#import "MainViewController.h"

@interface ViewSlide()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, nonatomic) PopupView *popupView;

// http download variables begin
@property (strong, nonatomic) NSString   *downloadURL;
@property (strong, nonatomic) NSURLConnection *downloadConnection;
@property (strong, nonatomic) NSMutableData   *downloadConnectionData;
@property (strong, nonatomic) NSNumber *downloadZipSize;
@property (strong, nonatomic) NSNumber *downloadLength;
@property (nonatomic, nonatomic) BOOL isDownloadRequestValid;
// http download variables end
@end

@implementation ViewSlide
@synthesize labelTitle;
@synthesize btnDownloadOrDisplay;
@synthesize btnSlideInfo;
@synthesize webViewThumbnail;

# pragma mark - rewrite setter

- (void)setDict:(NSMutableDictionary *)dict {
    self.slide = [[Slide alloc] initSlide:dict isFavorite:self.isFavorite];
        
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
        if([HttpUtils isNetworkAvailable]) {
            self.isDownloadRequestValid = YES;
            [self downloadZip:[ApiUtils downloadSlideURL:self.slideID]];
        } else {
            [self showPopupView:@"无网络，\n不下载"];
        }
    }
    [self updateBtnDownloadOrDisplayIcon];
}

- (IBAction)actionDisplaySlideInfo:(UIButton *)sender {
    MainViewController *mainViewController = [self masterViewController];

    [mainViewController popupSlideInfo:[self.slide refreshFields] isFavorite:self.isFavorite];
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
    
    if([self.slide.pages count] > 0) {
        [self.slide enterEditState];
        [self.masterViewController presentViewDisplayViewController];
    } else {
        [self showPopupView:@"it is empty"];
    }
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
    htmlContent = [NSString stringWithFormat:@"<html><body><img src='%@'></body></html>", thumbnailName];
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
- (void) downloadZip:(NSURL *)url {
    [self.slide toDownloaded];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableData *data = [[NSMutableData alloc] init];
    self.downloadConnectionData = data;
    NSURLConnection *newConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.downloadConnection = newConnection;
    if (self.downloadConnection){
        NSLog(@"Successfully created the connection");
    } else {
        NSLog(@"Could not create the connection");
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"An error happened");
    NSLog(@"%@", error);
}
/**
 *  Response Header
 *
 *   "Accept-Length" = 9010551;
 *   "Accept-Ranges" = bytes;
 *   "Content-Disposition" = "attachment; filename=93.zip";
 *   "Content-Type" = "application/octet-stream";
 *   Date = "Wed, 01 Jul 2015 06:00:48 GMT";
 *   Server = "Microsoft-IIS/7.5";
 *   "Transfer-Encoding" = Identity;
 *   "X-Powered-By" = "PHP/5.6.8, ASP.NET";
 *
 *  @param connection <#connection description#>
 *  @param response   <#response description#>
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* http = (NSHTTPURLResponse*)response;
    NSDictionary* headerDict = http.allHeaderFields;
    NSString* contentType = [headerDict objectForKey:@"Content-Type"];
    if([[contentType lowercaseString] isEqualToString:@"application/octet-stream"]) {
        self.downloadLength = [NSNumber numberWithFloat:[headerDict[@"Accept-Length"] floatValue]];
        self.progressView.hidden = NO;
    } else {
        self.isDownloadRequestValid = NO;
    }
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.downloadConnectionData appendData:data];
    
    self.progressView.progress = (float)[self.downloadConnectionData length] / [self.downloadLength floatValue];
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection{
    /* 下载的数据 */
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.slideID];
    NSString *pathName = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    
    BOOL state = [self.downloadConnectionData writeToFile:pathName atomically:YES];
    NSLog(@"%@", [NSString stringWithFormat:@"保存<#id:%@ %@> %@", self.slideID, pathName, state ? @"成功" : @"失败"]);
    
    // 下载zip动作为异步，解压动作应该放在此处
    if(state) {
        [self extractZipFile];
        [self reloadSlideDesc];
        
        [self.slide downloaded];
        self.progressView.hidden = YES;
    }
    
    [self updateBtnDownloadOrDisplayIcon];
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:zipPath error:NULL];
}

/**
 *  文档下载后，把文档页面排序重新赋值，
 *  其他信息都以目录中获取的信息为主
 */
- (void) reloadSlideDesc {
    NSMutableDictionary *descDict = [FileUtils readConfigFile:self.slide.descPath];
    if(descDict[SLIDE_DESC_ORDER] != nil) {
        self.slide.pages = descDict[SLIDE_DESC_ORDER];
        NSMutableDictionary *pageFromSlides = [[NSMutableDictionary alloc] init];
        [pageFromSlides setObject:self.slide.title forKey:self.slide.ID];
        self.slide.slides = pageFromSlides;
        [self.slide save];
    } else {
        NSLog(@"Bug Slide#order is nil, %@", self.slide.dictPath);
    }
}
@end
