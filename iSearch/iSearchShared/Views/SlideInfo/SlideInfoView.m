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
#import "Slide.h"
#import "ActionLog.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"

@interface SlideInfoView()
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UITextView *textViewDesc;
@property (strong, nonatomic) IBOutlet UILabel *labelEditTime;
@property (strong, nonatomic) IBOutlet UILabel *labelPageNum;
@property (strong, nonatomic) IBOutlet UILabel *labelZipSize;
@property (strong, nonatomic) IBOutlet UILabel *labelCategory;
@property (strong, nonatomic) IBOutlet UILabel *labelTypeName;
@property (weak, nonatomic) IBOutlet UIButton *btnDisplay;
@property (weak, nonatomic) IBOutlet UIButton *btnScan;
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
    [self.btnScan addTarget:self action:@selector(actionScanSlide:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.labelTitle.text    = self.slide.title;
    self.labelCategory.text = [NSString stringWithFormat:@"%@: %@", @"分类", self.slide.categoryName];
    self.labelPageNum.text  = [NSString stringWithFormat:@"%@: %@", @"页数", self.slide.pageNum];
    self.labelTypeName.text = [NSString stringWithFormat:@"%@: %@", @"属性", self.slide.typeName];
    self.textViewDesc.text  = self.slide.desc;
    
    NSString *sizeInfo, *editTime;
    if(self.isFavorite) {
        sizeInfo = [NSString stringWithFormat:@"%@: %@",
                    @"文件体积", [FileUtils humanFileSize:self.slide.folderSize]];
        editTime = [NSString stringWithFormat:@"%@: %@", @"收藏时间", self.slide.localCreatedDate];
    } else {
        sizeInfo = [NSString stringWithFormat:@"%@: %@", @"压缩包", [FileUtils humanFileSize:self.slide.folderSize]];
        editTime = [NSString stringWithFormat:@"%@: %@", @"上架时间", self.slide.createdDate];
    }
    
    self.labelEditTime.text = editTime;
    self.labelZipSize.text  = sizeInfo;
    
    [self.hideButton addTarget:self.masterViewController action:@selector(dismissPopupSlideInfo) forControlEvents:UIControlEventTouchUpInside];
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
        [configDict setObject:[NSNumber numberWithInt:0] forKey:SLIDE_DISPLAY_JUMPTO];
        [configDict writeToFile:configPath atomically:YES];
        
        [self.masterViewController dismissPopupSlideInfo];
        [self.slide enterDisplayOrScanState];
        [self.masterViewController presentViewDisplayViewController];
    } else {
        [self showPopupView:@"请君下载"];
    }
}

- (IBAction)actionRemoveSlide:(UIButton *)sender {
    if(self.slide.isDownloading) {
        [self.slide downloaded];
    } else if(self.slide.isDownloaded) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        [alert addButton:@"确认" actionBlock:^(void) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            [fileManager removeItemAtPath:self.slide.path error:&error];
            BOOL isSuccessfully = NSErrorPrint(error, @"remove slide#%@", self.slide.path);
    
            if(isSuccessfully) {
                [self showPopupView:@"移除成功"];
                ActionLog *actionLog = [[ActionLog alloc] init];
                [actionLog recordSlide:self.slide Action:ACTION_REMOVE];
            }
            [self.masterViewController refreshRightViewController];
            [self.masterViewController dismissPopupSlideInfo];
        }];
        
        [alert showError:self.masterViewController title:@"确认删除" subTitle:self.slide.title closeButtonTitle:@"取消" duration:0.0f];

    } else {
        [self showPopupView:@"未曾下载,何言移除！"];
    }
}

- (IBAction)actionScanSlide:(UIButton *)sender {
//    if(self.slide.isDownloaded) {
//        // 界面跳转需要传递fileID，通过写入配置文件来实现交互
//        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:EDITPAGES_CONFIG_FILENAME];
//        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
//        
//        [config setObject:self.slideID forKey:SCAN_SLIDE_ID];
//        NSNumber *slideType = [NSNumber numberWithInt:(self.isFavorite ? SlideTypeFavorite : SlideTypeSlide)];
//        [config setObject:slideType forKey:SCAN_SLIDE_FROM];
//        [FileUtils writeJSON:config Into:pathName];
//        
//        [self.masterViewController dismissPopupSlideInfo];
//        [self.masterViewController presentViewReViewController];
//    } else {
//        [self showPopupView:@"空空如也,\n编辑何物？"];
//    }
}

- (IBAction)actionAddToFavorite:(UIButton *)sender {
    if([self.slide isInFavorited]) {
        [self showPopupView:@"已在收藏"];
    } else if(self.slide.isDownloaded) {
        BOOL isSuccessfully = [self.slide addToFavorite];
        [self showPopupView:[NSString stringWithFormat:@"收藏%@", isSuccessfully ? @"成功" : @"失败"]];
        ActionLog *actionLog = [[ActionLog alloc] init];
        [actionLog recordSlide:self.slide Action:ACTION_ADD_TO_FAVORITE];
    } else {
        [self showPopupView:@"未曾下载,何言收藏！"];
    }
    
}
#pragma mark - assistant methods

- (void)showPopupView:(NSString*)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText =text;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
}
@end