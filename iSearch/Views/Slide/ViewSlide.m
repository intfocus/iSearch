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

#import "Url+Param.h"
#import "FileUtils.h"
#import "HttpUtils.h"
#import "SSZipArchive.h"
#import "MBProgressHUD.h"
#import "ExtendNSLogFunctionality.h"

#import "MainViewController.h"

@interface ViewSlide()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *btnSlideInfo; // 展示文档信息,弹出框
@property (weak, nonatomic) IBOutlet UIButton *btnDownloadOrDisplay;
@property (weak, nonatomic) IBOutlet UIWebView *webViewThumbnail;

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
    self.labelTitle.textAlignment = ([self.slide.title length] > 10 ? NSTextAlignmentLeft : NSTextAlignmentCenter);
    
    [self loadThumbnail];
    [self updateBtnDownloadOrDisplayIcon];
    [self bringSubviewToFront:self.btnDownloadOrDisplay];

    self.progressView.hidden = ![self.slide isDownloading];
        _dict = [NSMutableDictionary dictionaryWithDictionary:dict];
}
- (void)setIsFavorite:(BOOL)isFavorite {
    _isFavorite = isFavorite;
    
    UIImage *image = [UIImage imageNamed:(isFavorite ? @"infoFavorite" : @"infoSlide")];
    [self.btnSlideInfo setImage:image forState:UIControlStateNormal];
}

- (IBAction)setMasterViewController:(MainViewController *)masterViewController {
    _masterViewController = masterViewController;
    
    [self.btnSlideInfo addTarget:self action:@selector(actionDisplaySlideInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnDownloadOrDisplay addTarget:self action:@selector(actionDownloadOrDisplaySlide:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - control action
- (IBAction)actionDownloadOrDisplaySlide:(UIButton *)sender {
    if([self.slide isDownloading]) {
        [self showPopupView:@"下载中,请稍等."];
    } else if([self.slide isDownloaded]) {
        [self actionDisplaySlide];
    } else {
        if([HttpUtils isNetworkAvailable]) {
            self.isDownloadRequestValid = YES;
            NSString *urlString = [Url slideDownload:self.slideID];
            NSURL *url = [NSURL URLWithString:urlString];
            [self downloadZip:url];
        } else {
            [self showPopupView:@"无网络，不下载"];
        }
    }
    [self updateBtnDownloadOrDisplayIcon];
}

- (IBAction)actionDisplaySlideInfo:(UIButton *)sender {
    MainViewController *mainViewController = [self masterViewController];

    [mainViewController popupSlideInfo:[self.slide refreshFields] isFavorite:self.isFavorite];
}


- (void)actionDisplaySlide{
    //  this slide display or not;
    if(!self.slide.isDisplay) {
        self.slide.isDisplay = YES;
        [self.slide save];
    }
    
    if([self.slide.pages count] > 0) {
        // tell DisplayViewController somthing it need.
        NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
        NSNumber *displayType = [NSNumber numberWithInt:(self.isFavorite ? SlideTypeFavorite : SlideTypeSlide)];
        NSNumber *displayFrom = [NSNumber numberWithInt:(DisplayFromSlide)];
        [configDict setObject:self.slideID forKey:CONTENT_KEY_DISPLAYID];
        [configDict setObject:displayType forKey:SLIDE_DISPLAY_TYPE];
        [configDict setObject:displayFrom forKey:SLIDE_DISPLAY_FROM];
        [FileUtils writeJSON:configDict Into:configPath];
        
        [self.slide enterDisplayOrScanState];
        [self.masterViewController presentViewDisplayViewController];
    } else {
        [self showPopupView:@"文档为空,无法演示"];
    }
}

#pragma mark - assistant methods
- (void)showPopupView:(NSString*)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText =text;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
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
    if([self.slide isDownloaded]) {
        if(self.slide.isDisplay) {
            image = [UIImage imageNamed:@"coverSlideToDisplay"];
        } else {
            image = [UIImage imageNamed:@"coverSlideUnDisplay"];
        }
    } else if([self.slide isDownloading]) {
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
    NSString *html = [NSString stringWithFormat:@"<img src ='%@' style='width:100%%;'>", [self.slide.thumbailPath lastPathComponent]];
    NSURL *baseURL = [NSURL fileURLWithPath:[self.slide.thumbailPath stringByDeletingLastPathComponent]];
    [self.webViewThumbnail loadHTMLString:html baseURL:baseURL];
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
- (void) downloadZip:(NSURL *)url {
    [self.slide toDownloaded];
    
    NSURLRequest *request       = [NSURLRequest requestWithURL:url];
    NSMutableData *data         = [[NSMutableData alloc] init];
    self.downloadConnectionData = data;
    self.downloadConnection     = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.progressView.progress  = 0.0;
    self.progressView.hidden    = NO;
    
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
 *  @param connection connection
 *  @param response response
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* http = (NSHTTPURLResponse*)response;
    NSDictionary* headerDict = http.allHeaderFields;
    NSString* contentType = [headerDict objectForKey:@"Content-Type"];
    if([[contentType lowercaseString] isEqualToString:@"application/octet-stream"]) {
        self.downloadLength = [NSNumber numberWithFloat:[headerDict[@"Accept-Length"] floatValue]];
        if([self.downloadLength floatValue] == 0.0) { self.downloadLength = [NSNumber numberWithInteger:1]; }
    } else {
        self.isDownloadRequestValid = NO;
        self.progressView.hidden = YES;
    }
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.downloadConnectionData appendData:data];
    
    float progress = (float)[self.downloadConnectionData length] / [self.downloadLength floatValue];
    if(progress > 1.0) { progress = 0.99; }
    self.progressView.progress = progress;
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
    if(![self.slide isDownloaded]) {
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
    if(descDict[SLIDE_DESC_ORDER]) {
        self.slide.pages      = descDict[SLIDE_DESC_ORDER];
        self.slide.slides     = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.slide.title, self.slide.ID, nil];
        self.slide.folderSize = [FileUtils folderSize:self.slide.path];
        [self.slide refreshThumbnailPath];
        [self.slide save];
        
        [self loadThumbnail];
    } else {
        NSLog(@"Bug Slide#order is nil, %@", self.slide.dictPath);
    }
}
@end
