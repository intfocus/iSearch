//
//  MainViewController.m
//  iSearch
//
//  Created by lijunjie on 15/6/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MainViewController.h"
#import "LoginViewCOntroller.h"
#import "SideViewController.h"
#import "RightSideViewController.h"
#import "SettingViewController.h"

#import "const.h"
#import "FileUtils.h"
#import "ActionLog.h"
#import "MainEntryButton.h"
#import "ExtendNSLogFunctionality.h"
#import <TWRDownloadManager/TWRDownloadManager.h>

#import "SlideInfoView.h"
#import "UIViewController+CWPopup.h"
#import "DisplayViewController.h"
#import "NotificationDetailView.h"

@interface MainViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic,strong) IBOutlet UIView *leftView;
@property(nonatomic,strong) IBOutlet UIView *rightView;

@property(nonatomic,strong) UIViewController *rightViewController;

@property(nonatomic,strong) SlideInfoView *slideInfoView;
@property(nonatomic,strong) UINavigationController *settingViewController;
@property(nonatomic,strong) DisplayViewController *displayViewController;
@property(nonatomic,strong) NotificationDetailView *notificationDetailView;
@property (weak, nonatomic) IBOutlet UIView *coverView;

// 头像设置
@property (nonatomic) UIActionSheet *imagePickerActionSheet;
@property (nonatomic) UIImagePickerController *imagePicker;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /**
     *  实例变量初始化
     */
    self.btnEntrySelectedTag = [NSNumber numberWithInteger:EntryButtonHomePage];
    
    // CWPopup 事件
    self.useBlurForPopup  = YES;
    self.coverView.hidden = YES;
    
    SideViewController *left  = [[SideViewController alloc] initWithNibName:nil bundle:nil];
    left.masterViewController = self;
    self.leftViewController   = left;
    
    SideViewController *side     = (id)self.leftViewController;
    UIViewController *controller = [side viewControllerForTag:[self.btnEntrySelectedTag integerValue]];
    [self setRightViewController:controller withNav:YES];
}

- (void)refreshRightViewController {
    // presentViewController调出的视图覆盖全屏时，关闭时，会触发此处
    if([self.rightViewController isKindOfClass:[UINavigationController class]]) {
        [[[self.rightViewController childViewControllers] firstObject] viewDidAppear:YES];
    } else {
        [self.rightViewController viewDidAppear:YES];
    }
}


///////////////////////////////////////////////////////////
/// 控件事件
///////////////////////////////////////////////////////////

- (IBAction)changeView:(id)sender {
    UIControl *entry=sender;

    SideViewController *side = (id)self.leftViewController;
    #warning viewController的配置集中到sideViewController里
    UIViewController *controller = [side viewControllerForTag:[entry tag]];
    [self setRightViewController:controller withNav:YES];
    self.btnEntrySelectedTag = [NSNumber numberWithInteger:[entry tag]];
    
    if (!controller) {
        NSLog(@"Exception: sender.tag = %ld", (long)[sender tag]);
    }
   
}

- (void)hideLeftView {
    self.leftView.hidden = YES;
    [self.view setNeedsLayout];
}

- (void)showLeftView {
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

    if (!right) { return; }
    
    
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
    [self.view sendSubviewToBack:self.rightView];

    right.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    right.view.frame=self.rightView.bounds;
}

- (void)onEntryClick:(id)sender{
    if([sender tag] == EntryButtonSetting) {
        [self popupSettingViewController];
    } else {
        [self changeView:sender];
    }
    
    @try {
        MainEntryButton *entry = (MainEntryButton *)sender;
        ActionLogRecordNavigate(entry.titleView.text);
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}
/**
 *  点击头像事件
 *
 *  @param sender <#sender description#>
 */
- (void)onUserHeadClick:(id)sender{
    self.imagePickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选择" otherButtonTitles:@"现在拍照", nil];
    self.imagePickerActionSheet.delegate = self;
    [self.imagePickerActionSheet showInView:self.view];
}

- (void)backToLoginViewController{
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    UIWindow *window = self.view.window;
    window.rootViewController = login;
}

#pragma mark - 头像上传功能函数

#pragma mark - actionSheet let user choose
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self showImagePicker:buttonIndex];
}

