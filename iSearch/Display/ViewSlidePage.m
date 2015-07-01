//
//  ViewFilePage.m
//  WebView-1
//
//  Created by lijunjie on 15/6/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewSlidePage.h"
#import "const.h"
#import "message.h"
#import "FileUtils.h"
#import "ReViewController.h"

@implementation ViewSlidePage
@synthesize webViewThumbnail;
@synthesize labelFrom;
@synthesize labelPageNum;

/**
 *  UIWebView浏览PDF或GIF文档
 *
 *  @param documentName PDF文档路径
 *  @param webView      UIWebView
 */
- (void)loadThumbnail:(NSString *)thumbnailPath {
    NSString *html = [NSString stringWithFormat:@"<img src ='%@' style='width:100%%;max-height:100%%;'>", [thumbnailPath lastPathComponent]];
    NSURL *url = [NSURL fileURLWithPath:[thumbnailPath stringByDeletingLastPathComponent]];
    [self.webViewThumbnail loadHTMLString:html baseURL:url];
}

- (void)hightLight {
    self.webViewThumbnail.layer.borderWidth = 2.0f;
    self.webViewThumbnail.layer.borderColor = [UIColor colorWithRed:229/255.0 green:118/255.0 blue:127/255.0 alpha:1].CGColor;
}
@end
