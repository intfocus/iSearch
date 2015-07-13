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
#import "FileUtils+Slide.h"
#import "Slide.h"

#import "MBProgressHUD.h"
#import "MainAddNewTagView.h"
#import "AddNewTagView.h"
#import "ReViewController.h"
#import "DisplayViewController.h"

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
    [self.btnAddNewTag addTarget:self action:@selector(actionAddNewTag:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /**
     *  标签列表为单选，手工点击[提交]
     *  DLRadioButton单选原理 firstRadioButton.otherButtons = otherButtons;
     */
    NSMutableArray *slideList = [FileUtils favoriteSlideList1];
    Slide *slide;
    DLRadioButton *firstRadioButton;
    NSMutableArray *otherButtons = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    // firstRadioButton
    if([slideList count] >= 1) {
        slide = [slideList objectAtIndex:index];
        firstRadioButton = [self createRadioButton:slide.title Index:index];
        [firstRadioButton addTarget:self action:@selector(radioButtonMonitor:) forControlEvents:UIControlEventTouchUpInside];
        [self checkNewTagNameInList:firstRadioButton];
        [self.scrollView addSubview:firstRadioButton];
        self.arrayTagName = @[firstRadioButton];
    }
    // otherButtons
    if([slideList count] >= 2) {
        for (index = 1; index < [slideList count]; index++) {
            slide = [slideList objectAtIndex:index];
            DLRadioButton *radioButton = [self createRadioButton:slide.title Index:index];
            [radioButton addTarget:self action:@selector(radioButtonMonitor:) forControlEvents:UIControlEventTouchUpInside];
            [self checkNewTagNameInList:radioButton];
            [self.scrollView addSubview:radioButton];
            [otherButtons addObject:radioButton];
        }
        firstRadioButton.otherButtons = otherButtons;
        self.arrayTagName = [@[firstRadioButton] arrayByAddingObjectsFromArray:otherButtons];
    }
}

#pragma mark - @Selector
/**
 *  标签列表页[取消]事件
 *  返回原弹出页（编辑页面）
 *
 *  @param sender 召唤先祖，dismiss自己；自杀的权力都没有，CWPopup插件待弃！
 */
- (IBAction)actionDismissPopup:(UIBarButtonItem *)sender {
    MainAddNewTagView *masterView1 = [self masterViewController];
    ReViewController *masterView2 = (ReViewController*)[masterView1 masterViewController];
    [masterView2 dismissPopupAddToTag];
}

/**
 *  导航栏[完成]按钮；选中标签后，处理于激活状态.
 *  真正的物理操作逻辑在ReViewController中，so masterViewController is necessary!
 *
 *  @param sender UIBarButtonItem
 */
- (IBAction)actionSave:(UIBarButtonItem *)sender {
    NSString *slideTitle = [(DLRadioButton *)self.arrayTagName[0] selectedButton].titleLabel.text;
    if(!slideTitle || [slideTitle length] == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请选择或新建标签";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1];
    } else {
        Slide *slide = [Slide findByTitleInFavorited:slideTitle];
        
        MainAddNewTagView *masterView1 = [self masterViewController];
        if([masterView1.fromViewControllerName isEqualToString:@"ReViewController"]) {
            ReViewController *masterView2 = (ReViewController*)[masterView1 masterViewController];
            [masterView2 actionSavePagesAndMoveFiles:slide];
            if(masterView1.closeMainViewAfterDone) {
                [masterView2 dismissReViewController];
            } else {
                [masterView2 dismissPopupAddToTag];
            }
        }
        if([masterView1.fromViewControllerName isEqualToString:@"DisplayViewController"]) {
            DisplayViewController *masterView2 = (DisplayViewController *)[masterView1 masterViewController];
            [masterView2 actionSavePagesAndMoveFiles:slide];
            if(masterView1.closeMainViewAfterDone) {
                [masterView2 dismissDisplayViewController];
            } else {
                [masterView2 dismissPopupAddToTag];
            }
        }
    }
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
    if(masterView.addSlide &&
       masterView.addSlide.title &&
       [masterView.addSlide.title isEqualToString:radioButton.titleLabel.text]) {
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