//
//  OneViewController.h
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_OneViewController_h
#define iSearch_OneViewController_h

#import <UIKit/UIKit.h>
@class HomeViewController;
@class MainViewController;
/**
 *  HomePage第一栏 - 我的分类
 */
@interface OneViewController : UIViewController
@property (nonatomic , nonatomic) HomeViewController *masterViewController;
@property (nonatomic , nonatomic) MainViewController *mainViewController;
@end


#endif
