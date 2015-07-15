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
#import "FileUtils+Slide.h"
#import "DateUtils.h"
#import "CacheHelper.h"
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
    if(self = [super init]) {
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
        _thumbailPath = [FileUtils slideThumbnail:@"null" PageID:@"null" Dir:SLIDE_DIRNAME];
    }
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
    _thumbailPath = dict[SLIDE_DESC_THUMBNAIL];
    
    _slides     = dict[PAGE_FROM_SLIDES] ? dict[PAGE_FROM_SLIDES] : [[NSMutableArray alloc] init];
    _folderSize = (NSString *)psd(dict[SLIDE_DESC_FOLDERSIZE], @"");
    
    if(dict[SLIDE_DESC_ORDER]) { _pages = dict[SLIDE_DESC_ORDER]; }
    // ID&DirName is necessary
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
        _descDict1   = [FileUtils readConfigFile:self.descPath];
        dict         = [FileUtils readConfigFile:self.dictPath];
        
        if(!self.pages) {
            _pages = (NSMutableArray *)psd(_descDict1[SLIDE_DESC_ORDER], [[NSMutableArray alloc] init]);
        }

        _isDisplay  = (dict[SLIDE_DESC_ISDISPLAY] && [dict[SLIDE_DESC_ISDISPLAY] isEqualToString:@"1"]);

        _slides     = dict[PAGE_FROM_SLIDES] ? dict[PAGE_FROM_SLIDES] : [[NSMutableArray alloc] init];
        _folderSize = dict[SLIDE_DESC_FOLDERSIZE] ? dict[SLIDE_DESC_FOLDERSIZE] : [self reCaculateSlideFolderSize];
    }
    
    // local fields
    //if(!self.thumbailPath) {
        [self refreshThumbnailPath];
    //}
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];;
    _localCreatedDate = (NSString *)psd(dict[SLIDE_DESC_LOCAL_CREATEAT],timestamp);
    _localUpdatedDate = (NSString *)psd(dict[SLIDE_DESC_LOCAL_UPDATEAT],timestamp);
    
    if([@[@"1",@"2",@"4"] containsObject:self.type]) {
        _typeName = @"文档";
    } else if ([self.type isEqualToString:@"3"]) {
        _typeName = @"视频";
    } else if ([self.type isEqualToString:@"-1"]) {
        _typeName = @"收藏";
    } else if ([self.type isEqualToString:@"10000"]) {
        _typeName = @"说明文档";
    } else if ([self.type isEqualToString:@"0"]) {
        _typeName = @"分类";
    } else {
        _typeName = @"未知文档";
    }
}

- (void)updateTimestamp {
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];;
    if(!self.localCreatedDate) { _localCreatedDate = timestamp; }
    _localUpdatedDate = timestamp;
    _folderSize = [self reCaculateSlideFolderSize];
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
    slide.type = @"-1";
    slide.categoryName= @"收藏";
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

- (NSString *)cachePath {
    return [CacheHelper contentCachePath:self.type ID:self.ID];
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
    [self clearRemovedPages];

    [FileUtils writeJSON:self.dict Into:self.dictPath];
}

- (void)clearRemovedPages {
    // TODO clearRemovePages
}

- (BOOL)isValid {
//    NSString *pageNum = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:[self.pages count]]];
//     || (self.pages && [pageNum isEqualToString:self.pageNum])
    return (!self.ID || !self.pages || !self.type);
}

#pragma mark - edit slide pages

- (NSString *)dictSwpPath {
    return [self.path stringByAppendingPathComponent:SLIDE_CONFIG_SWP_FILENAME];
}
- (void)removeDictSwp {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self dictSwpPath] error:NULL];
}
- (NSMutableDictionary *)dictSwp {
    return [FileUtils readConfigFile:[self dictSwpPath]];
}
- (void)enterDisplayOrScanState {
    return [FileUtils writeJSON:[self refreshFields] Into:[self dictSwpPath]];
}

