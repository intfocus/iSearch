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
//  一、 界面初始化操作
//
//  A. 查找login.plist文件
//      A.1 找不到，进入空白登陆界面，跳至步骤C
//      A.2 找到，进入步骤B
//
//  B. 界面控件初始化(读取login.plist文件) TODO login.plist为空的情况
//      B.1 TextField-User输入框信息放置上次登陆成功时输入信息，默认为空字符串
//      B.2 TextField-PWD输入框，如果上次登陆成功有勾选[记住密码]则预填充密码显示为*，否则置空
//      B.3 Switch-RememberPassword控件设置上次登陆成功配置，默认@"0" (don't remember password)
//
//  C. [登陆]按钮处理步骤
//      C.1 界面输入框、按钮等控件disabeld
//      C.2 如果无网络环境，跳至步骤D[离线登陆]
//      C.3 取得输入内容，并作去除前后空格等处理
//      C.4 检测TextField-User、TextField-PWD输入框内容不可为空，进入步骤C,否则跳至步骤C.alert
//      C.5 http post至server
//          POST /LOGIN_URL_PATH ,{
//              user: user,         -- user-name or user-email
//              password: password, -- login password
//              lang: zh-CN         -- app language, default: zh-CN
//          }
//          response {
//              code: 1,            -- success: 1; failed: 0
//              info: { uid: 1 ...} -- success: { uid: 1 ...}; failed: { error: ... }
//           }
//          *注意* HttpPost响应体中的文本语言取决于Post时params[:lang]
//
//          C.5.1 登陆成功,跳至步骤 C.success
//          C.5.2 服务器端反馈错误信息，跳至步骤 C.alert
//          C.5.3 服务器无响应，跳至步骤 C.alert
//      C.alert 弹出警示框显示错误内容，控件内容无修改, 跳至步骤C.done
//      C.success
//          last为当前时间(格式LOGIN_DATE_FORMAT)
//          把user/password/last/remember_password写入login.plist文件
//          跳至主页
//      C.done 界面输入框、按钮等控件enabeld
//
//   D. [离线登陆]
//      D.1 如果TextField-User、TextField-PWD与login.plist成功登陆信息一致，
//          存在且 current > last 且 current - last < N 小时 => 点击此按钮进入主页，
//      D.2 如果步骤D.1不符合，则弹出对话框显示错误信息
//
//
//   **注意**
//  1. 读取登陆信息配置档，有则读取，无则使用默认值 #readLoginConfigFile#
//  2. 修改login.plist只存在于一种情况: 有网络环境下，HttpPost服务器登陆成功时

#import "LoginViewController.h"
#import "common.h"
#import "ViewUtils.h"
#import "MainViewController.h"

@interface LoginViewController ()
// i18n controls
@property (weak, nonatomic) IBOutlet UILabel *labelUser;
@property (weak, nonatomic) IBOutlet UILabel *labelPwd;
@property (weak, nonatomic) IBOutlet UILabel *labelSwitch;

// function controls
@property (weak, nonatomic) IBOutlet UITextField *fieldUser;
@property (weak, nonatomic) IBOutlet UITextField *fieldPwd;
@property (weak, nonatomic) IBOutlet UIButton *submit;
@property (weak, nonatomic) IBOutlet UISwitch *switchRememberPwd;
@property (retain, nonatomic) IBOutlet M13Checkbox *rememberPwd;

// logo动态效果
@property (strong, nonatomic) SKSplashView *splashView;
//Demo of how to add other UI elements on top of splash view
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation LoginViewController

