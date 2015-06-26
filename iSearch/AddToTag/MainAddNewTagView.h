//
//  MainAddNewTagView.h
//  iSearch
//
//  Created by lijunjie on 15/6/17.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_MainAddNewTagView_h
#define iSearch_MainAddNewTagView_h

#import <UIKit/UIKit.h>
#import "MainViewController.h"
@class Slide;
/**
 *  编辑文档页面时 => 选择页面 => 保存 => 选择标签/创建标签
 */
@interface MainAddNewTagView : UIViewController
// 调用本视图的父controller
@property(nonatomic,nonatomic) UIViewController *masterViewController;
// 标签列表/创建新标签 容器
@property(nonatomic,nonatomic) UIViewController *mainViewController;
// 传递[创建新标签]的信息
@property(nonatomic, strong) Slide *addSlide;
@end
#endif