#pragma mark - class methods
+ (Slide *)findById:(NSString *)slideID isFavorite:(BOOL)isFavorite {
    NSString *dirName = isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;
    NSString *dictPath = [FileUtils slideDescPath:slideID Dir:dirName Klass:SLIDE_DICT_FILENAME];
    NSMutableDictionary *dict = [FileUtils readConfigFile:dictPath];
    
    return [[Slide alloc] initSlide:dict isFavorite:isFavorite];
}

+ (Slide *)findByTitleInFavorited:(NSString *)title {
    Slide *slide;
    for(slide in [FileUtils favoriteSlideList1]) {
        if([slide.title isEqualToString:title]) { break; }
    }
    
    return slide;
}
#pragma mark - private methods
- (NSMutableDictionary *) refreshFields {
    // slide's desc field
    _dict[SLIDE_DESC_ID]              = self.ID;
    _dict[SLIDE_DESC_DESC]            = self.desc;
    _dict[CONTENT_FIELD_DESC]         = self.desc;
    _dict[CONTENT_FIELD_ID]           = self.ID;
    _dict[CONTENT_FIELD_NAME]         = self.name;
    _dict[CONTENT_FIELD_TYPE]         = self.type;
    if(!isNil(self.pages)) {
        _dict[SLIDE_DESC_ORDER]       = self.pages;
    }

    // server field
    _dict[CONTENT_FIELD_TITLE]        = self.title;
    _dict[CONTENT_FIELD_ZIPSIZE]      = self.zipSize;
    _dict[CONTENT_FIELD_PAGENUM]      = (self.pages ? [NSString stringWithFormat:@"%ld", (long)[self.pages count]] : self.pageNum);
    _dict[CONTENT_FIELD_CATEGORYID]   = self.categoryID;
    _dict[CONTENT_FIELD_CATEGORYNAME] = self.categoryName;
    _dict[CONTENT_FIELD_CREATEDATE]   = self.createdDate;

    // local field
    _dict[SLIDE_DESC_LOCAL_CREATEAT]  = self.localCreatedDate;
    _dict[SLIDE_DESC_LOCAL_UPDATEAT]  = self.localUpdatedDate;
    _dict[SLIDE_DESC_ISDISPLAY]       = (self.isDisplay ? @"1" : @"0");
    _dict[PAGE_FROM_SLIDES]           = (self.slides ? self.slides : [[NSMutableDictionary alloc] init]);
    _dict[SLIDE_DESC_FOLDERSIZE]      = self.folderSize;
    _dict[SLIDE_DESC_THUMBNAIL]       = [self.thumbailPath stringByReplacingOccurrencesOfString:[FileUtils getBasePath] withString:@""];
    
    return self.dict;
}

#pragma mark - refresh local fields
- (NSString *)reCaculateSlideFolderSize {
    NSString *fSize = [FileUtils folderSize:self.path];
    NSMutableDictionary *tmpDict = [FileUtils readConfigFile:self.dictPath];
    [tmpDict setObject:fSize forKey:SLIDE_DESC_FOLDERSIZE];
    [FileUtils writeJSON:tmpDict Into:self.dictPath];
    
    return fSize;
}

- (void)refreshThumbnailPath {
    NSString *pageID = [self.pages count] > 0 ? self.pages[0] : @"null";
    _thumbailPath = [FileUtils slideThumbnail:self.ID PageID:pageID Dir:self.dirName];
    //[thumbailPath stringByReplacingOccurrencesOfString:[FileUtils getBasePath] withString:@""];
    
//    NSMutableDictionary *tmpDict = [FileUtils readConfigFile:self.dictPath];
//    [tmpDict setObject:thumbailPath forKey:SLIDE_DESC_THUMBNAIL];
//    [FileUtils writeJSON:tmpDict Into:self.dictPath];
}

@end