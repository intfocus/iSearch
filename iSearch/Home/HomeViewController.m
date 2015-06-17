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
    
    OneViewController *one     = [[OneViewController alloc] initWithNibName:nil bundle:nil];
    self.oneViewController     = one;
    TwoViewController *two     = [[TwoViewController alloc] initWithNibName:nil bundle:nil];
    //    two.masterViewController   = self.masterViewController;
    self.twoViewController     = two;
    ThreeViewController *three = [[ThreeViewController alloc] initWithNibName:nil bundle:nil];
    self.threeViewController   = three;
    
    //self.navigationItem.title = @"主页";
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-8, 0, 44, 44)];
    titleLabel.text = @"主页";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:20.0];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [containerView addSubview:titleLabel];
    containerView.layer.masksToBounds = NO;
    UIBarButtonItem *leftTitleBI = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    self.navigationItem.leftBarButtonItem = leftTitleBI;
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


@end