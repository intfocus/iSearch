//
//  HomeViewController.h
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_HomeViewController_h
#define iSearch_HomeViewController_h
#import "RightSideViewController.h"
/**
 *  导航栏中[首页]联动的右侧界面
 */
@interface HomeViewController : RightSideViewController<UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSMutableDictionary *dict;

/**
 *  收藏页面，点击文件[明细]，弹出框显示文档信息，及操作
 */
- (void)actionPopupSlideInfo:(NSMutableDictionary *)dict;
/**
 *  关闭弹出框；
 *  由于弹出框没有覆盖整个屏幕，所以关闭弹出框时，不会触发回调事件[viewDidAppear]。
 *  强制刷新本界面；
 */
- (void)dismissPopup;
@end

#endif
