//
//  FileSlide.h
//  WebStructure
//
//  Created by lijunjie on 15-4-14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_ViewSlide_h
#define iSearch_ViewSlide_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class MainViewController;

@interface ViewSlide : UIView

// necessary! then do anything through masterViewController
@property (nonatomic, nonatomic) MainViewController *masterViewController;
@property (nonatomic, nonatomic) BOOL isFavorite;   // 收藏文件: 本地已下载
@property (strong, nonatomic) NSMutableDictionary *dict; // 文件配置信息，json格式


@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnSlideInfo; // 展示文档信息,弹出框
@property (weak, nonatomic) IBOutlet UIButton *btnDownloadOrDisplay;
@property (weak, nonatomic) IBOutlet UIWebView *webViewThumbnail;


// simple operation
@property (strong, nonatomic) NSString *slideID;
@property (strong, nonatomic) NSString *dirName;

// http download variables begin
@property (strong, nonatomic) NSURLConnection *downloadConnection;
@property (strong, nonatomic) NSMutableData   *downloadConnectionData;
// http download variables end


@end


#endif
