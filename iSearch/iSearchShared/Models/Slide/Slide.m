//
//  SlideUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/22.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Slide.h"

#import "const.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "ContentUtils.h"
#import "ExtendNSLogFunctionality.h"

typedef NS_ENUM(NSInteger, SlideFieldDefaultType) {
    SlideFieldString = 10,
    SlideFieldDate   = 11
};

@implementation Slide
//@synthesize ID,name,title,type,tags,desc,pages,pageNum,createdDate;
//@synthesize zipSize,zipUrl,localCreatedDate,localUpdatedDate;
//@synthesize categoryID,categoryName,typeName;

- (Slide *)init {
    self = [super init];
    
    // some fields necessary
    _dict         = [[NSMutableDictionary alloc] init];
    _type         = CONTENT_SLIDE;
    _name         = @"未设置";
    _desc         = @"未设置";
    _title        = @"未设置";
    _createdDate  = @"";
    _pageNum      = @"0";
    _createdDate  = @"";
    _zipSize      = @"0";
    _categoryID   = @"";
    _categoryName = @"";
    _pages        = [[NSMutableArray alloc] init];
    _slides       = [[NSMutableDictionary alloc] init];
    
    return self;
}
/**
 *  content cache init slide
 *
 *  @param dict cache content
 *
 *  @return slide instance
 */
- (Slide *)initSlide:(NSMutableDictionary *)dict isFavorite:(BOOL)isFavorite {
    self = [super init];

    _isFavorite = isFavorite;
    _isDisplay  = dict[SLIDE_DESC_ISDISPLAY] && [dict[SLIDE_DESC_ISDISPLAY] isEqualToString:@"1"];
    _dict       = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    // server info
    _ID           = dict[CONTENT_FIELD_ID];
    _name         = (NSString *)psd(dict[CONTENT_FIELD_NAME], @"未设置");
    _type         = (NSString *)psd(dict[CONTENT_FIELD_TYPE], @"");
    _desc         = (NSString *)psd(dict[CONTENT_FIELD_DESC], @"未设置");
    _title        = (NSString *)psd(dict[CONTENT_FIELD_TITLE], @"未设置");
    _pageNum      = (NSString *)psd(dict[CONTENT_FIELD_PAGENUM], @"");
    _createdDate  = (NSString *)psd(dict[CONTENT_FIELD_CREATEDATE], @"");
    _zipSize      = (NSString *)psd(dict[CONTENT_FIELD_ZIPSIZE], @"0");
    _categoryID   = (NSString *)psd(dict[CONTENT_FIELD_CATEGORYID], @"");
    _categoryName = (NSString *)psd(dict[CONTENT_FIELD_CATEGORYNAME], @"");
    if(dict[SLIDE_DESC_ORDER]) {
        _pages = dict[SLIDE_DESC_ORDER];
    }
    // ID/DirName is necessary
    [self assignLocalFields:[NSMutableDictionary dictionaryWithDictionary:dict]];
    
    
    return self;
}

- (void)assignLocalFields:(NSMutableDictionary *)dict {
    // base info whatever downloaded
    _dirName  = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    _path     = [FileUtils getPathName:self.dirName FileName:self.ID];
    _descPath = [self.path stringByAppendingPathComponent:SLIDE_CONFIG_FILENAME];
    _dictPath = [self.path stringByAppendingPathComponent:SLIDE_DICT_FILENAME];
    if([self isDownloaded] && !self.isFavorite) {
        _descContent = [NSString stringWithContentsOfFile:self.descPath encoding:NSUTF8StringEncoding error:NULL];
        _descDict1 = [FileUtils readConfigFile:self.descPath];
        NSMutableDictionary *dict = [FileUtils readConfigFile:self.dictPath];
        
        if(!self.pages) {
            _pages = (NSMutableArray *)psd(_descDict1[SLIDE_DESC_ORDER], [[NSMutableArray alloc] init]);
        }
        _isDisplay = (dict[SLIDE_DESC_ISDISPLAY] && [dict[SLIDE_DESC_ISDISPLAY] isEqualToString:@"1"]);
    }
    
    // local fields
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];;
    _localCreatedDate = (NSString *)psd(dict[SLIDE_DESC_LOCAL_CREATEAT],timestamp);
    _localUpdatedDate = (NSString *)psd(dict[SLIDE_DESC_LOCAL_UPDATEAT],timestamp);
    
    if([@[@"1",@"2",@"4"] containsObject:self.type]) {
        _typeName = @"文档";
    } else if ([self.type isEqualToString:@"3"]) {
        _typeName = @"视频";
    } else if ([self.type isEqualToString:@"0"]) {
        _typeName = @"分类";
    } else if ([self.type isEqualToString:@"10000"]) {
        _typeName = @"说明文档";
    } else {
        _typeName = @"未知文档";
    }
}

- (void)updateTimestamp {
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];;
    if(!self.localCreatedDate) { _localCreatedDate = timestamp; }
    _localUpdatedDate = timestamp;
}

#pragma mark - around slide download

