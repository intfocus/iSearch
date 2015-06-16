//
//  ShowViewController.m
//  iContent
//
//  Created by lijunjie on 15/5/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShowViewController.h"
#import "FileUtils.h"
#import "const.h"

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
    NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
    NSString *displayId = config[@"DisplayId"];
    NSString *filePath  = [FileUtils getPathName:FILE_DIRNAME FileName:displayId];
    
    //NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL       = [NSURL fileURLWithPath:filePath];
    NSString *htmlPath   = [filePath stringByAppendingPathComponent: @"index.html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    
    // 长按webview返回主界面
    UILongPressGestureRecognizer *tapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.myWeb addGestureRecognizer:tapGesture];
    
    
    // 8. WebView加载本地资源，并以相对路径显示其中的资源引用
    [self.myWeb loadHTMLString:htmlString baseURL:baseURL];
}

- (void)viewTapped:(UIGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end