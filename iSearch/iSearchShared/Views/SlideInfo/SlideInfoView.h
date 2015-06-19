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
@interface SlideInfoView : UIView
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDesc;
@property (weak, nonatomic) IBOutlet UILabel *labelEditTime;
@property (weak, nonatomic) IBOutlet UILabel *labelPageNum;
@property (weak, nonatomic) IBOutlet UILabel *labelZipSize;
@property (weak, nonatomic) IBOutlet UILabel *labelCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnDisplay;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToTag;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;

@end

#endif
