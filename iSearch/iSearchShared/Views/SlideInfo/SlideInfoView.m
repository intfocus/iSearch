//
//  SlideInfoView.m
//  iSearch
//
//  Created by lijunjie on 15/6/18.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlideInfoView.h"
#import "const.h"
#import "FileUtils.h"

#import "ExtendNSLogFunctionality.h"
#import "MainViewController.h"
#import "DisplayViewController.h"
#import "Slide.h"

@interface SlideInfoView()
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelDesc;
@property (strong, nonatomic) IBOutlet UILabel *labelEditTime;
@property (strong, nonatomic) IBOutlet UILabel *labelPageNum;
@property (strong, nonatomic) IBOutlet UILabel *labelZipSize;
@property (strong, nonatomic) IBOutlet UILabel *labelCategory;
@property (strong, nonatomic) IBOutlet UILabel *labelTypeName;
@property (weak, nonatomic) IBOutlet UIButton *btnDisplay;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToTag;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;

@end

@implementation SlideInfoView

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  控件事件
     */
    [self.btnRemove addTarget:self action:@selector(actionRemoveSlide:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnDisplay addTarget:self action:@selector(actionDisplaySlide:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.labelTitle.text = self.slide.title;
    self.labelDesc.text  = self.slide.desc;
    self.labelTypeName.text = self.slide.typeName;
    [self.labelDesc sizeToFit];
    if (self.labelDesc.frame.size.height > 67) {
        self.labelDesc.frame = CGRectMake(self.labelDesc.frame.origin.x, self.labelDesc.frame.origin.y, self.labelDesc.frame.size.width, 67);
    }
    self.labelEditTime.text = self.slide.createdDate;
    self.labelPageNum.text  = self.slide.pageNum;
    self.labelZipSize.text  = self.slide.zipSize;
    self.labelCategory.text = self.slide.categoryName;
    
    [self.hideButton addTarget:self.masterViewController action:@selector(dismissPopup) forControlEvents:UIControlEventTouchUpInside];
}


- (IBAction)actionRemoveSlide:(UIButton *)sender {
    NSString *filePath = [FileUtils getPathName:FAVORITE_DIRNAME FileName:self.dict[SLIDE_DESC_ID]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:filePath error:&error];
    NSErrorPrint(error, @"remove file#%@", filePath);
    
    if(error == nil) {
//        FavoriteViewController *masterView = (FavoriteViewController *)[self masterViewController];
//        [masterView dismissPopup];
    }
}

#pragma mark - setter rewrite
- (void)setDict:(NSMutableDictionary *)dict {
    self.slide = [[Slide alloc] init];
    self.slide = [Slide initWith:dict Favorite:self.isFavorite];
    _dict = [NSMutableDictionary dictionaryWithDictionary:dict];

}

#pragma mark - control action
- (IBAction)actionDisplaySlide:(id)sender {
    NSString *slideID = self.dict[SLIDE_DESC_ID];
    NSString *dirName = self.isFavorite ? FAVORITE_DIRNAME : SLIDE_DIRNAME;

    // 如果文档已经下载，即可执行演示效果，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:slideID Dir:dirName Force:YES]) {
        NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
        [configDict setObject:slideID forKey:CONTENT_KEY_DISPLAYID];
        NSNumber *displayType = [NSNumber numberWithInt:(self.isFavorite ? SlideTypeFavorite : SlideTypeSlide)];
        [configDict setObject:displayType forKey:SLIDE_DISPLAY_TYPE];
        [configDict writeToFile:configPath atomically:YES];
        
        DisplayViewController *showVC = [[DisplayViewController alloc] init];
        [self presentViewController:showVC animated:NO completion:nil];
    }
}



@end