//
//  ViewUpgrade.m
//  iSearch
//
//  Created by lijunjie on 15/7/3.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewUpgrade.h"
#import "AFNetworking.h"
#import "const.h"
#import "Version+Self.h"
#import "SettingViewController.h"
#import "SettingMainView.h"
#import "MBProgressHUD.h"
#import "HttpUtils.h"

@interface ViewUpgrade()
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelCurrentVersion;
@property (strong, nonatomic) IBOutlet UILabel *labelLatestVersion;
@property (strong, nonatomic) IBOutlet UITextView *textViewChangLog;
@property (strong, nonatomic) IBOutlet UIButton *btnSkip;
@property (strong, nonatomic) IBOutlet UIButton *btnUpgrade;
@property (strong, nonatomic) NSString *insertUrl;
@property (strong, nonatomic) Version *version;
@end

@implementation ViewUpgrade

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.navigationItem) {
        UIBarButtonItem *navBtnBackToMain = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(actionBackToMain:)];
        self.navigationItem.leftBarButtonItem = navBtnBackToMain;
        self.navigationItem.title = @"版本更新";
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.version = [[Version alloc] init];

    [self refreshControls:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // only occured when load within settingViewController
    if(self.settingViewController && [HttpUtils isNetworkAvailable]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText = @"检测中...";
        
        [hud showAnimated:YES whileExecutingBlock:^{
            [self.version checkUpdate:^{
                if([self.version isUpgrade]) {
                    [self refreshControls:YES];
                }
            } FailBloc:^{
            }];
        } completionBlock:^{
        }];
    }
}

#pragma mark - controls action
- (IBAction)actionUpgrade:(id)sender {
    NSURL *url = [NSURL URLWithString:self.insertUrl];
    NSLog(@"url: %@", url);
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)actionDismiss:(id)sender {
    if ([self.delegate respondsToSelector:@selector(dismissViewUpgrade)]) {
        [self.delegate dismissViewUpgrade];
    }
}

- (IBAction)actionOpenURL:(UIButton *)sender {
    NSString *urlString = sender.titleLabel.text;
    NSURL *downloadURL = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:downloadURL];
}

- (IBAction)actionBackToMain:(id)sender {
    SettingMainView *view = [[SettingMainView alloc] init];
    view.mainViewController = self.mainViewController;
    view.settingViewController = self.settingViewController;
    self.settingViewController.containerViewController = view;
}

#pragma mark - private methods

- (void)refreshControls:(BOOL)btnEnabled {
    [self.version reload];
    self.labelTitle.text = ([self.version isUpgrade] ? @"有新版本，更新吧" : @"已经最新版本");
    self.labelCurrentVersion.text = [NSString stringWithFormat:@"%@: %@", @"当前版本", self.version.current];
    self.labelLatestVersion.text  = [NSString stringWithFormat:@"%@: %@", @"最新版本", self.version.latest];
    self.textViewChangLog.text    = self.version.changeLog;
    self.insertUrl                = self.version.insertURL;
    [self enabledBtn:self.btnSkip Enabeld:btnEnabled];
    [self enabledBtn:self.btnUpgrade Enabeld:btnEnabled];
}

- (void)enabledBtn:(UIButton *)sender
            Enabeld:(BOOL)enabled {
    if(enabled == sender.enabled) return;
    
    sender.enabled = enabled;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:sender.titleLabel.text];
    NSRange strRange = {0,[str length]};
    if(enabled) {
        [str removeAttribute:NSStrikethroughStyleAttributeName range:strRange];
        
    } else {
        [str addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    }
    [sender setAttributedTitle:str forState:UIControlStateNormal];
}
@end