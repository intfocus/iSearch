//
//  ViewController.h
//  iReorganize
//
//  Created by lijunjie on 15/5/15.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Foundation/Foundation.h>

@interface ReViewController : UIViewController <UIGestureRecognizerDelegate>

/**
 *  添加标签界面，[取消]或选择标签[完成]时
 */
- (void)dismissPopup;

/**
 *  编辑状态下，选择多个页面后[保存].（自动归档为收藏）
 *  弹出[添加标签]， 选择标签或创建标签，返回标签文件的配置档
 *
 *  并把当前选择的页面拷贝到目标文件ID文件夹下
 *
 *  @param dict 目标文件配置
 */
- (void)actionSavePagesAndMoveFiles:(NSMutableDictionary *)dict;

@end

