//
//  ViewFilePage.h
//  WebView-1
//
//  Created by lijunjie on 15/6/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef WebView_1_ViewFilePage_h
#define WebView_1_ViewFilePage_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class ReViewController;

@interface ViewSlidePage : UIView

@property (weak, nonatomic) IBOutlet ReViewController *reViewController;

@property (weak, nonatomic) IBOutlet UIWebView *webViewThumbnail; // 缩略图
@property (weak, nonatomic) IBOutlet UILabel *labelPageNum; // 第几页
@property (weak, nonatomic) IBOutlet UILabel *labelFrom; // 来自那个文件
@property (weak, nonatomic) IBOutlet UIButton *btnMask; // 来自那个文件

@property (strong, nonatomic) NSString *slidePageName;

- (void)loadThumbnail:(NSString *)thumbnailPath;
- (void)hightLight;
@end

#endif
