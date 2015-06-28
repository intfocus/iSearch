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
#import "User.h"
#import "common.h"
#import "ViewUtils.h"
#import "MainViewController.h"
#import "SSZipArchive.h"

@interface LoginViewController ()
// function controls
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
//@property (retain, nonatomic) IBOutlet M13Checkbox *rememberPwd;

// Demo of how to add other UI elements on top of splash view
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

// login outside web
@property (weak, nonatomic) IBOutlet UIWebView *webViewLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnNavBack;
@property (weak, nonatomic) IBOutlet UILabel *labelLoginTitle;

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
    [self hideOutsideLoginControl:YES];
    /**
     控件事件
    */
    [self.btnNavBack addTarget:self action:@selector(actionOutsideLoginClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSubmit addTarget:self action:@selector(actionSubmit:) forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"view:%@", NSStringFromCGRect(self.view.bounds));
    NSLog(@"webview:%@", NSStringFromCGRect(self.webViewLogin.bounds));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.view bringSubviewToFront:self.btnSubmit];
}

#pragma mark memory management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    BOOL isNetworkAvailable = [HttpUtils isNetworkAvailable];
    NSLog(@"network is available: %@", isNetworkAvailable ? @"true" : @"false");
    if(isNetworkAvailable) {
        [self actionClearCookies];
        [self performSelector:@selector(actionOutsideLogin:) withObject:self];
    } else {
        [self performSelector:@selector(actionLoginWithoutNetwork:) withObject:self];
    }
    
}

#pragma mark - assistant methods

#pragma mark - within network
- (IBAction)actionOutsideLogin:(id)sender {
    [self performSelector:@selector(actionOutsideLoginRefresh:) withObject:self];
    [self hideOutsideLoginControl:NO];
    if(!self.timerReadCookie || ![self.timerReadCookie isValid]) {
        self.timerReadCookie = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(actionReadCookieTimer:) userInfo:nil repeats:YES];
    }
    self.timerCount = 0;
    [self.timerReadCookie fire];
}

- (IBAction)actionOutsideLoginRefresh:(id)sender {
    NSString *urlString = @"https://tsa-china.takeda.com.cn/uat/saml/sp/index.php?sso";
    NSURL *url = [NSURL URLWithString:urlString];
    [self.webViewLogin loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)actionReadCookieTimer:(id)sender {
    NSLog(@"timer: %ld", (long)self.timerCount);
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
        NSLog(@"got it, samlNameId: %@", cookieValue);
        if([cookieValue isEqualToString:@"error000"]) {
            [self hideOutsideLoginControl:YES];
            [ViewUtils simpleAlertView:self Title:ALERT_TITLE_LOGIN_FAIL Message:@"服务器登录失败" ButtonTitle:BTN_CONFIRM];
        } else {
            self.cookieValue = cookieValue;
            [self performSelector:@selector(actionOutsideLoginSuccessfully:) withObject:self];
        }
        [self.timerReadCookie invalidate];
        [self actionClearCookies];
    }
    self.timerCount++;
}

- (void) hideOutsideLoginControl:(BOOL)isHidden {
    NSLog(@"view:%@", NSStringFromCGRect(self.view.bounds));
    NSLog(@"webview:%@", NSStringFromCGRect(self.webViewLogin.bounds));
    NSLog(@"hidden:%@, webview:%@", (isHidden ? @"true" : @"false"), NSStringFromCGRect(self.webViewLogin.bounds));
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

- (IBAction)actionOutsideLoginSuccessfully:(id)sender {
    NSMutableArray *loginErrors = [[NSMutableArray alloc] init];

        NSString *urlPath = [NSString stringWithFormat:@"%@?%@=%@&%@=%@", LOGIN_URL_PATH, PARAM_LANG, APP_LANG, LOGIN_PARAM_UID, self.cookieValue];
        NSString *response = [HttpUtils httpGet:urlPath];
        NSError *error;
        NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:&error];
        NSErrorPrint(error, @"login response convert into json");
        
        // 服务器交互成功
        if(!error) {
            // 服务器响应json格式为: { code: 1, info: {} }
            //  code = 1 则表示服务器与客户端交互成功, info为用户信息,格式为JSON
            //  code = 非1 则表示服务器方面查检出有错误， info为错误信息,格式为JSON
            //            NSNumber *responseStatus = [responseDict objectForKey:LOGIN_FIELD_STATUS];
            NSString *responseResult = [responseDict objectForKey:LOGIN_FIELD_RESULT];
            // C.5.1 登陆成功,跳至步骤 C.success
            // if([responseStatus isEqualToNumber:[NSNumber numberWithInt:1]]) {
            if([responseResult length] == 0) {
                //      3.success
                //          last为当前时间(格式LOGIN_DATE_FORMAT)
                //          password = remember_password ? 控件内容 : @""
                //          把user/password/last/remember_password写入login.plist文件
                // 界面输入信息
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
                
                // 跳至主界面
                [self enterMainViewController];
                return;
            } else {
                [loginErrors addObject:[NSString stringWithFormat:@"服务器提示:%@", responseResult]];
            }
        } else {
            [loginErrors addObject:[NSString stringWithFormat:@"服务器响应解析失败:%@", response]];
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
- (IBAction)actionLoginWithoutNetwork:(id)sender {
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
    if(intervalBetweenDates > LOGIN_KEEP_HOURS*60*60) {
        [errors addObject:LOGIN_ERROR_EXPIRED_OUT_N_HOURS];
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

-(void)enterMainViewController{
    [self downloadCategoryThumbnail:@"https://tsa-china.takeda.com.cn/uat/images/pic_category.zip" dir:THUMBNAIL_DIRNAME];
    [self downloadCategoryThumbnail:@"http://tsa-china.takeda.com.cn/uat/public/999154.zip" dir:SLIDE_DIRNAME];
    [self downloadCategoryThumbnail:@"http://tsa-china.takeda.com.cn/uat/public/999155.zip" dir:SLIDE_DIRNAME];

    
    // UIViewController *mainView = [[NSClassFromString(@"MainViewController") alloc] initWithNibName:@"MainViewController" bundle:nil];
    MainViewController *mainView = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    UIWindow *window = self.view.window;
    window.rootViewController = mainView;
}

- (void)downloadCategoryThumbnail:(NSString *)downloadUrl dir:(NSString *)dirName {
//    NSString *downloadUrl = @"https://tsa-china.takeda.com.cn/uat/images/pic_category.zip";
    NSString *zipName = [downloadUrl lastPathComponent];
    NSString *zipPath = [FileUtils getPathName:DOWNLOAD_DIRNAME FileName:zipName];
    if([FileUtils checkFileExist:zipPath isDir:NO]) {
        return;
    }
    NSURL *url = [NSURL URLWithString:downloadUrl];
    NSData *zipData = [NSData dataWithContentsOfURL:url];
    NSString *thumbnailPath = [FileUtils getPathName:dirName];
    [zipData writeToFile:zipPath atomically:YES];
    BOOL state = [SSZipArchive unzipFileAtPath:zipPath toDestination:thumbnailPath];
    NSLog(@"解压%@  %@", zipPath, state ? @"成功" : @"失败");
}



@end
