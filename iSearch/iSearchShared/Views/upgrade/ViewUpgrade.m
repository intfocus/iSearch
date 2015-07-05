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

@interface ViewUpgrade()
@property (strong, nonatomic) IBOutlet UILabel *labelCurrentVersion;
@property (strong, nonatomic) IBOutlet UILabel *labelLatestVersion;
@property (strong, nonatomic) IBOutlet UITextView *textViewChangLog;
@property (strong, nonatomic) IBOutlet UIButton *btnSkip;
@property (strong, nonatomic) IBOutlet UIButton *btnUpgrade;
@property (strong, nonatomic) NSString *insertUrl;
@end

@implementation ViewUpgrade

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - core method
- (void)checkAppVersionUpgrade:(void(^)())successBloc
                     FailBlock:(void(^)())failBlock {
    NSDictionary *localVersionInfo =[[NSBundle mainBundle] infoDictionary];
    NSString *currVersion = [localVersionInfo objectForKey:@"CFBundleShortVersionString"];
    
    NSString *versionInfoUrl = [NSString stringWithFormat:@"http://fir.im/api/v2/app/version/%@",FIRIM_APP_ID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": FIRIM_USER_TOKEN};
    [manager GET:versionInfoUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *latestVersion = responseObject[FIRIM_VERSION];
        
        if(![latestVersion isEqualToString:currVersion] && ![latestVersion containsString:currVersion]) {
            NSString *installUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", responseObject[FIRIM_INSTALL_URL]];
            NSString *changeLog = responseObject[FIRIM_CHANGE_LOG];
            self.labelCurrentVersion.text = currVersion;
            self.labelLatestVersion.text  = latestVersion;
            self.textViewChangLog.text    = changeLog;
            self.insertUrl                = installUrl;
            
            successBloc();
        } else {
            NSLog(@"lastestVersion: %@, current version: %@", latestVersion, currVersion);
            
            failBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        failBlock();
    }];
}

#pragma mark - controls action
- (IBAction)actionUpgrade:(id)sender {
    NSURL *url = [NSURL URLWithString:self.insertUrl];
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

@end