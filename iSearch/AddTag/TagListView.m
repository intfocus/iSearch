//
//  TagListView.m
//  iSearch
//
//  Created by lijunjie on 15/6/16.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TagListView.h"
#import "DLRadioButton.h"
#import "ExtendNSLogFunctionality.h"
#import "FileUtils.h"

#import "MainAddNewTagView.h"
#import "AddNewTagView.h"

@interface TagListView()

@property (weak, nonatomic) IBOutlet UIButton *btnAddNewTag;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) NSArray *arrayTagName;

@end

@implementation TagListView

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  控件事件
     */
    [self.btnAddNewTag addTarget:self action:@selector(actionAddNewTag:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSubmit addTarget:self action:@selector(actionSubmit:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /**
     *  标签列表为单选，手工点击[提交]
     *  DLRadioButton单选原理 firstRadioButton.otherButtons = otherButtons;
     */
    NSMutableArray *fileList = [FileUtils favoriteFileList];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    // firstRadioButton
    NSInteger index = 0;
    dict = [fileList objectAtIndex:index];
    DLRadioButton *firstRadioButton = [self createRadioButton:dict[FILE_DESC_NAME] Index:index];
    [self.scrollView addSubview:firstRadioButton];
    // otherButtons
    NSMutableArray *otherButtons = [[NSMutableArray alloc] init];
    for (index = 1; index < [fileList count]; index++) {
        dict = [fileList objectAtIndex:index];
        DLRadioButton *radioButton = [self createRadioButton:dict[FILE_DESC_NAME] Index:index];
        [self.scrollView addSubview:radioButton];
        [otherButtons addObject:radioButton];
    }
    firstRadioButton.otherButtons = otherButtons;
    self.arrayTagName = [@[firstRadioButton] arrayByAddingObjectsFromArray:otherButtons];
}

#pragma mark - @Selector

/**
 *  选中标签后，提交
 *
 *  @param sender <#sender description#>
 */
- (IBAction)actionSubmit:(id)sender {
    [self showSelectedButton:self.arrayTagName];
}

- (IBAction)actionAddNewTag:(id)sender {
    // 界面跳转至文档页面编辑界面
    MainAddNewTagView *masterView = [self masterViewController];
    AddNewTagView *childView = [[AddNewTagView alloc] init];
    [childView setMasterViewController:masterView];
    [masterView setMainViewController:childView];
}
#pragma mark - Helpers
/**
 *  显示radioButtons选中项
 *
 *  @param radioButtons <#radioButtons description#>
 */
- (void)showSelectedButton:(NSArray *)radioButtons {
    NSString *buttonName = [(DLRadioButton *)radioButtons[0] selectedButton].titleLabel.text;
    [[[UIAlertView alloc] initWithTitle: buttonName ? @"Selected Button" : @"No Button Selected" message:buttonName delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

/**
 *  DLRadioButton创建代码封
 *
 *  @param title 标签名称
 *  @param index 所在列表序号
 *
 *  @return DLRadioButton实例
 */
- (DLRadioButton *)createRadioButton:(NSString *)title Index:(NSInteger)index {
    DLRadioButton *radioButton = [[DLRadioButton alloc] initWithFrame:CGRectMake(10, 10+30*index, self.view.frame.size.width - 60, 30)];
    radioButton.buttonSideLength = 30;
    [radioButton setTitle:title forState:UIControlStateNormal];
    [radioButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    radioButton.circleColor = [UIColor purpleColor];
    radioButton.indicatorColor = [UIColor purpleColor];
    radioButton.iconOnRight = YES;
    radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    return radioButton;
}

- (IBAction)actionDismissPopup:(id)sender {
}

#pragma mark - gesture recognizer delegate functions

// so that tapping popup view doesnt dismiss it
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}

@end