//
//  ViewController.m
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  iSearch - iLogin
//
//  说明:
//  1. 宏定义在const.h文件中
//  2. 报错、按钮标签等信息定义在message.ht文件中，便于多语言设置
//  3. app界面控件的点击或手势事件最好代码实现，组合各功能时只需要关联控件即可
//
//  步骤：
//  有网络
//  一、 点击[登录]，通过外浏览器跳转至指定登录网页
//      1. 如果登录界面一直，未出现，点击[关闭]，再点击[登录]
//  二、 在指定登录网页，输入正确用户名与密码后，外浏览器会得到指定cookie
//      1. 点击[登录]后，会启动定时器，每秒读取外浏览器的cookie,当前用户在指定网页登录成功时，定时器扫描到指定cookie
//      2. 再使用cookie值，访问iSearch服务器，取得用户部门信息
//          a. 如果失败，则弹出框提示，并返回登录界面
//          b. 如果成功,保存数据，跳转至主界面
//
//   **注意**
//  1. 读取登陆信息配置档，有则读取，无则使用默认值 #readConfigFile#
//  2. 修改login.plist只存在于一种情况: 有网络环境下，HttpPost服务器登陆成功时

#import "LoginViewController.h"

#import "const.h"
#import "message.h"
#import "User.h"
#import "Slide.h"
#import "HttpResponse.h"
#import "Version+Self.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "DateUtils.h"
#import "FileUtils.h"
#import "ApiHelper.h"
#import "ExtendNSLogFunctionality.h"
#import "MainViewController.h"

#import "SSZipArchive.h"
#import "SCLAlertView.h"
#import "AFNetworking.h"
#import "UIViewController+CWPopup.h"
#import "ViewUpgrade.h"

@interface LoginViewController () <ViewUpgradeProtocol>
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIWebView *webViewLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBack;
@property (weak, nonatomic) IBOutlet UILabel *labelLoginTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelPropmt;
@property (nonatomic, nonatomic) ViewUpgrade *viewUpgrade;

@property (strong, nonatomic)  NSString *cookieValue;
@property (strong, nonatomic)  NSTimer *timerReadCookie;

@property (strong, nonatomic) User *user;
@property (nonatomic, nonatomic) NSInteger timerCount;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化
     */
    self.user = [[User alloc] init];
    self.labelPropmt.text = @"";
    [self hideOutsideLoginControl:YES];
    
    // CWPopup 事件
    self.useBlurForPopup = YES;
    
    /**
     控件事件
    */
    [self.btnNavBack addTarget:self action:@selector(actionOutsideLoginClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSubmit addTarget:self action:@selector(actionSubmit:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if([HttpUtils isNetworkAvailable]) {
//        [self checkAppVersionUpgrade];
//    }
}

#pragma mark memory management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - check version upgrade

- (void)checkAppVersionUpgrade {
    self.btnSubmit.enabled = NO;
    [self.btnSubmit setTitle:@"检测版本..." forState:UIControlStateNormal];
    
    Version *version = [[Version alloc] init];
    [version checkUpdate:^{
        if([version isUpgrade]) {
            if(!self.viewUpgrade) {
                self.viewUpgrade = [[ViewUpgrade alloc] init];
            }
            self.viewUpgrade.delegate = self;
            [self presentPopupViewController:self.viewUpgrade animated:YES completion:^(void) {
                NSLog(@"popup view viewUpgrade");
                [self.viewUpgrade refreshControls:YES];
            }];
        }
    } FailBloc:^{
        self.btnSubmit.enabled = YES;
        [self.btnSubmit setTitle:@"登陆" forState:UIControlStateNormal];
    }];
    
}

#pragma mark - ViewUpgradeProtocol
- (void)dismissViewUpgrade {
    if(self.viewUpgrade) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            _viewUpgrade = nil;
            NSLog(@"dismiss viewUpgrade.");
        }];
    }
    self.btnSubmit.enabled = YES;
    [self.btnSubmit setTitle:@"登录" forState:UIControlStateNormal];
}
#pragma mark - control action selector

- (IBAction)actionOutsideLoginClose:(id)sender {
    [self hideOutsideLoginControl:YES];
    [self actionClearCookies];
    if(self.timerReadCookie) {
        [self.timerReadCookie invalidate];
    }
}

- (IBAction)actionSubmit:(id)sender {
    self.labelPropmt.text = @"";

    self.cookieValue = @"nm6586tst";
    [self actionOutsideLoginSuccessfully];
    return;
    
    BOOL isNetworkAvailable = [HttpUtils isNetworkAvailable];
    NSLog(@"network is available: %@", isNetworkAvailable ? @"true" : @"false");
    if(isNetworkAvailable) {
        [self actionClearCookies];
        [self actionOutsideLogin];
    } else {
        [self actionLoginWithoutNetwork];
    }
    
}

