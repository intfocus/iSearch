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
#import "ContentViewController.h"

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
    
    //NSActionLogger(@"主界面加载", @"successfully");
    //ContentViewController *right=[[ContentViewController alloc] initWithNibName:nil bundle:nil];
    // 界面跳转至文档页面编辑界面
    // 如果文档已经下载，可以查看文档内部详细信息，
    // 否则需要下载，该功能在FileSlide内部处理
    NSString *fileID = @"1";
    if([FileUtils checkSlideExist:fileID]) {
        // 界面跳转需要传递fileID，通过写入配置文件来实现交互
        NSString *pathName = [FileUtils getPathName:CONFIG_DIRNAME FileName:REORGANIZE_CONFIG_FILENAME];
        NSMutableDictionary *config = [FileUtils readConfigFile:pathName];
        
        [config setObject:fileID forKey:@"FileID"];
        [config writeToFile:pathName atomically:YES];
        
        NSString *fileDescSwpPath = [FileUtils fileDescPath:fileID Klass:FILE_CONFIG_SWP_FILENAME];
        if([FileUtils checkFileExist:fileDescSwpPath isDir:false]) {
            NSLog(@"Config SWP file Exist! last time must be CRASH!");
        } else {
            // 拷贝一份文档描述配置
            [FileUtils copyFileDescContent:fileID];
        }
    }
    ContentViewController *right = [[ContentViewController alloc] init];
    //NotificationViewController *right = [[NotificationViewController alloc] init];
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
    NSInteger leftWidth = 200;
    CGRect screenframe=self.view.bounds;
    CGRect leftframe=screenframe;
    leftframe.size.width=leftWidth;
    self.leftView.frame=leftframe;
    CGRect rightframe=screenframe;
    rightframe.origin.x=leftWidth;
    rightframe.size.width=CGRectGetWidth(screenframe)-leftWidth;
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

- (void)calledByPresentedViewController {
    SEL method = @selector(calledByPresentedViewController);
    BOOL hasMethod = [self.right respondsToSelector:method];
    NSLog(@"right className is %@", NSStringFromClass([self.right class]));
    if(hasMethod) {
        [self.right performSelector:method withObject:nil afterDelay:0.1];
    } else {
        NSLog(@"has not the method calledByPresentedViewController");
    }
    NSLog(@"called by Display view.");
}


@end