#pragma mark - imagePicker
- (void)showImagePicker: (NSInteger)index {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        if (!self.imagePicker) {
            self.imagePicker = [[UIImagePickerController alloc] init];
        }
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = YES;
        self.imagePicker.modalPresentationStyle = UIModalPresentationFormSheet;
        if (index == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
        else if (index == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
    }
    else {
        //authorization failed, show the alert
        [self alertAuthorization];
    }
}

- (void)alertAuthorization{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
        NSString *message = @"授权访问相机~";
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action){
            if (&UIApplicationOpenSettingsURLString != NULL) {
                NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:appSettings];
            }
        }];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else{
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"授权访问相机~" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - imagePicker delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *editImamge = info[UIImagePickerControllerEditedImage];
    NSData *imagedata = UIImageJPEGRepresentation(editImamge, 0.6);
    //save the photo for next launch
    [[NSUserDefaults standardUserDefaults] setObject:imagedata forKey:@"avatarSmall"];
    [picker dismissViewControllerAnimated:YES completion:^{
        ((SideViewController *)self.leftViewController).head.headView.image = editImamge;
    }];
}

#pragma mark - Slide info PopupView
- (void)popupSlideInfo:(NSMutableDictionary *)dict isFavorite:(BOOL)isFavorite {
    if(!self.slideInfoView) {
        self.slideInfoView = [[SlideInfoView alloc] init];
        self.slideInfoView.masterViewController = self;
    }
    self.slideInfoView.isFavorite = isFavorite;
    self.slideInfoView.dict = dict;
    [self presentPopupViewController:self.slideInfoView animated:YES completion:^(void) {
        NSLog(@"popup view presented");
        self.coverView.hidden = NO;
    }];
}
- (void)dismissPopupSlideInfo {
    if (self.popupViewController) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            _slideInfoView = nil;
            self.coverView.hidden = YES;
            NSLog(@"dismiss SlideInfoView.");
        }];
    }
}

#pragma mark - popup show settingViewController
- (void)popupSettingViewController {
    if(!self.settingViewController) {
        SettingViewController *settingVC = [[SettingViewController alloc] init];
        settingVC.mainViewController = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingVC];
        nav.view.frame = CGRectMake(0, 0, 400, 500);
        self.settingViewController = nav;
    }
    [self presentPopupViewController:self.settingViewController animated:YES completion:^(void) {
        self.coverView.hidden = NO;
        NSLog(@"popup view settingViewController");
    }];
}
- (void)dimmissPopupSettingViewController {
    if (self.popupViewController) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            _settingViewController = nil;
            self.coverView.hidden = YES;
            NSLog(@"dismiss SettingViewController.");
        }];
    }
}

#pragma mark - present view DisplayViewController
- (void)presentViewDisplayViewController {
    if(!self.displayViewController) {
        self.displayViewController = [[DisplayViewController alloc] init];
        self.displayViewController.masterViewController = self;
    }
    [self presentViewController:self.displayViewController animated:NO completion:^{
        self.coverView.hidden = NO;
    }];
}
- (void)dismissViewDisplayViewController {
    if(self.displayViewController) {
        [self.displayViewController dismissViewControllerAnimated:NO completion:^{
            _displayViewController = nil;
            self.coverView.hidden = YES;
            
            NSLog(@"dismiss DisplayViewController.");
        }];
    }
}

#pragma mark - present view NotificationDetailView
- (void)popupNotificationDetailView:(NSDictionary *)notification {
    if(!self.notificationDetailView) {
        self.notificationDetailView = [[NotificationDetailView alloc] init];
        self.notificationDetailView.dict = notification;
        self.notificationDetailView.masterViewController = self;
    }
    [self presentPopupViewController:self.notificationDetailView animated:YES completion:^{
        self.coverView.hidden = NO;
    }];
}
- (void)dimmissPopupNotificationDetailView {
    if(self.notificationDetailView) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            _notificationDetailView = nil;
            self.coverView.hidden = YES;
            
            NSLog(@"dismiss NotificationDetailView.");
        }];
    }
}

#pragma mark - Slide Download Manager
- (void)downloadManager {
    [[TWRDownloadManager sharedManager] downloadFileForURL:@"" progressBlock:^(CGFloat progress) {

    } remainingTime:^(NSUInteger seconds) {

    } completionBlock:^(BOOL completed) {
        NSLog(@"Download completed!");

    } enableBackgroundMode:YES];
}

#pragma mark - supportedInterfaceOrientationsForWindow
-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
@end