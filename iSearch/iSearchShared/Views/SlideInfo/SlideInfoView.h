//
//  SlideInfoView.h
//  iSearch
//
//  Created by lijunjie on 15/6/18.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_SlideInfoView_h
#define iSearch_SlideInfoView_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 *  文档[信息]显示该文档的标题、描述、查看等信息及操作
 */
@interface SlideInfoView : UIViewController
@property (strong, nonatomic) NSMutableDictionary *dict; // 该文件的信息，json格式
@property (nonatomic , nonatomic) UIViewController *masterViewController;

@end

#endif
