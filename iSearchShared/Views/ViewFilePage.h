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


@interface ViewFilePage : UIView

@property (weak, nonatomic) IBOutlet UIWebView *webViewThumbnail; // 缩略图
@property (weak, nonatomic) IBOutlet UILabel *labelPageNum; // 第几页
@property (weak, nonatomic) IBOutlet UILabel *labelFrom; // 来自那个文件

@property (strong, nonatomic) NSMutableDictionary *dict; // 该文件的信息，json格式

- (void)loadThumbnail:(NSString *)thumbnailPath;
- (void)hightLight;
@end

#endif
