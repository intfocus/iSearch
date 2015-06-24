//
//  OfflineCell.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OfflineCell.h"
#import "Slide.h"
#import "const.h"
#import "FileUtils.h"
#import "SSZipArchive.h"
#import "PopupView.h"
#import "ExtendNSLogFunctionality.h"
#import "DisplayViewController.h"
#import "OfflineViewController.h"

#define OFFLINE_DOWNLOAD_URL @"OFFLINE_DOWNLOAD_URL"

@interface OfflineCell()
@property (nonatomic, nonatomic) PopupView *popupView;
@property (nonatomic, nonatomic) DisplayViewController *displayViewController;
@property (nonatomic, nonatomic) Slide *slide;
@end

@implementation OfflineCell

- (void) setDict:(NSMutableDictionary *)dict {
    _dict = dict;
    
    if(self.slide == nil) {
        [self columnToContent];
        self.slide = [[Slide alloc]initWith:self.dict Favorite:NO];
    }
    
    [self checkSlideDownloadBtn];
}

#pragma mark - control action

- (IBAction)actionBtnDownloadOrDisplay:(UIButton *)sender {
    if([FileUtils checkSlideExist:self.slide.ID Dir:SLIDE_DIRNAME Force:NO]) {
        if([FileUtils checkSlideExist:self.slide.ID Dir:SLIDE_DIRNAME Force:YES]) {
            [self performSelector:@selector(actionDisplaySlide:) withObject:self afterDelay:0.0f];
        } else {
            [self showPopupView: @"文档配置信息有误"];
        }
    } else {
        NSString *downloadUrl = [NSString stringWithFormat:@"%@%@?%@=%@", BASE_URL, CONTENT_DOWNLOAD_URL_PATH, CONTENT_PARAM_FILE_DWONLOADID, self.dict[OFFLINE_COLUMN_FILEID]];
        [self.dict setObject:downloadUrl forKey:OFFLINE_DOWNLOAD_URL];
        
        self.labelDownloadState.text = @"下载中...";
        [self downloadZip:downloadUrl];
    }
}

/**
 *  演示文稿；
 *  离线列表文档，若下载都在SLIDE_DIRNAME中；
 *  内存管理: 谁开启DisplayViewController谁关闭，分配callingController1
 *
 *  @return 演示界面
 */
- (IBAction) actionDisplaySlide:(id)sender {
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
    NSNumber *displayType = [NSNumber numberWithInt:(SlideTypeSlide)];
    NSNumber *displayFrom = [NSNumber numberWithInt:(DisplayFromOfflineCell)];
    [configDict setObject:self.slide.ID forKey:CONTENT_KEY_DISPLAYID];
    [configDict setObject:displayType forKey:SLIDE_DISPLAY_TYPE];
    [configDict setObject:displayFrom forKey:SLIDE_DISPLAY_FROM];
    [FileUtils writeJSON:configDict Into:configPath];
    
    if(self.displayViewController == nil) {
        self.displayViewController = [[DisplayViewController alloc] init];
        self.displayViewController.callingController1 = self;
    }
    [self.offlineViewController presentViewController:self.displayViewController animated:NO completion:nil];
}
/**
 *  释放DisplayViewController内存
 */
- (void)dismissDisplayViewController {
    _displayViewController = nil;
    NSLog(@"dismissed here - OfflineCell");
}

#pragma mark - assistant methods
- (void) showPopupView: (NSString*) text {
    if(self.popupView == nil) {
        self.popupView = [[PopupView alloc]initWithFrame:CGRectMake(self.offlineViewController.view.frame.size.width/4, self.offlineViewController.view.frame.size.height/4, self.offlineViewController.view.frame.size.width/2, self.offlineViewController.view.frame.size.height/2)];
        
        self.popupView.ParentView = self.offlineViewController.view;
    }
    [self.popupView setText: text];
    [self.offlineViewController.view addSubview:self.popupView];
}

/**
 *  检测 CONTENT_DIRNAME/id 是否存在
 */
- (void) checkSlideDownloadBtn {
    NSString *imageName, *downloadState;
    if([FileUtils checkSlideExist:self.slide.ID Dir:SLIDE_DIRNAME Force:NO]){
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
    if(state) {
        [self extractZipFile];
        [self reloadSlideDesc];
        [self checkSlideDownloadBtn];
    }
    
    [self checkSlideDownloadBtn];
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
    NSString *filesPath = [FileUtils getPathName:SLIDE_DIRNAME];
    NSString *filePath = [filesPath stringByAppendingPathComponent:self.slide.ID];
    
    // 解压
    BOOL state = [SSZipArchive unzipFileAtPath:zipPath toDestination:filePath];
    NSLog(@"%@", [NSString stringWithFormat:@"下载#%@ - %@", self.dict[OFFLINE_DOWNLOAD_URL], state ? @"成功" : @"失败"]);
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
        NSLog(@"Bug: Slide#ID=%@ desc.json@order is nil.", self.slide.ID);
    }
}

- (void)columnToContent {
    self.dict[CONTENT_FIELD_ID]           = self.dict[OFFLINE_COLUMN_FILEID];
    self.dict[CONTENT_FIELD_NAME]         = self.dict[OFFLINE_COLUMN_NAME];
    self.dict[CONTENT_FIELD_TITLE]        = self.dict[OFFLINE_COLUMN_TITLE];
    self.dict[CONTENT_FIELD_TYPE]         = self.dict[OFFLINE_COLUMN_TYPE];
    self.dict[CONTENT_FIELD_DESC]         = self.dict[OFFLINE_COLUMN_DESC];
    self.dict[CONTENT_FIELD_PAGENUM]      = self.dict[OFFLINE_COLUMN_PAGENUM];
    self.dict[CONTENT_FIELD_CATEGORYID]   = psd(self.dict[OFFLINE_COLUMN_CATEGORYID],@"1");
    self.dict[CONTENT_FIELD_CATEGORYNAME] = self.dict[OFFLINE_COLUMN_CATEGORYNAME];
    self.dict[CONTENT_FIELD_ZIPSIZE]      = self.dict[OFFLINE_COLUMN_ZIPSIZE];
    self.dict[CONTENT_FIELD_CREATEDATE]   = psd(self.dict[OFFLINE_COLUMN_CREATEDATE],@"hh");
}
@end