- (NSString *)toDownloaded {
    return [FileUtils slideToDownload:self.ID];
}
- (BOOL)isDownloaded:(BOOL)isForce {
    return [FileUtils checkSlideExist:self.ID Dir:self.dirName Force:isForce];
}

- (BOOL)isDownloaded {
    return [self isDownloaded:YES];
}
- (BOOL)isDownloading {
    return [FileUtils isSlideDownloading:self.ID];
}
- (NSString *)downloaded {
    return [FileUtils slideDownloaded:self.ID];
}

#pragma mark - around favorite

- (NSString *)favoritePath {
    return [FileUtils getPathName:FAVORITE_DIRNAME FileName:self.ID];
}

- (BOOL)addToFavorite {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtPath:self.path toPath:[self favoritePath] error:&error];
    NSErrorPrint(error, @"slide#%@ %@ => %@", self.ID, self.path, [self favoritePath]);
    Slide *slide = [[Slide alloc] initSlide:[self refreshFields] isFavorite:YES];
    [slide updateTimestamp];
    [slide save];
    return isNil(error);
}

- (BOOL)isInFavorited:(BOOL)isForce {
    return [FileUtils checkSlideExist:self.ID Dir:FAVORITE_DIRNAME Force:isForce];
}
- (BOOL)isInFavorited {
    return [self isInFavorited:YES];
}
#pragma mark - around write cache

- (NSString *)cacheName {
    return [ContentUtils contentCacheName:self.type ID:self.ID];
}
- (NSString *)cachePath {
    return [FileUtils getPathName:CACHE_DIRNAME FileName:[self cacheName]];
}
- (void)toCached {
    NSMutableDictionary *dict = [self refreshFields];
    [FileUtils writeJSON:dict Into:[self cachePath]];
}

- (BOOL)isCached {
    return [FileUtils checkFileExist:self.cachePath isDir:NO];
}

#pragma mark - instance methods

- (void)save {
    [self refreshFields];
    [self clearRemovePages];

    [FileUtils writeJSON:self.dict Into:self.dictPath];
}

- (void)clearRemovePages {
    // TODO clearRemovePages
}
+ (Slide *)findById:(NSString *)slideID isFavorite:(BOOL)isFavorite {
    NSString *dirName = isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    NSString *dictPath = [FileUtils slideDescPath:slideID Dir:dirName Klass:SLIDE_DICT_FILENAME];
    NSMutableDictionary *dict = [FileUtils readConfigFile:dictPath];
    
   return [[Slide alloc]initSlide:dict isFavorite:isFavorite];
}
+ (Slide *)findByTitleInFavorited:(NSString *)title {
    Slide *slide;
    for(slide in [FileUtils favoriteSlideList1]) {
        if([slide.title isEqualToString:title]) { break; }
    }
    
    return slide;
}

- (BOOL)isValid {
    NSString *pageNum = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:[self.pages count]]];
    return (!self.ID || !self.pages || (!self.pages && [pageNum isEqualToString:self.pageNum]));
}

#pragma mark - edit slide pages

- (NSString *)dictSwpPath {
    return [self.path stringByAppendingPathComponent:SLIDE_CONFIG_SWP_FILENAME];
}
- (NSMutableDictionary *)dictSwp {
    return [FileUtils readConfigFile:[self dictSwpPath]];
}
- (void)enterEditState {
    return [FileUtils writeJSON:[self refreshFields] Into:[self dictSwpPath]];
}

#pragma mark - private methods

- (NSMutableDictionary *) refreshFields {

    // slide's desc field
    _dict[SLIDE_DESC_ID]              = self.ID;
    _dict[SLIDE_DESC_DESC]            = self.desc;
    _dict[CONTENT_FIELD_ID]           = self.ID;
    _dict[CONTENT_FIELD_NAME]         = self.name;
    _dict[CONTENT_FIELD_TYPE]         = self.type;
    if(!isNil(self.pages)) {
    _dict[SLIDE_DESC_ORDER]           = self.pages;
    }

    // server field
    _dict[CONTENT_FIELD_TITLE]        = self.title;
    _dict[CONTENT_FIELD_ZIPSIZE]      = self.zipSize;
    _dict[CONTENT_FIELD_PAGENUM]      = [NSString stringWithFormat:@"%ld", (long)[self.pages count]];
    _dict[CONTENT_FIELD_CATEGORYID]   = self.categoryID;
    _dict[CONTENT_FIELD_CATEGORYNAME] = self.categoryName;
    _dict[CONTENT_FIELD_CREATEDATE]   = self.createdDate;

    // local field
    _dict[SLIDE_DESC_LOCAL_CREATEAT]  = self.localCreatedDate;
    _dict[SLIDE_DESC_LOCAL_UPDATEAT]  = self.localUpdatedDate;
    _dict[SLIDE_DESC_ISDISPLAY]       = (self.isDisplay ? @"1" : @"0");
    _dict[PAGE_FROM_SLIDES]           = (self.slides ? self.slides : [[NSMutableDictionary alloc] init]);
    
    return self.dict;
}
@end