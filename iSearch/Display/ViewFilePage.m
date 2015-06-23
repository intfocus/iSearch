//
//  ViewFilePage.m
//  WebView-1
//
//  Created by lijunjie on 15/6/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewFilePage.h"
#import "const.h"
#import "message.h"

@implementation ViewFilePage
@synthesize webViewThumbnail;
@synthesize labelFrom;
@synthesize labelPageNum;


- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        [self configView];
    }
    return self;
}


/**
 *  配置文档页面: 缩略图、第几页、来自那个文档。
 */
- (void) configView {
}
/**
 *  UIWebView浏览PDF或GIF文档
 *
 *  @param documentName PDF文档路径
 *  @param webView      UIWebView
 */
- (void)loadThumbnail:(NSString *)thumbnailPath {
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

- (void)hightLight {
    self.webViewThumbnail.layer.borderWidth = 2.0f;
    self.webViewThumbnail.layer.borderColor = [UIColor colorWithRed:229/255.0 green:118/255.0 blue:127/255.0 alpha:1].CGColor;
}
@end