#pragma mark - assistant methods

#pragma mark - within network
- (void)actionOutsideLogin {
    [self actionOutsideLoginRefresh];
    [self hideOutsideLoginControl:NO];
    if(!self.timerReadCookie || ![self.timerReadCookie isValid]) {
        self.timerReadCookie = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(actionReadCookieTimer) userInfo:nil repeats:YES];
    }
    self.timerCount = 0;
    [self.timerReadCookie fire];
}

- (void)actionOutsideLoginRefresh {
    NSString *urlString = @"https://tsa-china.takeda.com.cn/uat/saml/sp/index.php?sso";
    NSURL *url = [NSURL URLWithString:urlString];
    [self.webViewLogin loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)actionReadCookieTimer {
    NSString *cookieName = @"samlNameId", *cookieValue = @"";
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        NSLog(@"cookie: %@:%@", cookie.name, cookie.value);
        if([cookie.name isEqualToString:cookieName]) {
            cookieValue = cookie.value;
            break;
        }
    }
    if([cookieValue length] > 0) {
        if([cookieValue isEqualToString:@"error000"]) {
            [self hideOutsideLoginControl:YES];
            [ViewUtils simpleAlertView:self Title:ALERT_TITLE_LOGIN_FAIL Message:@"服务器登录失败" ButtonTitle:BTN_CONFIRM];
        } else {
            self.cookieValue = cookieValue;
            [self actionOutsideLoginSuccessfully];
        }
        [self.timerReadCookie invalidate];
        [self actionClearCookies];
    }
    self.timerCount++;
}

- (void) hideOutsideLoginControl:(BOOL)isHidden {
    if(isHidden) {
        [self.view sendSubviewToBack:self.labelLoginTitle];
        [self.view sendSubviewToBack:self.webViewLogin];
        [self.view sendSubviewToBack:self.btnNavBack];
    } else {
        [self.view bringSubviewToFront:self.labelLoginTitle];
        [self.view bringSubviewToFront:self.webViewLogin];
        [self.view bringSubviewToFront:self.btnNavBack];
    }
    self.webViewLogin.hidden = isHidden;
    self.labelLoginTitle.hidden = isHidden;
    self.btnNavBack.hidden = isHidden;
}
- (void) actionClearCookies {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    for (cookie in [cookieJar cookies]) {
        [cookieJar deleteCookie:cookie];
    }
}

- (void)actionOutsideLoginSuccessfully {
    NSMutableArray *loginErrors = [[NSMutableArray alloc] init];
    
    self.labelPropmt.text = @"获取用户信息...";
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];

    HttpResponse *httpResponse = [ApiHelper login:self.cookieValue];
    if(![httpResponse isValid]) {
        [loginErrors addObjectsFromArray:httpResponse.errors];
    } else {
        NSMutableDictionary *responseDict = httpResponse.data;
        // 服务器交互成功
        NSString *responseResult = responseDict[LOGIN_FIELD_RESULT];
        if(responseResult && [responseResult length] == 0) {
            self.user.loginUserName    = self.cookieValue;
            self.user.loginPassword    = self.cookieValue;
            self.user.loginRememberPWD = YES;
            self.user.loginLast        = [DateUtils dateToStr:[NSDate date] Format:LOGIN_DATE_FORMAT];
            
            // 服务器信息
            self.user.ID         = [responseDict objectForKey:LOGIN_FIELD_ID];
            self.user.name       = [responseDict objectForKey:LOGIN_FIELD_NAME];
            self.user.email      = [responseDict objectForKey:LOGIN_FIELD_EMAIL];
            self.user.deptID     = [responseDict objectForKey:LOGIN_FIELD_DEPTID];
            self.user.employeeID = [responseDict objectForKey:LOGIN_FIELD_EMPLOYEEID];
            
            // write into local config
            [self.user save];
            [self.user writeInToPersonal];
            
            // 跳至主界面
            [self enterMainViewController];
            return;
        } else {
            [loginErrors addObject:[NSString stringWithFormat:@"服务器提示:%@", psd(responseResult,@"")]];
        }
    }

    if([loginErrors count])
        [ViewUtils simpleAlertView:self Title:ALERT_TITLE_LOGIN_FAIL Message:[loginErrors componentsJoinedByString:@"\n"] ButtonTitle:BTN_CONFIRM];
    [self hideOutsideLoginControl:YES];
}

#pragma mark - without network
/**
 *  C.2 如果无网络环境，跳至步骤D[离线登陆]
 *  D. [离线登陆]
 *     D.1 current > last 且 current - last < N 小时 => 点击此按钮进入主页，
 *     D.2 如果步骤D.1不符合，则弹出对话框显示错误信息
 */
