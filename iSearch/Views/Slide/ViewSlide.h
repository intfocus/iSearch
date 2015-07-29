//
//  FileSlide.h
//  WebStructure
//
//  Created by lijunjie on 15-4-14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_ViewSlide_h
#define iSearch_ViewSlide_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MainViewController;
@class Slide;

@interface ViewSlide : UIView
@property (nonatomic, nonatomic) BOOL isFavorite;
@property (strong, nonatomic) NSMutableDictionary *dict;
@property (nonatomic, nonatomic) MainViewController *masterViewController;

// simple operation
@property (strong, nonatomic) NSString *slideID;
@property (strong, nonatomic) NSString *dirName;
@property (strong, nonatomic) Slide *slide;

@end


#endif