/**
 *  界面由无到有时，执行此函数
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    // 登陆前 Logor动态效果
    // [self twitterSplash];
    
    // 多语言控制
    self.labelUser.text = LOGIN_LABEL_USER;
    self.labelPwd.text  = LOGIN_LABEL_PWD;
    self.labelSwitch.text = LOGIN_REMEMBER_PWD;
    [self.submit setTitle:LOGIN_BTN_SUBMIT forState:UIControlStateNormal];
    
    // TextField-PWD 设置成password格式，显示为*
    [self.fieldPwd setSecureTextEntry:YES];
    // [登陆]按钮点击事件
    [self.submit addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.fieldUser.placeholder = @"user";
    self.fieldPwd.placeholder = @"password";
    
    // checkbox - remember password
    self.rememberPwd = [[M13Checkbox alloc] initWithFrame:self.switchRememberPwd.frame title:LOGIN_REMEMBER_PWD];
    [self.rememberPwd titleLabel].textColor = [UIColor lightGrayColor];
    // checkbox border color
    [self.rememberPwd setStrokeColor:[UIColor lightGrayColor]];
    [self.rememberPwd setCheckAlignment:M13CheckboxAlignmentLeft];
    [self.rememberPwd autoFitWidthToText];
    
    [[self.switchRememberPwd superview] addSubview:self.rememberPwd];
    [self.switchRememberPwd removeFromSuperview];
    
    // 用户登陆信息记录的配置档路径
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:LOGIN_CONFIG_FILENAME];
    
    // A.1 找不到配置档，进入空白登陆界面，跳至步骤C
    if(![FileUtils checkFileExist:configPath isDir:false]) {
        // 界面不做任何操作
    } else {
        //  B. 界面控件初始化(读取login.plist文件)
        //      B.1 TextField-User输入框信息放置上次登陆成功时输入信息，默认为空字符串
        //      B.2 TextField-PWD输入框，如果上次登陆成功有勾选[记住密码]则预填充密码显示为*，否则置空
        //      B.3 Switch-RememberPassword控件设置上次登陆成功配置，默认@"0" (don't remember password)
        NSMutableDictionary *dict = [self readLoginConfigFile];
        self.fieldUser.text = dict[@"user"];
        [self.rememberPwd setCheckState:false];
        if([dict[@"remember_password"] isEqualToString:@"1"]) {
            self.fieldPwd.text  = dict[@"password"];
            [self.rememberPwd setCheckState:true];
        }
    }
}
/**
 *  界面每次出现时都会被触发，动态加载动作放在这里
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/**
 *  twitter加载Logo的动态效果
 */
- (void) twitterSplash {    //Twitter style splash
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"twitterIcon.png"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = [UIColor colorWithRed:0.25098 green:0.6 blue:1.0 alpha:1.0];
    _splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon backgroundColor:twitterColor animationType:SKSplashAnimationTypeNone];
    _splashView.delegate = self; //Optional -> if you want to receive updates on animation beginning/end
    _splashView.animationDuration = 2; //Optional -> set animation duration. Default: 1s
    [self.view addSubview:_splashView];
    [_splashView startAnimation];
}


//////////////////////////////////////////////////////////////
#pragma mark memory management
//////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  C. [登陆]按钮处理步骤
//      C.1 界面输入框、按钮等控件disabeld
//      C.2 如果无网络环境，跳至步骤D[离线登陆]
//      C.3 取得输入内容，并作去除前后空格等处理
//      C.4 检测TextField-User、TextField-PWD输入框内容不可为空，进入步骤C,否则跳至步骤C.alert
//      C.5 http post至server
//          POST /LOGIN_URL_PATH ,{
//              user: user,         -- user-name or user-email
//              password: password, -- login password
//              lang: zh-CN         -- app language, default: zh-CN
//          }
//          response {
//              code: 1,            -- success: 1; failed: 0
//              info: { uid: 1 ...} -- success: { uid: 1 ...}; failed: { error: ... }
//           }
//          *注意* HttpPost响应体中的文本语言取决于Post时params[:lang]
//
//          C.5.1 登陆成功,跳至步骤 C.success
//          C.5.2 服务器端反馈错误信息，跳至步骤 C.alert
//          C.5.3 服务器无响应，跳至步骤 C.alert
//      C.alert 弹出警示框显示错误内容，控件内容无修改, 跳至步骤C.done
//      C.success
//          last为当前时间(格式LOGIN_DATE_FORMAT)
//          把user/password/last/remember_password写入login.plist文件
//          跳至主页
//      C.done 界面输入框、按钮等控件enabeld

