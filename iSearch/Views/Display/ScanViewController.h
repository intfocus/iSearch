//
//  ViewController.h
//  iReorganize
//
//  Created by lijunjie on 15/5/15.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Slide;
@class DisplayViewController;

@interface ScanViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic , nonatomic) DisplayViewController *masterViewController;

/**
 *  添加标签界面，[取消]或选择标签[完成]时
 */
- (void)dismissPopupAddToTag;
- (void)dismissReViewController;
- (void)actionSavePagesAndMoveFiles:(Slide *)targetSlide;

@end

