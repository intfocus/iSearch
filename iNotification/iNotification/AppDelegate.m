//
//  AppDelegate.m
//  iNotification
//
//  Created by lijunjie on 15/5/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  公告通知
//
//  依赖插件:
//      pod 'JTCalendar', "~>1.2.3"
//
//  A 从服务器获取公告通知
//      A.1 error => 跳至步骤B
//      A.2 无法连接 => 跳至步骤B
//      A.3 成功 =>
//          如果存在缓存文件，则删除（待确认是否会保证该文件可读取）
//          把服务器响应内容写入本地缓存文件中
//          继续步骤C
//
//  B 从本地缓存读取旧的公告通知
//      B1. 存在缓存则读取
//      B2. 不存在则初始化公告通知数组为空， 继续步骤C
//
//  C 处理公告通知数组实例
//      C1. 遍历公告通知数组分成:
//          公告数组：元素为NSDirecotry, [发生日期]为空
//          预告数组：元素为NSDirecotry, [发成日期]不为空
//          预告日期数组: 元素为字符串， [发生日期]不空，并格式化为"yyyy/mm/dd", *去重* 。 为日历控件加状态使用
//
//  D 控件
//      D1. 公告列表栏，显示公告数组中信息
//          公告内容长度不一致时，每个公告单元高度随着变化
//          日期为今天则显示"今天"，否则显示[yyyy/MM/dd]
//      D2. 预告使用日历控件，有预告的日期在控件中加状态，点击日期在下方显示预告内容
//      D3. 可以收缩日历控件，腾出更多空间显示预告内容 (TODO)
//
//  E 数组格式
//      json {
//          title: 标题,
//          msg: 内容,
//          created_date: 发布时间
//          occur_date: 发生时间
//          type: 通告类型isearch/ilearn
//      }
//
//   BUG
//   1. 从服务器获取公告失败时，读取公告的缓存文件报错

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [self.window makeKeyAndVisible];
    return YES;
}

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
