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
#import "ExtendNSLogFunctionality.h"

typedef NS_ENUM(NSInteger, SlideFieldDefaultType) {
    SlideFieldString = 10,
    SlideFieldDate   = 11
};

@implementation Slide
//@synthesize ID,name,title,type,tags,desc,pages,pageNum,createdDate;
//@synthesize zipSize,zipUrl,localCreatedDate,localUpdatedDate;
//@synthesize categoryID,categoryName,typeName;

- (Slide *)initWith:(NSMutableDictionary *)dict Favorite:(BOOL)isFavorite {
    self = [super init];
    
    // backup assign values
    _descDict    = [NSMutableDictionary dictionaryWithDictionary:dict];
    _assignDict  = [NSMutableDictionary dictionaryWithDictionary:dict];
    _isFavorite  = isFavorite;

    // deal logic
    _dirName   = (isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME);
    _isDisplay = NO;// TODO

    /*
     * assign server value
     */
    // will check by [updateLocalFields]
    _ID = psd(dict[CONTENT_FIELD_ID],dict[SLIDE_DESC_ID]);
    if(self.ID == nil) {
        NSLog(@"Bug: Slide#id is nil");
        abort();
    }
    
    _name         = dict[CONTENT_FIELD_NAME];
    _type         = dict[CONTENT_FIELD_TYPE];
    _desc         = dict[CONTENT_FIELD_DESC];
    _title        = dict[CONTENT_FIELD_TITLE];
    
    // make attribute value not nil
    _pageNum      = psd(dict[CONTENT_FIELD_PAGENUM], @"");
    _createdDate  = psd(dict[CONTENT_FIELD_CREATEDATE], @"");
    _zipSize      = psd(dict[CONTENT_FIELD_ZIPSIZE], @"");
    _categoryID   = psd(dict[CONTENT_FIELD_CATEGORYID], @"");
    _categoryName = psd(dict[CONTENT_FIELD_CATEGORYNAME], @"");
    
    [self assignLocalFields];
    
    _path = [FileUtils getPathName:self.dirName FileName:self.ID];
    _descPath = [self.path stringByAppendingPathComponent:SLIDE_CONFIG_FILENAME];
    
    if(isFavorite || self.isDownload) {
        _descDict = [FileUtils readConfigFile:self.descPath];
        _isDisplay = (self.descDict[SLIDE_DESC_ISDISPLAY] != nil && [self.descDict[SLIDE_DESC_ISDISPLAY] isEqualToString:@"1"]);
    }
    // reassign _descDict when download
    // assign default value when nil
    [self uploadLocalFields];
    
    // local fields
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];;
    _localCreatedDate = psd(dict[SLIDE_DESC_LOCAL_CREATEAT],timestamp);
    _localUpdatedDate = psd(dict[SLIDE_DESC_LOCAL_UPDATEAT],timestamp);
    
    if([self.type isEqualToString:@"1"]) {
        _typeName = @"文档";
    } else if ([self.type isEqualToString:@"2"]) {
        _typeName = @"幻灯片";
    } else {
        _typeName = @"文档";
        NSLog(@"Unkown Slide#type: %@", self.type);
    }

    
    return self;
}

#pragma mark - instance methods

- (void)cached:(NSString *)cacheName {
    NSString *cachePath = [FileUtils getPathName:CONTENT_DIRNAME FileName:cacheName];
    NSMutableDictionary *dict = [self refreshFields];
    [FileUtils writeJSON:dict Into:cachePath];
}

- (BOOL)isDownload {
    return [FileUtils checkSlideExist:self.ID Dir:self.dirName Force:NO];
}


- (void)save {
    [self refreshFields];
    
    if([self isDownload] && ![self isValid]) {
        NSLog(@"pages is not valid - %@", self.descPath);
    }
    [FileUtils writeJSON:self.descDict Into:self.descPath];
}

