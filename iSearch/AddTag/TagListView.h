//
//  TagListView.h
//  iSearch
//
//  Created by lijunjie on 15/6/16.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_TagListView_h
#define iSearch_TagListView_h
#import <UIKit/UIKit.h>

@class MainAddNewTagView;
/**
 *  编辑文档页面时 => 选择页面 => 保存 => 
 *      标签列表 => 勾选 => 完成
 *      创建标签 => 输入name/desc => 返回本页，新创建为默认勾选项
 */
@interface TagListView : UIViewController

- (void)dismissPopup;

@property(nonatomic,weak)MainAddNewTagView *masterViewController;

@end

#endif
