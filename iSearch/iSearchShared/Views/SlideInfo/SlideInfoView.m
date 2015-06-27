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
#import "ReViewController.h"
#import "Slide.h"
#import "PopupView.h"

@interface SlideInfoView()
@property (nonatomic, nonatomic) PopupView *popupView;
@property (nonatomic, nonatomic) DisplayViewController *displayViewController;
@property (nonatomic, nonatomic) ReViewController *reViewController;
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
     *  实例变量初始化
     */
    /**
     *  控件事件
     */
    [self.btnRemove addTarget:self action:@selector(actionRemoveSlide:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnDisplay addTarget:self action:@selector(actionDisplaySlide:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAddToTag addTarget:self action:@selector(actionAddToFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnEdit addTarget:self action:@selector(actionEditSlide:) forControlEvents:UIControlEventTouchUpInside];
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
    self.labelZipSize.text  = [FileUtils humanFileSize:self.slide.zipSize];
    self.labelCategory.text = self.slide.categoryName;
    
    [self.hideButton addTarget:self.masterViewController action:@selector(dismissPopupSlideInfo) forControlEvents:UIControlEventTouchUpInside];
}



#pragma mark - assistant methods

- (void)showPopupView:(NSString*) text {
    if(self.popupView == nil) {
        self.popupView = [[PopupView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/4, self.view.frame.size.width/2, self.view.frame.size.height/2)];
        
        self.popupView.ParentView = self.view;
    }
    
    [self.popupView setText: text];
    [self.view addSubview:self.popupView];
}

#pragma mark - setter rewrite
- (void)setDict:(NSMutableDictionary *)dict {
    self.slide = [[Slide alloc]initSlide:dict isFavorite:self.isFavorite];
    self.slideID = self.slide.ID;
    self.dirName = self.slide.dirName;
    _dict = [NSMutableDictionary dictionaryWithDictionary:dict];

}

#pragma mark - control action
- (IBAction)actionDisplaySlide:(id)sender {
    // 如果文档已经下载，即可执行演示效果，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:self.slideID Dir:self.dirName Force:YES]) {
        NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
        [configDict setObject:self.slideID forKey:CONTENT_KEY_DISPLAYID];
        NSNumber *displayType = [NSNumber numberWithInt:(self.isFavorite ? SlideTypeFavorite : SlideTypeSlide)];
        [configDict setObject:displayType forKey:SLIDE_DISPLAY_TYPE];
        [configDict writeToFile:configPath atomically:YES];
        
        if(self.displayViewController == nil) {
            self.displayViewController = [[DisplayViewController alloc] init];
        }
        [self.masterViewController dismissPopupSlideInfo];
        [self presentViewController:self.displayViewController animated:NO completion:nil];
    } else {
        [self showPopupView:@"请先下载"];
    }
}

- (IBAction)actionRemoveSlide:(UIButton *)sender {
    if(self.slide.isDownloading) {
        [self.slide downloaded];
        [self showPopupView:@"请刷新界面"];
    }else if(self.slide.isDownloaded) {
        NSString *filePath = [FileUtils getPathName:self.dirName FileName:self.slide.ID];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        BOOL isSuccessfully = NSErrorPrint(error, @"remove file#%@", filePath);
        
        if(isSuccessfully) {
            [self showPopupView:@"移除成功"];
        }
        [self.masterViewController performSelector:@selector(refreshRightViewController)];
        [self.masterViewController dismissPopupSlideInfo];
    } else {
        [self showPopupView:@"未曾下载，\n何言移除！"];
    }
}

- (IBAction)actionEditSlide:(UIButton *)sender {
    if(self.slide.isDownloaded) {
        // 界面跳转需要传递fileID，通过写入配置文件来实现交互
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:EDITPAGES_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        
        [config setObject:self.slideID forKey:CONTENT_KEY_EDITID1];
        NSNumber *slideType = [NSNumber numberWithInt:(self.isFavorite ? SlideTypeFavorite : SlideTypeSlide)];
        [config setObject:slideType forKey:SLIDE_EDIT_TYPE];
        [FileUtils writeJSON:config Into:pathName];
        
        // 界面跳转至文档页面编辑界面
        if(self.reViewController == nil) {
            self.reViewController = [[ReViewController alloc] init];
        }
        
        [self.masterViewController dismissPopupSlideInfo];
        [self presentViewController:self.reViewController animated:NO completion:nil];
    } else {
        [self showPopupView:@"空空如也,\n编辑何物？"];
    }
}

- (IBAction)actionAddToFavorite:(UIButton *)sender {
    if([self.slide isInFavorited]) {
        [self showPopupView:@"已在收藏了"];
    } else if(self.slide.isDownloaded) {
        BOOL isSuccessfully = [self.slide addToFavorite];
        [self showPopupView:[NSString stringWithFormat:@"收藏%@", isSuccessfully ? @"成功" : @"失败"]];
    } else {
        [self showPopupView:@"未曾下载，\n何言收藏！"];
    }
    
}

@end