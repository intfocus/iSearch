//
//  FileSlide.m
//  WebStructure
//
//  Created by lijunjie on 15-4-14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewSlide.h"
#import "const.h"
#import "message.h"
#import "FileUtils.h"
#import "SSZipArchive.h"

@implementation ViewSlide
@synthesize labelTitle;
@synthesize btnDownloadOrDisplay;
@synthesize btnSlideInfo;
@synthesize webViewThumbnail;


- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        // 非收藏文件，才有检测的必要
        if(!self.isFavoriteFile) {
            [self checkSlideDownloadBtn];
        }
    }
    return self;
}

/**
 *  给dict赋值时，进行内部操作
 *  1. 非收藏文件，才有检测的必要
 *
 *  @param dict <#dict description#>
 */
- (void)setDict:(NSMutableDictionary *)dict {
    _dict = dict;
    
    // 收藏文件，说明已下载
    if(self.isFavoriteFile) {
        self.btnDownloadOrDisplay.hidden = NO;
        [self bringSubviewToFront:self.btnDownloadOrDisplay];
    } else {
        self.btnDownloadOrDisplay.hidden = NO;
        [self checkSlideDownloadBtn];
    }
    
    
}

- (IBAction) actionDownloadFile:(id)sender {
    NSString *dir = self.isFavoriteFile ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    if(![FileUtils checkSlideExist:self.dict[CONTENT_FIELD_ID] Dir:dir Force:NO]) {
        [sender setTitle:SLIDE_BTN_DOWNLOADING forState:UIControlStateNormal];
        [self downloadZip:self.dict[CONTENT_FIELD_URL]];
    //} else {
    //     演示文稿功能在主界面代码中处理
    }
}

/**
 *  检测 CONTENT_DIRNAME/id 是否存在
 */
- (void) checkSlideDownloadBtn {
    NSString *dir = self.isFavoriteFile ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    if([FileUtils checkSlideExist:self.dict[CONTENT_FIELD_ID] Dir:dir Force:NO]) {
        [self.btnDownloadOrDisplay setTitle:SLIDE_BTN_DISPLAY forState:UIControlStateNormal];
    } else {
        [self.btnDownloadOrDisplay setTitle:SLIDE_BTN_DOWNLOAD forState:UIControlStateNormal];
    }
}

/**
 *  UIWebView浏览PDF或GIF文档
 *
 *  @param documentName PDF文档路径
 *  @param webView      UIWebView
 */
- (void)loadThumbnail:(NSString *)thumbnailPath {
    self.webViewThumbnail.hidden = YES;
    return;
    NSString *extName = [thumbnailPath pathExtension];
    
    if([extName isEqualToString:@"pdf"]) {
        NSURL *url = [NSURL fileURLWithPath:thumbnailPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webViewThumbnail loadRequest:request];
        
    } else if([extName isEqualToString:@"gif"]) {
        
        NSString *html = [NSString stringWithFormat:@"<img src ='%@'>", thumbnailPath];
        [self.webViewThumbnail loadHTMLString:html baseURL:nil];
    } else {
        NSLog(@"Load default thumbnail.");
    }
}

//////////////////////////////////////////////////////////////
#pragma mark 下载文档 格式为zip压缩包
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
    NSLog(@"Received data: %@", self.dict[CONTENT_FIELD_ID]);
    [self.downloadConnectionData appendData:data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection{
    /* 下载的数据 */
    NSLog(@"%@", [NSString stringWithFormat:@"下载<#id:%@ url:%@> 成功", self.dict[CONTENT_FIELD_ID], self.dict[CONTENT_FIELD_URL]]);
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.dict[CONTENT_FIELD_ID]];
    NSString *pathName = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    
    BOOL state = [self.downloadConnectionData writeToFile:pathName atomically:YES];
    NSLog(@"%@", [NSString stringWithFormat:@"保存<#id:%@ url:%@> %@", self.dict[CONTENT_FIELD_ID], self.dict[CONTENT_FIELD_URL], state ? @"成功" : @"失败"]);
    
    // 下载zip动作为异步，解压动作应该放在此处
    if(state) [self extractZipFile];
    
    [self checkSlideDownloadBtn];
}
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self.downloadConnectionData setLength:0];
}

/**
 *  DOWNLOAD_DIRNAME/id.zip 解压至 CONTENT_DIRNAME/id
 */
- (void) extractZipFile {
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.dict[CONTENT_FIELD_ID]];
    NSString *zipPath = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    NSString *filesPath = [FileUtils getPathName:SLIDE_DIRNAME];
    NSString *filePath = [filesPath stringByAppendingPathComponent:self.dict[CONTENT_FIELD_ID]];
    
    // 解压
    BOOL state = [SSZipArchive unzipFileAtPath:zipPath toDestination:filePath];
    NSLog(@"解压<#id:%@.zip> %@", self.dict[CONTENT_FIELD_ID], state ? @"成功" : @"失败");
}
@end
