//
//  MainViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "LoginViewCOntroller.h"
#import "SideViewController.h"
#import "RightSideViewController.h"

#import "HomeViewController.h"
#import "NotificationViewController.h"
#import "OfflineViewController.h"
#import "ContentViewController.h"

#import "PopupView.h"
#import "const.h"
#import "ExtendNSLogFunctionality.h"


#import "MainAddNewTagView.h"
#import "UIViewController+CWPopup.h"


@interface MainViewController ()

@property(nonatomic,strong)IBOutlet UIView *leftView;
@property(nonatomic,strong)IBOutlet UIView *rightView;

@property(nonatomic,strong)UIViewController *leftViewController;
@property(nonatomic,strong)UIViewController *rightViewController;

@end

@implementation MainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 耗时间的操作放在些block中
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //NSActionLogger(@"主界面加载", @"successfully");
        
        SideViewController *left  = [[SideViewController alloc] initWithNibName:nil bundle:nil];
        left.masterViewController = self;
        self.leftViewController   = left;
        
        SideViewController *side     = (id)self.leftViewController;
        UIViewController *controller = [side viewControllerForTag:EntryButtonHomePage];
        [self setRightViewController:controller withNav:YES];
    });

//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
//    tapRecognizer.numberOfTapsRequired = 1;
//    tapRecognizer.delegate = self;
//    [self.view addGestureRecognizer:tapRecognizer];
    self.useBlurForPopup = YES;
    
//    BlockTask(^{
//        //sleep(1);
//    });

}

///////////////////////////////////////////////////////////
/// 屏幕方向设置
///////////////////////////////////////////////////////////


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(BOOL)shouldAutorotate{
    return YES;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)dismissPopup {
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissed");
        }];
    }
}


///////////////////////////////////////////////////////////
/// 屏幕方向设置
///////////////////////////////////////////////////////////

- (IBAction)changeVIew:(id)sender {
    UIControl *entry=sender;

    SideViewController *side=(id)self.leftViewController;

    #warning viewController的配置集中到sideViewController里
    
    NSLog(@"Exception: sender.tag = %ld; %ld", (long)[sender tag], EntryButtonSetting);
    if([entry tag] == EntryButtonSetting) {
        MainAddNewTagView *view = [[MainAddNewTagView alloc] init];
        [self presentPopupViewController:view animated:YES completion:^(void) {
            NSLog(@"popup view presented");
        }];
    } else {
        UIViewController *controller=[side viewControllerForTag:entry.tag];
        [self setRightViewController:controller withNav:YES];

        if (!controller) {
            NSLog(@"Exception: sender.tag = %ld", (long)[sender tag]);
        }
    }
}

- (void)hideLeftView{
    self.leftView.hidden = YES;
    [self.view setNeedsLayout];
}

- (void)showLeftView{
    self.leftView.hidden = NO;
    [self.view setNeedsLayout];
}

- (void)viewDidLayoutSubviews{
    NSInteger leftWidth = 240;
    if (self.leftView.hidden) {
        leftWidth=0;
    }

    CGRect bounds = self.view.bounds;
    CGRect left = bounds;
    left.size.width=leftWidth;
    self.leftView.frame=left;
    
    CGRect right=bounds;
    right.origin.x=leftWidth;
    right.size.width=CGRectGetWidth(bounds) - leftWidth;
    self.rightView.frame=right;
}

- (void)setLeftViewController:(UIViewController *)left{
    [_leftViewController removeFromParentViewController];
    [_leftViewController.view removeFromSuperview];

    if (!left) return;

    _leftViewController=left;
    [self addChildViewController:left];
    [self.leftView addSubview:left.view];

    left.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    left.view.frame=self.leftView.bounds;
}
- (void)setRightViewController:(UIViewController *)right withNav:(BOOL)hasNavigation {
    [_rightViewController removeFromParentViewController];
    [_rightViewController.view removeFromSuperview];

    if (!right) {
        return;
    }
    
    RightSideViewController *r=(id)right;
    r.masterViewController=self;
    
    if(hasNavigation) {
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:right];
        nav.navigationBar.translucent=NO;
        nav.toolbar.translucent=NO;
        right=nav;
    }

    _rightViewController=right;
    [self addChildViewController:right];
    [self.rightView addSubview:right.view];

    right.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    right.view.frame=self.rightView.bounds;
}

-(void)onEntryClick:(id)sender{
    [self changeVIew:sender];
}
-(void)onUserHeadClick:(id)sender{

}

-(void)backToLoginViewController{
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    UIWindow *window = self.view.window;
    window.rootViewController = login;
}

-(void)helloWorld {
    NSLog(@"hello world");
}

@end