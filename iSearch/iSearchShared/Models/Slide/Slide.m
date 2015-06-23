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
@synthesize slideID,name,title,type,tags,desc,pages,pageNum,createdDate;
@synthesize zipSize,zipUrl,localCreatedDate,localUpdatedDate;
@synthesize categoryID,categoryName,typeName;

- (Slide *)initWith:(NSMutableDictionary *)dict Favorite:(BOOL)isFavorite {
    Slide *slide = [super init];
    
    // backup assign values
    slide.configDict  = [NSMutableDictionary dictionaryWithDictionary:dict];
    slide.isFavorite  = isFavorite;

    // deal logic
    NSString *dirName = (isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME);
    slide.dirName     = dirName;
    slide.isDisplay   = NO;// TODO

    
    // when download and add to favorite
    NSString *descPath;
    NSMutableDictionary *descDict;
    // <local desc format>
    if(isFavorite) {
        [slide dealWithDownload:[NSMutableDictionary dictionaryWithDictionary:dict]];
        
        descPath = [FileUtils slideDescPath:slide.slideID Dir:dirName Klass:SLIDE_CONFIG_FILENAME];
        descDict = [FileUtils readConfigFile:descPath];
        slide.isDisplay = (descDict[SLIDE_DESC_ISDISPLAY] == nil);
        
    // <content format>
    } else {
        slide.slideID = slide.configDict[CONTENT_FIELD_ID];
        
        // when download
        if([FileUtils checkSlideExist:slide.slideID Dir:dirName Force:NO]) {
            descPath = [FileUtils slideDescPath:slide.slideID Dir:dirName Klass:SLIDE_CONFIG_FILENAME];
            descDict = [FileUtils readConfigFile:descPath];
            slide.isDisplay = !(descDict[SLIDE_DESC_ISDISPLAY] == nil);

            [slide dealWithDownload:descDict];
        }
        // or not
        else {
            [slide dealWithContent:[NSMutableDictionary dictionaryWithDictionary:dict]];
        }
    }
    
    // common fields
    slide.pageNum          = [slide defaultWhenNil:dict[CONTENT_FIELD_PAGENUM] Type:SlideFieldString];
    slide.createdDate      = [slide defaultWhenNil:dict[CONTENT_FIELD_CREATEDATE] Type:SlideFieldDate];
    slide.zipSize          = [slide defaultWhenNil:dict[CONTENT_FIELD_ZIPSIZE] Type:SlideFieldString];
    slide.categoryID       = [slide defaultWhenNil:dict[CONTENT_FIELD_CATEGORYID] Type:SlideFieldString];
    slide.categoryName     = [slide defaultWhenNil:dict[CONTENT_FIELD_CATEGORYNAME] Type:SlideFieldString];

    // local fields
    slide.localCreatedDate = [slide defaultWhenNil:dict[SLIDE_DESC_LOCAL_CREATEAT] Type:SlideFieldDate];
    slide.localUpdatedDate = [slide defaultWhenNil:dict[SLIDE_DESC_LOCAL_UPDATEAT] Type:SlideFieldDate];
    
    slide.typeName = @"文档";
    return slide;
}

//@synthesize ID,name,title,type,tags,desc,pages,pageNum,createdDate;
//@synthesize zipSize,zipUrl,localCreatedDate,localUpdatedDate;
//@synthesize categoryID,categoryName;
- (Slide *)dealWithDownload:(NSMutableDictionary *)dict {
    Slide *slide = self;
    slide.slideID = dict[SLIDE_DESC_ID];
    slide.name    = dict[SLIDE_DESC_NAME];
    slide.title   = dict[SLIDE_DESC_NAME];
    slide.type    = dict[SLIDE_DESC_TYPE];
    slide.desc    = dict[SLIDE_DESC_DESC];
    slide.pages   = dict[SLIDE_DESC_ORDER];
    
    return slide;
}

- (Slide *)dealWithContent:(NSMutableDictionary *)dict {
    Slide *slide = self;
    slide.slideID = dict[CONTENT_FIELD_ID];
    slide.name    = dict[CONTENT_FIELD_NAME];
    slide.title   = [slide defaultWhenNil:dict[CONTENT_FIELD_TITLE] Type:SlideFieldString];
    slide.type    = dict[CONTENT_FIELD_TYPE];
    slide.desc    = dict[CONTENT_FIELD_DESC];
    slide.pages   = [[NSMutableArray alloc] init];

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

@end