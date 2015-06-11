//
//  MainViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewCOntroller.h"
#import "NotificationViewController.h"
#import "OfflineViewController.h"

@interface MainViewController ()

@property(nonatomic,strong)IBOutlet UIView *leftView;
@property(nonatomic,strong)IBOutlet UIView *rightView;

@property(nonatomic,strong)UIViewController *left;
@property(nonatomic,strong)UIViewController *right;

@end

@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    LoginViewController *right=[[LoginViewController alloc] initWithNibName:nil bundle:nil];
    self.right=right;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)changeVIew:(id)sender {
    switch([sender tag]) {
        case 0: {
            LoginViewController *login = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
            self.right = login;
            break;
        }
        case 1: {
            NotificationViewController *notification = [[NotificationViewController alloc] initWithNibName:nil bundle:nil];
            self.right = notification;
            break;
        }
        case 2: {
            OfflineViewController *offline = [[OfflineViewController alloc] initWithNibName:nil bundle:nil];
            self.right = offline;
            break;
        }
        default: {
            NSLog(@"Exception: sender.tag = %ld", (long)[sender tag]);
            break;
        }
    }
    
}
- (void)viewDidLayoutSubviews{
    CGRect screenframe=self.view.bounds;
    CGRect leftframe=screenframe;
    leftframe.size.width=300;
    self.leftView.frame=leftframe;
    CGRect rightframe=screenframe;
    rightframe.origin.x=300;
    rightframe.size.width=CGRectGetWidth(screenframe)-300;
    self.rightView.frame=rightframe;
}

- (void)setLeft:(UIViewController *)left{
    [_left removeFromParentViewController];
    [_left.view removeFromSuperview];
    _left=left;
    [self addChildViewController:left];
    [self.leftView addSubview:left.view];
    left.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    left.view.frame=self.leftView.bounds;
}
- (void)setRight:(UIViewController *)right{
    [_right removeFromParentViewController];
    [_right.view removeFromSuperview];
    _right=right;
    [self addChildViewController:right];
    [self.rightView addSubview:right.view];
    right.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    right.view.frame=self.rightView.bounds;
}


@end