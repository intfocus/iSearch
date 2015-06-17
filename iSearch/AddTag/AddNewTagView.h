//
//  AddToFavoriteView.h
//  iSearch
//
//  Created by lijunjie on 15/6/16.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_AddNewTagView_h
#define iSearch_AddNewTagView_h

#import <UIKit/UIKit.h>

@class MainAddNewTagView;
/**
 *  创建新标签 => 完成/取消
 */
@interface AddNewTagView : UIViewController

@property(nonatomic,weak)MainAddNewTagView *masterViewController;

@end


#endif
