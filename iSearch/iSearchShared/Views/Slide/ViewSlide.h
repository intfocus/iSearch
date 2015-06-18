//
//  FileSlide.h
//  WebStructure
//
//  Created by lijunjie on 15-4-14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef WebStructure_ViewSlide_h
#define WebStructure_ViewSlide_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface ViewSlide : UIView

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnFileInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnDownloadOrDisplay;
@property (weak, nonatomic) IBOutlet UIWebView *webViewThumbnail;

@property (nonatomic, nonatomic) BOOL  isFavoriteFile;   // 收藏文件: 本地已下载
@property (strong, nonatomic) NSMutableDictionary *dict; // 文件配置信息，json格式


// http download variables begin
@property (strong, nonatomic) NSURLConnection *downloadConnection;
@property (strong, nonatomic) NSMutableData   *downloadConnectionData;
// http download variables end


/**
 *  UIWebView浏览PDF或GIF文档
 *
 *  @param documentName PDF文档路径
 *  @param webView      UIWebView
 */
- (void)loadThumbnail:(NSString *)thumbnailPath;

@end


#endif
