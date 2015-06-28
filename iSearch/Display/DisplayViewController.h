//
//  ViewController.h
//  WebView-1
//
//  Created by lijunjie on 15-4-1.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintView.h"
@class OfflineCell;
@class ViewSlide;
@class Slide;

@interface DisplayViewController : UIViewController {
     PaintView *paintView;
}

@property (nonatomic, nonatomic) OfflineCell *callingController1; // 调出者
@property (nonatomic, nonatomic) ViewSlide   *callingController2; // 调出者
@property (nonatomic, nonatomic) BOOL   presentReViewController; // 调出者


- (void)actionSavePagesAndMoveFiles:(Slide *)targetSlide;
- (void)dismissDisplayViewController;
- (void)dismissPopupAddToTag;

@end