- (NSString *)inspect {
    return [NSString stringWithFormat:@"#<Slide ID: %@, name: %@, type: %@, desc: %@, pages: %@, title: %@, zipSize: %@, pageNum: %@, categoryID: %@, categoryName: %@, createdDate: %@, localCreatedDate: %@, localUpdatedDate: %@, isDisplay: %d", self.ID, self.name, self.type, self.desc, self.pages, self.title, self.zipSize, self.pageNum, self.categoryID, self.categoryName, self.createdDate, self.localCreatedDate, self.localUpdatedDate, self.isDisplay];
}

- (NSString *)to_s {
    return [self inspect];
}

- (BOOL)isValid {
    NSString *pageNum = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:[self.pages count]]];
    return (self.pages != nil && [pageNum isEqualToString:self.pageNum]);
}
#pragma mark - private methods
- (NSMutableDictionary *) refreshFields {
    // slide's desc field
    _descDict[SLIDE_DESC_ID]    = self.ID;
    _descDict[SLIDE_DESC_NAME]  = self.name;
    _descDict[SLIDE_DESC_TYPE]  = self.type;
    _descDict[SLIDE_DESC_DESC]  = self.desc;
    // 目录中文档未下载缓存时self.pages为nil
    _descDict[SLIDE_DESC_ORDER] = (self.pages == nil ? [[NSMutableArray alloc] init] : self.pages);
    
    // server field
    _descDict[CONTENT_FIELD_TITLE]        = self.title;
    _descDict[CONTENT_FIELD_ZIPSIZE]      = self.zipSize;
    _descDict[CONTENT_FIELD_PAGENUM]      = self.pageNum;
    _descDict[CONTENT_FIELD_CATEGORYID]   = self.categoryID;
    _descDict[CONTENT_FIELD_CATEGORYNAME] = self.categoryName;
    _descDict[CONTENT_FIELD_CREATEDATE]   = self.createdDate;
    
    // local field
    _descDict[SLIDE_DESC_LOCAL_CREATEAT]  = self.localCreatedDate;
    _descDict[SLIDE_DESC_LOCAL_UPDATEAT]  = self.localUpdatedDate;
    _descDict[SLIDE_DESC_ISDISPLAY]       = (self.isDisplay ? @"1" : @"0");
    
    return self.descDict;
}

/**
 *  离线下载、目录加载时，会得到文档的服务器信息
 *  并上本地信息就是完整的文档信息
 *  （服务器信息优先级高于本地信息）
 */
- (void)uploadLocalFields {
    if(self.name == nil)
        self.name = psd(self.descDict[SLIDE_DESC_NAME], @"");
    if(self.title == nil)
        self.title = psd(self.descDict[SLIDE_DESC_NAME], @"");
    if(self.type == nil)
        self.type = psd(self.descDict[SLIDE_DESC_TYPE], @"");
    if(self.desc == nil)
        self.desc = psd(self.descDict[SLIDE_DESC_DESC], @"无描述");
    if(self.pages == nil)
        self.pages = self.descDict[SLIDE_DESC_ORDER];
    if(self.pages == nil)
        self.pages = [[NSMutableArray alloc] init];
}

- (void)assignLocalFields {
    if(self.name == nil && self.descDict[SLIDE_DESC_NAME] != nil)
        self.name = self.descDict[SLIDE_DESC_NAME];
    if(self.title == nil && self.descDict[SLIDE_DESC_NAME] != nil)
        self.title = self.descDict[SLIDE_DESC_NAME];
    if(self.type == nil && self.descDict[SLIDE_DESC_TYPE] != nil)
        self.type = self.descDict[SLIDE_DESC_TYPE];
    if(self.desc == nil && self.descDict[SLIDE_DESC_DESC] != nil)
        self.desc =  self.descDict[SLIDE_DESC_DESC];
    if(self.pages == nil && self.descDict[SLIDE_DESC_ORDER] != nil)
        self.pages = self.descDict[SLIDE_DESC_ORDER];
}
@end