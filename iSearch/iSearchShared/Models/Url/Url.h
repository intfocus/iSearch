//
//  Url.h
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  api链接统一在些管理
 */
@interface Url : NSObject

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
@property (nonatomic, strong) NSString *action;
// 批量下载
@property (nonatomic, strong) NSString *slideList;

// class methods
+ (NSString *)login;
+ (NSString *)slides;
+ (NSString *)categories;
+ (NSString *)slideDownload;
+ (NSString *)slideList;
+ (NSString *)notifications;
+ (NSString *)action;
@end
