//
//  FileUtils+Slide.m
//  iSearch
//
//  Created by lijunjie on 15/7/9.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileUtils+Slide.h"
#import "DateUtils.h"
#import "Slide.h"
#import "ExtendNSLogFunctionality.h"

@implementation FileUtils (Slide)
/**
 *  收藏文件列表（FAVORITE_DIRNAME）
 *
 *  @return @{FILE_DESC_KEY: }
 */
+ (NSMutableArray *) favoriteSlideList1 {
    NSMutableArray *slideList = [[NSMutableArray alloc]init];
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 重组内容文件名称格式: r150501
    NSString *favoritesPath = [FileUtils getPathName:FAVORITE_DIRNAME];
    NSArray *slides = [fileManager contentsOfDirectoryAtPath:favoritesPath error:&error];
    
    NSString *slideID;
    Slide *slide;
    for(slideID in slides) {
        slide = [Slide findById:slideID isFavorite:YES];
        if([slide isInFavorited]) { [slideList addObject:slide]; }
    }
    
    return slideList;
}

/** 创建新标签
 *
 * step1: 判断该标签名称是否存在
 *      创建FileID, 格式: r150501010101
 *      初始化重组内容文件的配置档
 *  step2.1 若不存在,则创建
 *  @param tagName 输入的新标签名称
 *
 *  结论: 调用过本函数，FILE_DIRNAME/FileID/desc.json 必须存在
 *       后继操作: 拷贝页面文件及文件夹
 *
 *  @param tagName   标签名称
 *  @param tagDesc   标签描述
 *  @param timestamp 时间戳 （创建新FileID时使用)
 */
+ (Slide *)findOrCreateTag:(NSString *)tagName
                      Desc:(NSString *)tagDesc
                 Timestamp:(NSString *)timestamp {
    tagName = [tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // step1: 判断该标签名称是否存在
    Slide *slide;
    BOOL isExist = NO;
    for(slide in [FileUtils favoriteSlideList1]) {
        if([slide.title isEqualToString:tagName]) { isExist = YES; break; }
    }
    
    
    // step1.1 若不存在,则创建
    if(!isExist) {
        slide = [[Slide alloc] init];
        // 初始化重组内容文件的配置档
        // 创建FileID, 格式: r150501010101
        NSString *newSlideID = [NSString stringWithFormat:@"r%@", timestamp];
        slide.ID = newSlideID;
        // base info
        slide.isFavorite = YES;
        slide.type = CONTENT_SLIDE;
        
        
        // slideID需要唯一
        while([slide isInFavorited]) {
            timestamp = [DateUtils dateToStr:[NSDate date] Format:NEW_TAG_FORMAT];
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:slide.favoritePath withIntermediateDirectories:YES attributes:nil error:nil];
        
        slide.name  = tagName;
        slide.title = tagName;
        slide.desc  = tagDesc;
        // step2.2 收藏夹中原已存在，修改原配置档，复制页面
    } else {
        // 重置name/desc
        slide.name  = tagName;
        slide.title = tagName;
        slide.desc  = tagDesc;
    }
    slide.type         = @"-1";
    slide.categoryName = @"收藏";
    [slide assignLocalFields:[[NSMutableDictionary alloc]init]];
    [slide updateTimestamp];
    [slide save];
    
    return slide;
}


/**
 *  根据文件名称在收藏夹中查找文件描述档
 *
 *  @param fileName 文件名称
 *
 *  @return descJSOn
 */
+ (NSMutableDictionary *) getDescFromFavoriteWithName:(NSString *)fileName {
    NSMutableArray *slideList = [FileUtils favoriteSlideList1];
    Slide *slide;
    for(slide in slideList) {
        if(slide.title && [slide.title isEqualToString:fileName]) {
            break;
        }
    }
    
    return [slide refreshFields];
}



/**
 *  拷贝文件FILE_DIRNAME/fromFileId的页面pageName至文件FAVORITE_DIRNAME/toFileId下
 *  FILE_DIRNAME/fileId/{fileId_pageId.html, desc.json, fileID_pageID/}
 *
 *  @param pageName   页面名称fildId_pageId.html
 *  @param fromFileId 源文件id
 *  @param toFileId   目标文件id
 */
+ (void)copyFilePage:(NSString *)pName
           FromSlide:(Slide *)fromSlide
             ToSlide:(Slide *)toSlide {
    NSError *error;
    NSString *pagePath, *newPagePath, *imagePath, *newImagePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 复制html文件
    pagePath = [fromSlide.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", pName, PAGE_HTML_FORMAT]];
    newPagePath = [toSlide.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", pName, PAGE_HTML_FORMAT]];
    [fileManager copyItemAtPath:pagePath toPath:newPagePath error:&error];
    NSErrorPrint(error, @"copy page html from %@ -> %@", pagePath, newPagePath);
    
    // 复制文件夹
    imagePath = [fromSlide.path stringByAppendingPathComponent:pName];
    newImagePath = [toSlide.path stringByAppendingPathComponent:pName];
    [fileManager copyItemAtPath:imagePath toPath:newImagePath error:&error];
    NSErrorPrint(error, @"copy page folder from %@ -> %@", imagePath, newImagePath);
}
@end