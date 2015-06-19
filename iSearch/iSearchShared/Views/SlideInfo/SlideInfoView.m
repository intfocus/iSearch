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
#import "FavoriteViewController.h"
#import "DisplayViewController.h"

@interface SlideInfoView()
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelDesc;
@property (strong, nonatomic) IBOutlet UILabel *labelEditTime;
@property (strong, nonatomic) IBOutlet UILabel *labelPageNum;
@property (strong, nonatomic) IBOutlet UILabel *labelZipSize;
@property (strong, nonatomic) IBOutlet UILabel *labelCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnDisplay;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnAddToTag;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;

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

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.labelTitle.text = self.dict[FILE_DESC_NAME];
    self.labelDesc.text = self.dict[FILE_DESC_DESC];
    self.labelEditTime.text = self.dict[FILE_DESC_NAME];
    self.labelPageNum.text = @"TODO"; //self.dict[FILE_DESC_NAME];
    self.labelZipSize.text = @"TODO"; //self.dict[FILE_DESC_NAME];
    self.labelCategory.text = @"TODO"; //self.dict[FILE_DESC_NAME];
    
}

- (IBAction)actionRemoveSlide:(UIButton *)sender {
    NSString *filePath = [FileUtils getPathName:FAVORITE_DIRNAME FileName:self.dict[FILE_DESC_ID]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:filePath error:&error];
    NSErrorPrint(error, @"remove file#%@", filePath);
    
    if(error == nil) {
        FavoriteViewController *masterView = (FavoriteViewController *)[self masterViewController];
        [masterView dismissPopup];
    }
}
- (IBAction)actionDisplaySlide:(id)sender {
    NSString *fileID = self.dict[FILE_DESC_ID];
    NSString *dir = self.isFavoriteFile ? FAVORITE_DIRNAME : FILE_DIRNAME;

    // 如果文档已经下载，即可执行演示效果，
    // 否则需要下载，该功能在FileSlide内部处理
    if([FileUtils checkSlideExist:fileID Dir:dir Force:YES]) {
        NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:CONTENT_CONFIG_FILENAME];
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
        [configDict setObject:fileID forKey:CONTENT_KEY_DISPLAYID];
        [configDict writeToFile:configPath atomically:YES];
        
        DisplayViewController *showVC = [[DisplayViewController alloc] init];
        [self presentViewController:showVC animated:NO completion:nil];
    }
}
@end