- (void)actionLoginWithoutNetwork {
    NSMutableArray *errors = [self checkEnableLoginWithoutNetwork:self.user];
    
    if(![errors count]) {
        // 跳至主界面
        [self enterMainViewController];
    // D.2 如果步骤D.1不符合，则弹出对话框显示错误信息
    } else {
        [ViewUtils simpleAlertView:self Title:ALERT_TITLE_LOGIN_FAIL Message:[errors componentsJoinedByString:@"\n"] ButtonTitle:BTN_CONFIRM];
    }
}


/**
 *  无网络环境时，检测是否符合离线登陆条件
 *
 *  @param dict 上次用户成功登陆信息，无则赋值默认值
 *  @param user FieldText-User输入框内容
 *  @param pwd  FieldText-Pwd输入框内容
 *
 *  @return 不符合离线登陆条件错误信息数组
 */
- (NSMutableArray *) checkEnableLoginWithoutNetwork:(User *) user {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    // 上次登陆日期字符串转换成NSDate
    NSDate *lastDate    = [DateUtils strToDate:user.loginLast Format:LOGIN_DATE_FORMAT];
    NSDate *currentDate = [NSDate date];
    
    // 判断1: current > last, 即应该是升序
    NSComparisonResult compareResult = [currentDate compare:lastDate];
    if (compareResult != NSOrderedDescending) {
        [errors addObject:LOGIN_ERROR_LAST_GT_CURRENT];
    }
    
    // 判断2: last日期距离现在小于N小时
    NSTimeInterval intervalBetweenDates = [currentDate timeIntervalSinceDate:lastDate];
    int intervalHours = (int)intervalBetweenDates/60/60;
    if(intervalHours > LOGIN_KEEP_HOURS) {
        NSString *errorInfo = [NSString stringWithFormat:LOGIN_ERROR_EXPIRED_OUT_N_HOURS, user.loginLast, intervalHours, LOGIN_KEEP_HOURS];
        [errors addObject:errorInfo];
    }

    return errors;
}

#pragma mark - status bar settings

-(BOOL)prefersStatusBarHidden{
    return NO;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - assistant methods

-(void)enterMainViewController {
    for(NSArray *array in @[@[@"https://tsa-china.takeda.com.cn/uat/images/pic_category.zip", THUMBNAIL_DIRNAME, @"分类缩略图", @""],
                            @[@"http://tsa-china.takeda.com.cn/uat/public/999154.zip", FAVORITE_DIRNAME,@"使用手册1", @"999154"],
                            @[@"http://tsa-china.takeda.com.cn/uat/public/999155.zip", FAVORITE_DIRNAME,@"使用手册2", @"999155"]]) {
        
        self.labelPropmt.text = [NSString stringWithFormat:@"下载<%@>...", array[2]];
        [self downloadCategoryThumbnail:array[0] dir:array[1] SlideID:array[3]];
         [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    }
    
    MainViewController *mainView = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    UIWindow *window = self.view.window;
    window.rootViewController = mainView;
}


- (void)downloadCategoryThumbnail:(NSString *)downloadUrl dir:(NSString *)dirName SlideID:(NSString *)slideID {
    NSString *dirPath = [FileUtils getPathName:dirName];
    NSString *zipName = [downloadUrl lastPathComponent];
    NSString *zipPath = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    if([FileUtils checkFileExist:zipPath isDir:NO]) return;
    
    NSURL *url = [NSURL URLWithString:downloadUrl];
    NSData *zipData = [NSData dataWithContentsOfURL:url];
    [zipData writeToFile:zipPath atomically:YES];
    BOOL state = [SSZipArchive unzipFileAtPath:zipPath toDestination:dirPath];
    NSLog(@"解压%@  %@", zipPath, state ? @"成功" : @"失败");
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager removeItemAtPath:zipPath error:NULL];
    
    if(slideID && [slideID length] > 0) {
        NSString *dictPath = [FileUtils slideDescPath:slideID Dir:FAVORITE_DIRNAME Klass:SLIDE_CONFIG_FILENAME];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict = [FileUtils readConfigFile:dictPath];
        dict[CONTENT_FIELD_ID]      = slideID;
        dict[CONTENT_FIELD_TYPE]    = @"10000";
        dict[CONTENT_FIELD_DESC]    = dict[SLIDE_DESC_NAME];
        dict[CONTENT_FIELD_TITLE]   = dict[SLIDE_DESC_NAME];
        dict[CONTENT_FIELD_NAME]    = dict[SLIDE_DESC_NAME];
        dict[CONTENT_FIELD_PAGENUM] = [NSString stringWithFormat:@"%ld", (long)[dict[SLIDE_DESC_ORDER] count]];
        Slide *slide = [[Slide alloc] initSlide:dict isFavorite:YES];
        [slide save];
    }
}
@end