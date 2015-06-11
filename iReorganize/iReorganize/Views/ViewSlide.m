//
//  FileSlide.m
//  WebStructure
//
//  Created by lijunjie on 15-4-14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewSlide.h"
#import "FileUtils.h"
#import "const.h"
#import "message.h"
#import "SSZipArchive.h"

@implementation ViewSlide
@synthesize slideTitle;


- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        [self checkSlideDownloadBtn];
    }
    return self;
}

- (IBAction) slideClick:(id)sender {
    if(![FileUtils checkSlideExist:self.dict[@"id"]]) {
        [sender setTitle:SLIDE_BTN_DOWNLOADING forState:UIControlStateNormal];
        [self downloadZip:self.dict[@"url"]];
    //} else {
    //     演示文稿功能在主界面代码中处理
    }
}

/**
 *  检测 CONTENT_DIRNAME/id 是否存在
 */
- (void) checkSlideDownloadBtn {
    if([FileUtils checkSlideExist:self.dict[@"id"]]) {
        [self.slideDownload setTitle:SLIDE_BTN_DETAIL forState:UIControlStateNormal];
    } else {
        [self.slideDownload setTitle:SLIDE_BTN_DOWNLOAD forState:UIControlStateNormal];
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
    NSURL    *url = [NSURL URLWithString:urlString];
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
    NSLog(@"Received data: %@", self.dict[@"id"]);
    [self.downloadConnectionData appendData:data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection{
    /* 下载的数据 */
    NSLog(@"%@", [NSString stringWithFormat:@"下载<#id:%@ url:%@> 成功", self.dict[@"id"], self.dict[@"url"]]);
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.dict[@"id"]];
    NSString *pathName = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    
    BOOL state = [self.downloadConnectionData writeToFile:pathName atomically:YES];
    NSLog(@"%@", [NSString stringWithFormat:@"保存<#id:%@ url:%@> %@", self.dict[@"id"], self.dict[@"url"], state ? @"成功" : @"失败"]);
    
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
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.dict[@"id"]];
    NSString *zipPathName = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    NSString *filesPathName = [FileUtils getPathName:FILE_DIRNAME];
    
    // 解压
    BOOL state = [SSZipArchive unzipFileAtPath:zipPathName toDestination:filesPathName];
    NSLog(@"%@", [NSString stringWithFormat:@"解压<#id:%@.zip> %@", self.dict[@"id"], state ? @"成功" : @"失败"]);
}
@end