- (IBAction)submitAction:(id)sender {
    
    [self enterMainViewController];
    return;
    
    // C.1 界面输入框、按钮等控件disabeld
    [self switchCtlStateWhenLogin:false];

    // 不符合登陆条件的错误信息
    // 以该数组是否为空判断是否符合登陆条件
    NSMutableArray *loginErrors = [[NSMutableArray alloc] init];
    
    // C.3 取得输入内容，并作去除前后空格等处理
    NSString *user = [self.fieldUser.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *pwd = [self.fieldPwd.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    // C.2 如果无网络环境，跳至步骤D[离线登陆]
    if(![HttpUtils isNetworkAvailable]) {
        NSMutableDictionary *dict = [self readLoginConfigFile];
        loginErrors = [self loginOfflineAction:dict User:user Pwd:pwd];
        
        
        // 3.done 界面输入框、按钮等控件enabeld, switch复原
        [self switchCtlStateWhenLogin:true];
        
        return; // 离线登陆，则到此结束
    }
    
    // C.4 检测TextField-User、TextField-PWD输入框内容不可为空，进入步骤C,否则跳至步骤C.alert
    if(![loginErrors count]) {
        if(!user.length) [loginErrors addObject:LOGIN_ERROR_USER_EMPTY];
        if(!pwd.length)  [loginErrors addObject:LOGIN_ERROR_PWD_EMPTY];
    }

    // C.5 http post至server
    if(![loginErrors count]) {
        //  POST /LOGIN_URL_PATH ,{
        //      user: user,         -- user-name or user-email
        //      password: password, -- login password
        //      lang: zh-CN         -- app language, default: zh-CN
        //  }
        //  response {
        //      code: 1,            -- success: 1; failed: 0
        //      info: { uid: 1 ...} -- success: { uid: 1 ...}; failed: { error: ... }
        //  }
        NSString *loginParams = [NSString stringWithFormat:@"user=%@&password=%@&lang=%@", user, pwd, APP_LANG];
        NSString *response = [HttpUtils login:loginParams];
        
        NSError *error;
        NSMutableDictionary *mutableDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
      
        // 服务器交互成功
        if(!error) {
            // 服务器响应json格式为: { code: 1, info: {} }
            //  code = 1 则表示服务器与客户端交互成功, info为用户信息,格式为JSON
            //  code = 非1 则表示服务器方面查检出有错误， info为错误信息,格式为JSON
            NSNumber            *code = [mutableDictionary objectForKey:@"code"];
            NSMutableDictionary *info = [mutableDictionary objectForKey:@"info"];
            // C.5.1 登陆成功,跳至步骤 C.success
            if([code isEqualToNumber:[NSNumber numberWithInt:1]]) {
                //      3.success
                //          last为当前时间(格式LOGIN_DATE_FORMAT)
                //          password = remember_password ? 控件内容 : @""
                //          把user/password/last/remember_password写入login.plist文件
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                [data setObject:user forKey:@"user"];
                [data setObject:pwd forKey:@"password"];
                [data setObject:(self.rememberPwd.checkState ? @"1" : @"0") forKey:@"remember_password"];
                [data setObject:[ViewUtils dateToStr:[NSDate date] Format:LOGIN_DATE_FORMAT] forKey:@"last"];
                [data writeToFile:[self loginConfigPath] atomically:YES];
                
                // 跳至主页
                [ViewUtils simpleAlertView:self Title:@"登陆成功" Message:@"TODO# 跳至主页" ButtonTitle:BTN_CONFIRM];
                
            } else {
                // C.5.2 服务器端反馈错误信息，跳至步骤 C.alert
                [loginErrors addObject:[info objectForKey:@"error"]];
            }
        // C.5.3 服务器无响应，跳至步骤 C.alert
        } else {
            [loginErrors addObject:ALERT_MSG_LOGIN_SERVER_ERROR];
        }
    }
    
    // 3.alert, 此if判断显得有些多余, loginErrors不可能为空 :)
    if([loginErrors count])
        [ViewUtils simpleAlertView:self Title:ALERT_TITLE_LOGIN_FAIL Message:[loginErrors componentsJoinedByString:@"\n"] ButtonTitle:BTN_CONFIRM];
    else
        NSLog(@"测试阶段，登陆成功时界面没有跳转，打印此信息，请勿心慌.");
        
    
    // 3.done 界面输入框、按钮等控件enabeld, switch复原
    [self switchCtlStateWhenLogin:true];
}

/**
 *  集中管理界面控件是否禁用
 *
 *  @param isEnaled 禁用则设置为false
 */
- (void) switchCtlStateWhenLogin:(BOOL)isEnaled {
    [self.fieldPwd setEnabled: isEnaled];
    [self.fieldUser setEnabled: isEnaled];
    [self.submit setEnabled: isEnaled];
    [self.rememberPwd setEnabled: isEnaled];
}

/**
 *  C.2 如果无网络环境，跳至步骤D[离线登陆]
 *  D. [离线登陆]
 *     D.1 如果TextField-User、TextField-PWD与login.plist成功登陆信息一致，
 *           存在且 current > last 且 current - last < N 小时 => 点击此按钮进入主页，
 *     D.2 如果步骤D.1不符合，则弹出对话框显示错误信息
 */
- (NSMutableArray *) loginOfflineAction:(NSMutableDictionary *)dict
                       User:(NSString *) user
                        Pwd:(NSString *) pwd {
    
    NSMutableArray *errors = [self checkEnableLoginOffline:dict User:user Pwd:pwd];
    
    if(![errors count]) {
        [ViewUtils simpleAlertView:self Title:@"登陆成功" Message:@"TODO# 跳至主页[离线]" ButtonTitle:BTN_CONFIRM];
        
    // D.2 如果步骤D.1不符合，则弹出对话框显示错误信息
    } else {
        [ViewUtils simpleAlertView:self Title:ALERT_TITLE_LOGIN_FAIL Message:[errors componentsJoinedByString:@"\n"] ButtonTitle:BTN_CONFIRM];
    }
    return errors;
}

/**
 *  取得login配置档路径
 *
 *  @return login配置档路径
 */
- (NSString *) loginConfigPath {
    return [FileUtils getPathName:CONFIG_DIRNAME FileName:LOGIN_CONFIG_FILENAME];
}

/**
 *  读取用户上次登陆信息，有则读取，无则使用默认值
 *
 *  @return 上次登陆信息
 */
- (NSMutableDictionary*) readLoginConfigFile {
    NSString *configPath = [self loginConfigPath];
    NSMutableDictionary *dict = [NSMutableDictionary alloc];
    if([FileUtils checkFileExist:configPath isDir:false]) {
        dict = [dict initWithContentsOfFile:configPath];
    } else {
        dict = [dict initWithObjectsAndKeys:@"user", @"", @"password", @"", @"last", LOGIN_LAST_DEFAULT, @"remember_password",@"0", nil];
    }
    
    return dict;
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
- (NSMutableArray *) checkEnableLoginOffline: (NSMutableDictionary *) dict
                            User: (NSString *) user
                             Pwd: (NSString *) pwd {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    // 上次登陆日期字符串转换成NSDate
    NSDate *lastDate    = [DateUtils strToDate:dict[@"last"] Format:LOGIN_DATE_FORMAT];
    NSDate *currentDate = [NSDate date];
    
    // 判断1: current > last, 即应该是升序
    NSComparisonResult compareResult = [currentDate compare:lastDate];
    if (compareResult != NSOrderedDescending)
        [errors addObject:LOGIN_ERROR_LAST_GT_CURRENT];
    
    // 判断2: last日期距离现在小于N小时
    NSTimeInterval intervalBetweenDates = [currentDate timeIntervalSinceDate:lastDate];
    if(intervalBetweenDates > LOGIN_KEEP_HOURS*60*60)
        [errors addObject:LOGIN_ERROR_EXPIRED_OUT_N_HOURS];
        
    
    // 判断3: 输入框user/pwd内容与配置档内容是否一致
    if(![user isEqualToString:dict[@"user"]])
        [errors addObject:LOGIN_ERROR_USER_NOT_MATCH];
    if(![pwd isEqualToString:dict[@"password"]])
        [errors addObject:LOGIN_ERROR_PWD_NOT_MATCH];

    return errors;
}

// pragm mark - 进入主界面
-(void)enterMainViewController{
    // 这里最好换成import，不要用NSClassFromString
    UIViewController *mainView = [[NSClassFromString(@"MainViewController") alloc] initWithNibName:@"MainViewController" bundle:nil];
    //MainViewController *mainView = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    UIWindow *window = self.view.window;
    window.rootViewController = mainView;
}


// pragm mark - screen style setting
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


@end
