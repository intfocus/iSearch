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
#import "GMGridViewCell.h"
@class ScanViewController;

@interface ViewSlidePage : UIView<GMGridViewCellProtocol>

@property (weak, nonatomic) IBOutlet ScanViewController *scanViewController;

@property (weak, nonatomic) IBOutlet UILabel *labelPageNum; // 第几页
@property (weak, nonatomic) IBOutlet UILabel *labelFrom; // 来自那个文件
@property (weak, nonatomic) IBOutlet UIButton *btnMask; // 来自那个文件

@property (strong, nonatomic) NSString *slidePageName;
@property (strong, nonatomic) NSString *thumbnailPath;

- (void)hightLight;

- (void)activate;
- (void)deactivate;
- (void)coverUserInterface:(NSNumber *)selectState;
@end

#endif
