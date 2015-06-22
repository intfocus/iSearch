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

#import "MainViewController.h"
#import "DisplayViewController.h"

@interface ViewSlide()
@property (nonatomic, nonatomic) DisplayViewController *displayViewController;
@end

@implementation ViewSlide
@synthesize labelTitle;
@synthesize btnDownloadOrDisplay;
@synthesize btnSlideInfo;
@synthesize webViewThumbnail;

# pragma mark - rewrite setter

- (void)setDict:(NSMutableDictionary *)dict {
    self.slide = [[Slide alloc] init];
    self.slide = [Slide initWith:dict Favorite:self.isFavorite];
    self.slideID = self.slide.slideID;
    self.dirName = self.slide.dirName;
    _dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
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
    if([FileUtils checkSlideExist:self.slideID Dir:self.dirName Force:NO]) {
        [self performSelector:@selector(actionDisplaySlide:) withObject:self afterDelay:0.0f];
        [self updateBtnDownloadOrDisplayIcon];
    } else {
        NSString *downloadUrl = [NSString stringWithFormat:@"%@%@?%@=%@",
                                 BASE_URL, CONTENT_DOWNLOAD_URL_PATH, CONTENT_PARAM_FILE_DWONLOADID, self.slideID];
        [self downloadZip:downloadUrl];
    }
}

- (IBAction)actionDisplaySlideInfo:(UIButton *)sender {
    MainViewController *mainViewController = [self masterViewController];
//    [mainViewController poupSlideInfo:self.slideID Dir:self.dirName];
    [mainViewController poupSlideInfo:self.dict isFavorite:self.isFavorite];
}


- (IBAction)actionDisplaySlide:(UIButton *)sender {
    //  this slide display or not;
    NSString *descPath = [FileUtils slideDescPath:self.slideID Dir:self.dirName Klass:SLIDE_CONFIG_FILENAME];
    if(self.slide.isDisplay) {
        [self.dict setObject:@"1" forKey:SLIDE_DESC_ISDISPLAY];
        [FileUtils writeJSON:self.dict Into:descPath];
    }
    
    // tell DisplayViewController somthing it need.
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    NSNumber *displayType = [NSNumber numberWithInt:(self.isFavorite ? SlideTypeFavorite : SlideTypeSlide)];
    [configDict setObject:self.slideID forKey:CONTENT_KEY_DISPLAYID];
    [configDict setObject:displayType forKey:SLIDE_DISPLAY_TYPE];
    [FileUtils writeJSON:configDict Into:configPath];
    
    if(self.displayViewController == nil) {
        self.displayViewController = [[DisplayViewController alloc] init];
    }
    [self.masterViewController presentViewController:self.displayViewController animated:NO completion:nil];

}

#pragma mark - assistant methods

/**
 *  read local slide's desc when already download.
 *
 *  @param dict slide's desc from server
 *
 *  @return dict
 */
- (NSMutableDictionary *)checkSlideDownloadOrNot:(NSMutableDictionary *)dict {
    if([FileUtils checkSlideExist:self.slideID Dir:SLIDE_DIRNAME Force:NO]) {
        NSString *descPath = [FileUtils slideDescPath:self.slideID Dir:SLIDE_DIRNAME Klass:CONFIG_DIRNAME];
        dict = [FileUtils readConfigFile:descPath];
    }
    return dict;
}

/**
 *  图标 - 需求
 *  未下载: slideToDownload.png
 *  已下载:
 *      未曾演示: slideUnDisplay.png
 *      演示过: slideToDisplay.png
 */
- (void) updateBtnDownloadOrDisplayIcon {
    UIImage *image;
    if(![FileUtils checkSlideExist:self.slideID Dir:self.dirName Force:NO]) {
        image = [UIImage imageNamed:@"slideToDownload.png"];
    } else {
        if(self.dict[SLIDE_DESC_ISDISPLAY] == nil) {
            image = [UIImage imageNamed:@"slideUnDisplay.png"];
        } else {
            image = [UIImage imageNamed:@"slideToDisplay.png"];
        }
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
    
    NSString *htmlContent, *basePath;
    NSURL *baseURL;
    if([FileUtils checkFileExist:thumbanilPath isDir:NO]) {
        basePath = slidePath;
    } else {
        thumbnailName = @"slide-default.png";
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
- (void) downloadZip: (NSString *) urlString {
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
    
    // 下载zip动作为异步，解压动作应该放在此处
    if(state) [self extractZipFile];
    
    [self updateBtnDownloadOrDisplayIcon];
}
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self.downloadConnectionData setLength:0];
}

/**
 *  DOWNLOAD_DIRNAME/id.zip 解压至 CONTENT_DIRNAME/id
 */
- (void) extractZipFile {
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.slideID];
    NSString *zipPath = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    NSString *filesPath = [FileUtils getPathName:SLIDE_DIRNAME];
    NSString *filePath = [filesPath stringByAppendingPathComponent:self.slideID];
    
    // 解压
    BOOL state = [SSZipArchive unzipFileAtPath:zipPath toDestination:filePath];
    NSLog(@"%@", [NSString stringWithFormat:@"解压<#id:%@.zip> %@", self.slideID, state ? @"成功" : @"失败"]);
}
@end
