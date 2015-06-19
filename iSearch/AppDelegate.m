//
//  AppDelegate.m
//  iSearch
//
//  Created by lijunjie on 15/5/29.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    RegisterUserNotification();
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandlerInstance);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //self.window.rootViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    // 每次启动app都需要进入登录界面
    self.window.rootViewController=[[NSClassFromString(@"LoginViewController") alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.window makeKeyAndVisible];
    return YES;
}

// 捕捉到异常时，推送通知；需要真机测试
void SOS_Notification(NSString* signal){
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification) {
        notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:1];
        notification.alertBody=signal;
        notification.userInfo=nil;
        notification.soundName=UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

void RegisterUserNotification(){
    UIApplication *application=[UIApplication sharedApplication];
    UIUserNotificationType types=UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge;
    UIUserNotificationSettings *user=[UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:user];
}

void UncaughtExceptionHandlerInstance(NSException *exception){
    SOS_Notification(exception.name);
}
/**
 *  不同展示，屏幕横竖展示方式需求不同，在此设置
 *
 *  @param application ...
 *  @param window      ...
 *
 *  @return 屏幕横竖展示方式
 */
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    if ([self.window.rootViewController.presentedViewController isKindOfClass: [MainViewController class]]) {
//        return UIInterfaceOrientationMaskLandscape;
//    }
//    else
//        return UIInterfaceOrientationMaskLandscape;
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
