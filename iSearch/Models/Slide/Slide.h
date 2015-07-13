//
//  SlideUtils.h
//  iSearch
//
//  Created by lijunjie on 15/6/22.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_SlideUtils_h
#define iSearch_SlideUtils_h
#import "BaseModel.h"
/**
 *  文档格式: 
 *    1. 已下载文件desc.json
 *    2. 服务器目录数据
 *    3. 离线下载文件列表,字段名称以2为主(categoryName只有这里有)
 *
 *   三种数据格式，处理逻辑都放在这里。
 *
 *   以目录数据为主，如果已下载，则读取[order]，如果已经离线下载，则读取[categoryName]
 */
@interface Slide : BaseModel

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
@property (nonatomic, strong) NSString *folderSize;
@property (nonatomic, strong) NSString *zipUrl;
@property (nonatomic, strong) NSString *createdDate;
@property (nonatomic, strong) NSMutableArray *pages;

// backup
@property (nonatomic, strong) NSString *path; // slide path
@property (nonatomic, strong) NSString *descPath; // slide desc file path
@property (nonatomic, strong) NSString *descContent; // origin desc.json content
@property (nonatomic, strong) NSString *dictPath; 
@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, strong) NSMutableDictionary *descDict1; // origin desc.json json
@property (nonatomic, strong) NSMutableDictionary *cacheDict; // content cache json
@property (nonatomic, strong) NSMutableDictionary *slides; // pages from slides
@property (nonatomic, nonatomic) BOOL isFavorite;

// local fields
@property (nonatomic, nonatomic) BOOL isDisplay;
@property (nonatomic, strong) NSString *thumbailPath;
@property (nonatomic, strong) NSString *dirName;
@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSString *localCreatedDate;
@property (nonatomic, strong) NSString *localUpdatedDate;

// class methods
+ (Slide *)findById:(NSString *)slideID isFavorite:(BOOL)isFavorite;
+ (Slide *)findByTitleInFavorited:(NSString *)title;

// instance methods
- (Slide *)initSlide:(NSMutableDictionary *)dict isFavorite:(BOOL)isFavorite;

- (void)save;
- (void)toCached;
- (void)assignLocalFields:(NSMutableDictionary *)dict;
- (void)updateTimestamp;
- (NSMutableDictionary *)refreshFields;
- (void)refreshThumbnailPath;

- (NSString *)toDownloaded;
- (BOOL)isDownloaded;
- (BOOL)isDownloaded:(BOOL)isForce;
- (BOOL)isDownloading;
- (NSString *)downloaded;

- (NSString *)favoritePath;
- (BOOL)addToFavorite;
- (BOOL)isInFavorited:(BOOL)isForce;
- (BOOL)isInFavorited;

- (void)enterDisplayOrScanState;
- (NSString *)dictSwpPath;
- (void)removeDictSwp;
- (NSMutableDictionary *)dictSwp;

@end
#endif
