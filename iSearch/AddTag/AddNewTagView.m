//
//  AddToFavoriteView.m
//  iSearch
//
//  Created by lijunjie on 15/6/16.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddNewTagView.h"
#import "const.h"
#import "FileUtils.h"
#import "DateUtils.h"

#import "MainAddNewTagView.h"
#import "TagListView.h"

@interface AddNewTagView()
@property (weak, nonatomic) IBOutlet UITextField *fieldName;
@property (weak, nonatomic) IBOutlet UITextView  *textDesc;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@end

@implementation AddNewTagView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建标签";
    
    /**
     *  控件事件
     */
    [self.btnSubmit addTarget:self action:@selector(actionSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)actionSubmit:(id)sender {
    NSString *tagName = [self.fieldName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *tagDesc = [self.textDesc.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:NEW_TAG_FORMAT];
    [FileUtils addNewTag:tagName Desc:tagDesc Timestamp:timestamp];
    
    [self switchToTagListView];
}
- (IBAction)actionCancel:(id)sender {
    [self switchToTagListView];
}


#pragma mark - helpers

- (void) switchToTagListView {
    MainAddNewTagView *masterView = [self masterViewController];
    TagListView *childView = [[TagListView alloc] init];
    [childView setMasterViewController:masterView];
    [masterView setMainViewController:childView];
}
#pragma mark - gesture recognizer delegate functions

// so that tapping popup view doesnt dismiss it
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}

@end