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
#import "FileUtils+Slide.h"
#import "DateUtils.h"

#import "MainAddNewTagView.h"
#import "TagListView.h"

@interface AddNewTagView()
@property (weak, nonatomic) IBOutlet UITextField *fieldName;
@property (weak, nonatomic) IBOutlet UITextView  *textDesc;
@property (nonatomic, nonatomic) IBOutlet UIBarButtonItem *barItemCancel; // 取消
@property (nonatomic, nonatomic) IBOutlet UIBarButtonItem *barItemSubmit; // 完成

@end

@implementation AddNewTagView

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  导航栏按钮
     */
    self.title = @"创建标签";
    self.barItemCancel = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"取消"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(actionCancel:)];
    self.navigationItem.leftBarButtonItem = self.barItemCancel;
    self.barItemSubmit = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"完成"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(actionSubmit:)];
    self.navigationItem.rightBarButtonItem = self.barItemSubmit;
    
    /**
     *  控件控制
     */
    // 输入标签名称不为空则激活
    self.barItemSubmit.enabled = NO;
    
    // 搜索框内容改变时，实时搜索并展示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TagNameValueChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [self.fieldName setTag:TextFieldNewTagName];
    [self.fieldName addTarget:self action:@selector(TagNameValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    /**
     *  控件默认值
     */
    self.fieldName.placeholder = @"新标签名称";
    self.fieldName.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:.2].CGColor;
    self.fieldName.layer.borderWidth =1.0;
    self.fieldName.layer.cornerRadius =5.0;
    self.textDesc.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:.2].CGColor;
    self.textDesc.layer.borderWidth =1.0;
    self.textDesc.layer.cornerRadius =5.0;
}

- (IBAction)actionSubmit:(UIBarButtonItem *)sender {
    NSString *tagName   = [self.fieldName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *tagDesc   = [self.textDesc.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:NEW_TAG_FORMAT];
    Slide *newSlide     = [FileUtils findOrCreateTag:tagName Desc:tagDesc Timestamp:timestamp];
    
    [self switchToTagListView:newSlide];
}
- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    [self switchToTagListView:nil];
}

#pragma mark 输入框监听

/**
 *  监听输入框内容变化
 *
 *  @param notifice notifice
 */
- (void)TagNameValueChanged:(NSNotification*)notifice {
    UITextField *field = [notifice object];
    // 指定TextFieldTag，否则放弃监听
    if([field tag] != TextFieldNewTagName) return;
    
    NSString *tagName = [field.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.barItemSubmit.enabled = ([tagName length] > 0);
}

#pragma mark - helpers

- (void) switchToTagListView:(Slide *)newSlide {
    MainAddNewTagView *masterView = [self masterViewController];
    TagListView *childView = [[TagListView alloc] init];
    [childView setMasterViewController:masterView];
    masterView.addSlide = newSlide;
    [masterView setMainViewController:childView];
}
#pragma mark - gesture recognizer delegate functions

// so that tapping popup view doesnt dismiss it
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}

@end