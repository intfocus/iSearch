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
#import "ReViewController.h"

@interface TagListView()
@property (weak, nonatomic) IBOutlet UIButton *btnAddNewTag;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, nonatomic) IBOutlet UIBarButtonItem *barItemCancel; // 取消
@property (nonatomic, nonatomic) IBOutlet UIBarButtonItem *barItemSubmit; // 完成
@property (nonatomic) NSArray *arrayTagName;

@end

@implementation TagListView

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  导航栏按钮
     */
    self.title = @"添加标签";
    self.barItemCancel = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"取消"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(actionDismissPopup:)];
    self.navigationItem.leftBarButtonItem = self.barItemCancel;
    self.barItemSubmit = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"完成"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(actionSave:)];
    self.navigationItem.rightBarButtonItem = self.barItemSubmit;
    
    /**
     *  控件控制
     */
    // 有勾选标签则激活
//    self.barItemSubmit.enabled = NO;
    [self.btnAddNewTag addTarget:self action:@selector(actionAddNewTag:) forControlEvents:UIControlEventTouchUpInside];
    
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
    [firstRadioButton addTarget:self action:@selector(radioButtonMonitor:) forControlEvents:UIControlEventTouchUpInside];
    [self checkNewTagNameInList:firstRadioButton];
    
    [self.scrollView addSubview:firstRadioButton];
    // otherButtons
    NSMutableArray *otherButtons = [[NSMutableArray alloc] init];
    for (index = 1; index < [fileList count]; index++) {
        dict = [fileList objectAtIndex:index];
        DLRadioButton *radioButton = [self createRadioButton:dict[FILE_DESC_NAME] Index:index];
        [radioButton addTarget:self action:@selector(radioButtonMonitor:) forControlEvents:UIControlEventTouchUpInside];
        [self checkNewTagNameInList:radioButton];
        [self.scrollView addSubview:radioButton];
        [otherButtons addObject:radioButton];
    }
    firstRadioButton.otherButtons = otherButtons;
    self.arrayTagName = [@[firstRadioButton] arrayByAddingObjectsFromArray:otherButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - @Selector
/**
 *  标签列表页[取消]事件
 *  返回原弹出页（编辑页面）
 *
 *  @param sender 召唤先祖，dismiss自己；自杀的权力都没有，CWPopup插件待弃！
 */
- (IBAction)actionDismissPopup:(UIBarButtonItem *)sender {
    NSLog(@"cancel");
    MainAddNewTagView *masterView1 = [self masterViewController];
    ReViewController *masterView2 = (ReViewController*)[masterView1 masterViewController];
    [masterView2 dismissPopup];
}

/**
 *  选中标签后，提交
 *
 *  @param sender <#sender description#>
 */
- (IBAction)actionSave:(UIBarButtonItem *)sender {
    NSString *fileName = [(DLRadioButton *)self.arrayTagName[0] selectedButton].titleLabel.text;
    NSMutableDictionary *descDict = [FileUtils getDescFromFavoriteWithName:fileName];
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:ADDTAG_CONFIG_FILENAME];
    [FileUtils writeJSON:descDict Into:configPath];
    
    MainAddNewTagView *masterView1 = [self masterViewController];
    ReViewController *masterView2 = (ReViewController*)[masterView1 masterViewController];
    [masterView2 actionSavePagesWithMoveFiles:descDict];
    [masterView2 dismissPopup];
}

/**
 *  点击[创建新标签]事件
 *
 *  @param sender <#sender description#>
 */
- (IBAction)actionAddNewTag:(id)sender {
    // 界面跳转至文档页面编辑界面
    MainAddNewTagView *masterView = [self masterViewController];
    AddNewTagView *childView = [[AddNewTagView alloc] init];
    [childView setMasterViewController:masterView];
    [masterView setMainViewController:childView];
}

- (void)checkNewTagNameInList:(DLRadioButton *)radioButton {
    MainAddNewTagView *masterView = [self masterViewController];
    NSMutableDictionary *descDict = masterView.descDict;
    if(descDict[FILE_DESC_NAME] &&
       [descDict[FILE_DESC_NAME] length] >0 &&
       [descDict[FILE_DESC_NAME] isEqualToString:radioButton.titleLabel.text]) {
        radioButton.selected = YES;
        self.barItemSubmit.enabled = YES;
    }
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
#pragma mark - radio buttions list click monitor
/**
 *  所有radioButton实例的点击事件都要添加此事件
 *  有勾选时，可以提交，否则只能取消
 *
 */
- (IBAction)radioButtonMonitor:(id)sender {
    NSString *buttonName = [(DLRadioButton *)self.arrayTagName[0] selectedButton].titleLabel.text;
    NSLog(@"buttonName %@", buttonName);
    self.barItemSubmit.enabled = ([buttonName length] > 0);
}

#pragma mark - gesture recognizer delegate functions

// so that tapping popup view doesnt dismiss it
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}

@end