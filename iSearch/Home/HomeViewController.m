//
//  HomeViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeViewController.h"
#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"

#import "MainViewController.h"
#import "UIViewController+CWPopup.h"
#import "SlideInfoView.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIView *oneView;   // 我的收藏
@property (weak, nonatomic) IBOutlet UIView *twoView;   // 我的分类
@property (weak, nonatomic) IBOutlet UIView *threeView; // 我的记录

@property(nonatomic,strong)UIViewController *oneViewController;
@property(nonatomic,strong)UIViewController *twoViewController;
@property(nonatomic,strong)UIViewController *threeViewController;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * 实例变量初始化
     */
    OneViewController *one     = [[OneViewController alloc] initWithNibName:nil bundle:nil];
    one.masterViewController   = self;
    self.oneViewController     = one;
    TwoViewController *two     = [[TwoViewController alloc] initWithNibName:nil bundle:nil];
    two.masterViewController   = self;
    self.twoViewController     = two;
    ThreeViewController *three = [[ThreeViewController alloc] initWithNibName:nil bundle:nil];
    three.masterViewController   = self;
    self.threeViewController   = three;
    
    //导航栏标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-8, 0, 44, 44)];
    titleLabel.text = @"主页";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:20.0];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [containerView addSubview:titleLabel];
    containerView.layer.masksToBounds = NO;
    UIBarButtonItem *leftTitleBI = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    self.navigationItem.leftBarButtonItem = leftTitleBI;
    
    
    // CWPopup 事件
    self.useBlurForPopup = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)calledByPresentedViewController {
    NSLog(@"called by HomePage view.");
}


- (void)setOneViewController:(UIViewController *)one {
    [_oneViewController removeFromParentViewController];
    [_oneViewController.view removeFromSuperview];
    
    if (!one) return;
    
    _oneViewController=one;
    [self addChildViewController:one];
    [self.oneView addSubview:one.view];
    
    //one.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    one.view.frame=self.oneView.bounds;
}

- (void)setTwoViewController:(UIViewController *)two {
    [_twoViewController removeFromParentViewController];
    [_twoViewController.view removeFromSuperview];
    
    if (!two) return;
    
    _twoViewController=two;
    [self addChildViewController:two];
    [self.twoView addSubview:two.view];
    
    two.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    two.view.frame=self.twoView.bounds;
}

- (void)setThreeViewController:(UIViewController *)three {
    [_threeViewController removeFromParentViewController];
    [_threeViewController.view removeFromSuperview];
    
    if (!three) return;
    
    _threeViewController=three;
    [self addChildViewController:three];
    [self.threeView addSubview:three.view];
    
    three.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    three.view.frame=self.threeView.bounds;
}

/**
 *  收藏页面，点击文件[明细]，弹出框显示文档信息，及操作
 */
- (void)actionPopupSlideInfo:(NSMutableDictionary *)dict {
    SlideInfoView *slideInfoView = [[SlideInfoView alloc] init];
    slideInfoView.masterViewController = self;
    slideInfoView.dict = dict;
    [self presentPopupViewController:slideInfoView animated:YES completion:^(void) {
        NSLog(@"popup view presented");
    }];
}

/**
 *  关闭弹出框；
 *  由于弹出框没有覆盖整个屏幕，所以关闭弹出框时，不会触发回调事件[viewDidAppear]。
 *  强制刷新[收藏界面]；
 */
- (void)dismissPopup {
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissed");
        }];
    }
    OneViewController *one     = [[OneViewController alloc] initWithNibName:nil bundle:nil];
    one.masterViewController   = self;
    self.oneViewController     = one;
}

@end