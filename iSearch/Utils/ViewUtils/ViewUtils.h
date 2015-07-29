//
//  ViewUtils.h
//  iLogin
//
//  Created by lijunjie on 15/5/6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  说明:
//  处理View相关的代码合集.

#ifndef iLogin_ViewUtils_h
#define iLogin_ViewUtils_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ViewUtils : NSObject

/**
 *  简单的弹出框，用来提示错误、警示信息。只有三部分组成标题、提示信息、按钮标签文字。
 *
 *  @param title       弹出框的标题
 *  @param message     提示错误、警示等信息
 *  @param buttonTitle 按钮标签文字
 */
+ (void) simpleAlertView: delegate Title: (NSString*) title Message: (NSString*) message ButtonTitle: (NSString*) buttonTitle;

// TODO 下面函数已抽出放在DateUtils中， 原引用自ViewUtils的写法需要修改

/**
 *  通用函数: 字符串转日期。
 *
 *  @param str    日期字符串
 *  @param format 日期字符串的日期格式
 *
 *  @return 日期字符串对应的日期
 */
+ (NSDate *) strToDate: (NSString *)str Format:(NSString*) format;

/**
 *  通用函数: 日期转成字符串
 *
 *  @param date   待转换的日期
 *  @param format 转换字符串的格式
 *
 *  @return 指定格式的日期字符串
 */
+ (NSString *) dateToStr: (NSDate *)date Format:(NSString*) format;

+ (UIView *)loadNibClass:(Class)cls;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;


/**
 *  tableViewCell根据内容自定义高度
 *
 *  @param text     cell显示内容
 *  @param width    cell的宽度，以此自适应高度
 *  @param fontSize 内容字段大小
 *
 *  @return CGSize
 */
+ (CGSize)sizeForTableViewCell:(NSString *)text
                         Width:(NSInteger)width
                      FontSize:(NSInteger)fontSize;

/**
 *  弹出框架显示临时性文字
 *
 *  @param view controller.view
 *  @param text 提示文字
 */
+ (void)showPopupView:(UIView *)view Info:(NSString*)text;
@end

#endif
