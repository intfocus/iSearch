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
    _descDict  = [NSMutableDictionary dictionaryWithDictionary:dict];
    _isFavorite  = isFavorite;

    // deal logic
    _dirName = (isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME);
    _isDisplay = NO;// TODO

    
    // when download and add to favorite
    NSString *descPath;
    NSMutableDictionary *descDict;
    // local desc format
    if(isFavorite) {
        [self dealWithDownload:[NSMutableDictionary dictionaryWithDictionary:dict]];
        
        _descPath = [FileUtils slideDescPath:self.ID Dir:self.dirName Klass:SLIDE_CONFIG_FILENAME];
        _descDict = [FileUtils readConfigFile:descPath];
        _isDisplay = (descDict[SLIDE_DESC_ISDISPLAY] == nil);
        
    // content format
    } else {
        NSMutableDictionary *contentDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        _ID = dict[CONTENT_FIELD_ID];
        
        // when download
        if([FileUtils checkSlideExist:self.ID Dir:self.dirName Force:NO]) {
            _descPath = [FileUtils slideDescPath:self.ID Dir:self.dirName Klass:SLIDE_CONFIG_FILENAME];
            _descDict = [FileUtils readConfigFile:self.descPath];
            _isDisplay = (self.descDict[SLIDE_DESC_ISDISPLAY] != nil);

            [self dealWithDownload:descDict];
        }
        // or not
        else {
            [self dealWithContent:[NSMutableDictionary dictionaryWithDictionary:dict]];
        }
    }
    
    // common fields
    _pageNum          = [self defaultWhenNil:dict[CONTENT_FIELD_PAGENUM] Type:SlideFieldString];
    _createdDate      = [self defaultWhenNil:dict[CONTENT_FIELD_CREATEDATE] Type:SlideFieldDate];
    _zipSize          = [self defaultWhenNil:dict[CONTENT_FIELD_ZIPSIZE] Type:SlideFieldString];
    _categoryID       = [self defaultWhenNil:dict[CONTENT_FIELD_CATEGORYID] Type:SlideFieldString];
    _categoryName     = [self defaultWhenNil:dict[CONTENT_FIELD_CATEGORYNAME] Type:SlideFieldString];

    // local fields
    _localCreatedDate = [self defaultWhenNil:dict[SLIDE_DESC_LOCAL_CREATEAT] Type:SlideFieldDate];
    _localUpdatedDate = [self defaultWhenNil:dict[SLIDE_DESC_LOCAL_UPDATEAT] Type:SlideFieldDate];
    
    _typeName = @"文档";
    return self;
}

//@synthesize ID,name,title,type,tags,desc,pages,pageNum,createdDate;
//@synthesize zipSize,zipUrl,localCreatedDate,localUpdatedDate;
//@synthesize categoryID,categoryName;
- (Slide *)dealWithDownload:(NSMutableDictionary *)dict {
    Slide *slide = self;
    slide.ID    = dict[SLIDE_DESC_ID];
    slide.name  = dict[SLIDE_DESC_NAME];
    slide.title = dict[SLIDE_DESC_NAME];
    slide.type  = dict[SLIDE_DESC_TYPE];
    slide.desc  = dict[SLIDE_DESC_DESC];
    slide.pages = dict[SLIDE_DESC_ORDER];
    
    return slide;
}

#pragma mark - instance methods

- (Slide *)dealWithContent:(NSMutableDictionary *)dict {
    Slide *slide = self;
    slide.ID    = dict[CONTENT_FIELD_ID];
    slide.name  = dict[CONTENT_FIELD_NAME];
    slide.title = [slide defaultWhenNil:dict[CONTENT_FIELD_TITLE] Type:SlideFieldString];
    slide.type  = dict[CONTENT_FIELD_TYPE];
    slide.desc  = dict[CONTENT_FIELD_DESC];
    slide.pages = [[NSMutableArray alloc] init];

    return slide;
}

- (NSString *)defaultWhenNil:(NSString *)fieldValue Type:(NSInteger)fieldType {
    if(fieldValue != nil) {
        return fieldValue;
    }
    
    switch (fieldType) {
        case SlideFieldString: {
            fieldValue = @"";
        }
            break;
        case SlideFieldDate: {
            fieldValue = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];
        }
            break;
        default: {
            fieldValue = @"";
            NSLog(@"Bug:fieldValue#%@, fieldType:%ld", fieldValue, (long)fieldType);
        }
            break;
    }
    return fieldValue;
}

- (void)save {
    // slide's desc field
    _descDict[SLIDE_DESC_ID]    = self.ID;
    _descDict[SLIDE_DESC_NAME]  = self.name;
    _descDict[SLIDE_DESC_TYPE]  = self.type;
    _descDict[SLIDE_DESC_DESC]  = self.desc;
    _descDict[SLIDE_DESC_ORDER] = self.pages;

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
    _descDict[SLIDE_DESC_ISDISPLAY]       = (self.isDisplay ? @"1" : nil);
    
    [FileUtils writeJSON:self.descDict Into:self.descPath];
}@end