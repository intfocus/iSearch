//
//  SlideUtils.h
//  iSearch
//
//  Created by lijunjie on 15/6/22.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_SlideUtils_h
#define iSearch_SlideUtils_h
#import <UIKit/UIKit.h>
/**
 *  文档格式: 
 *    1. 已下载文件desc.json
 *    2. 服务器目录数据
 *    3. 离线下载文件列表
 *
 *   三种数据格式，处理逻辑都放在这里。
 */
@interface Slide : NSObject

// attributes
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *pageNum;
@property (nonatomic, strong) NSString *zipSize;
@property (nonatomic, strong) NSString *zipUrl;
@property (nonatomic, strong) NSString *createdDate;
@property (nonatomic, strong) NSMutableArray *pages;

// backup
@property (nonatomic, strong) NSString *descPath;
@property (nonatomic, strong) NSMutableDictionary *descDict;
@property (nonatomic, nonatomic) BOOL isFavorite;

// local fields
@property (nonatomic, strong) NSString *dirName;
@property (nonatomic, nonatomic) BOOL isDisplay;
@property (nonatomic, strong) NSString *localCreatedDate;
@property (nonatomic, strong) NSString *localUpdatedDate;
@property (nonatomic, strong) NSString *typeName;

// instance methods
- (Slide *)initWith:(NSMutableDictionary *)dict Favorite:(BOOL)isFavorite;

@end
#endif
