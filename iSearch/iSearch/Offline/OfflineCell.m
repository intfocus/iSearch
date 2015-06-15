//
//  OfflineCell.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OfflineCell.h"
#import "const.h"
#import "FileUtils.h"
#import "SSZipArchive.h"


@implementation OfflineCell
/**
 *  TableViewCell自身函数，自定义操作放在这里
 *
 *  @param reuseIdentifier <#reuseIdentifier description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initControls];
        NSLog(@"it should be called.");
    }
    return self;
}

- (void) initControls {
    NSString *fileID = self.dict[OFFLINE_COLUMN_FILEID];
    NSString *filePath = [FileUtils getPathName:FILE_DIRNAME FileName:fileID];

    NSString *imageName = [[NSString alloc] init];
    NSString *downloadState = @"未下载";
    if([FileUtils checkFileExist:filePath isDir:false]) {
        imageName = @"ToView.png";
        downloadState = @"已下载";
    } else {
        imageName = @"ToDownload.png";
        downloadState = @"未下载";
    }
    self.labelDownloadState.text = downloadState;
    UIImage *image = [UIImage imageNamed:imageName];
    [self.btnDownloadOrView setImage:image forState:UIControlStateNormal];
    self.btnDownloadOrView.frame = CGRectMake(self.btnDownloadOrView.frame.origin.x,
                                              self.btnDownloadOrView.frame.origin.y,
                                              image.size.width,
                                              image.size.height);
    
}

- (IBAction) slideClick:(id)sender {
    if(![FileUtils checkSlideExist:self.dict[OFFLINE_COLUMN_FILEID] Force:NO]) {
        NSString *downloadUrl = [NSString stringWithFormat:@"%@%@?%@=%@", BASE_URL, CONTENT_DOWNLOAD_URL_PATH, CONTENT_PARAM_FILE_DWONLOADID, self.dict[OFFLINE_COLUMN_FILEID]];
        [self downloadZip:downloadUrl];
        //} else {
        //     演示文稿功能在主界面代码中处理
    }
}

/**
 *  检测 CONTENT_DIRNAME/id 是否存在
 */
- (void) checkSlideDownloadBtn {
    if([FileUtils checkSlideExist:self.dict[OFFLINE_COLUMN_FILEID] Force:NO]) {
        self.labelDownloadState.text = @"已下载";
    } else {
        self.labelDownloadState.text = @"未下载";
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
- (void) downloadZip: (NSString *) urlPath {
    NSURL *url = [NSURL URLWithString:urlPath];
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
    NSLog(@"connection %@", error);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.downloadConnectionData appendData:data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection{
    /* 下载的数据 */
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.dict[OFFLINE_COLUMN_FILEID]];
    NSString *pathName = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    
    BOOL state = [self.downloadConnectionData writeToFile:pathName atomically:YES];
    
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
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", self.dict[OFFLINE_COLUMN_FILEID]];
    NSString *zipPath = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    NSString *filesPath = [FileUtils getPathName:FILE_DIRNAME];
    NSString *filePath = [filesPath stringByAppendingPathComponent:self.dict[OFFLINE_COLUMN_FILEID]];
    
    // 解压
    BOOL state = [SSZipArchive unzipFileAtPath:zipPath toDestination:filePath];
    NSLog(@"%@", [NSString stringWithFormat:@"解压<#id:%@.zip> %@", self.dict[OFFLINE_COLUMN_FILEID], state ? @"成功" : @"失败"]);
    [self initControls];
}
@end