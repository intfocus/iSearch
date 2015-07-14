//
//  Url.h
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
#import "BaseModel.h"
/**
 *  api链接统一管理
 */
@interface Url : BaseModel

@property (nonatomic, strong) NSString *base;
// 登录
@property (nonatomic, strong) NSString *login;
// 目录
@property (nonatomic, strong) NSString *slides;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *slideDownload;
// 通知公告
@property (nonatomic, strong) NSString *notifications;
// 行为记录
@property (nonatomic, strong) NSString *actionLog;
// 批量下载
@property (nonatomic, strong) NSString *slideList;
@end
