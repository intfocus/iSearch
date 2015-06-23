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
@interface Slide : NSObject {
    NSString *sid;
    NSString *type;
    NSString *name;
    NSString *title;
    NSString *desc;
    NSString *tags;
    NSMutableArray *pages;
    NSString *categoryID;
    NSString *categoryName;
    NSString *pageNum;
    NSString *zipSize;
    NSString *createdDate;
    NSString *localCreatedDate;
    NSString *localUpdatedDate;
}
@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *sid;
@property(nonatomic,copy) NSString *sid;
@end
#endif
