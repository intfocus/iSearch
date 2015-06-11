//
//  AppDelegate.m
//  iReorganize
//
//  Created by lijunjie on 15/5/15.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  内容重组 + 收藏
//
//  约定:
//      文件下载放置在 FILE_DIRNAME/fileID
//      收藏文件放置在 FAVORITE_DIRNAME/fileID
//      内容重组新建文件名称格式: ryyMMddHHmmSS, 开头[r]eorganize
//      文件组成 FILE_DIRNAME/fileId/{fileId_pageId.html, fileId_pageId.gif, desc.json}
//  **说明** fileId/desc.json 是灵魂文件
//
//  需求:
//      A 内容重组（文件页面）
//          A1（编辑）=> 保存
//              A1.1 新建，需填写name/desc, 创建文件夹FILE_DIRNAME/ryyMMddHHMMSS
//              A1.2 已存在， 取得文件ID
//          A2 把页面html/gif从当前fileId拷贝至选择或新建的文件ID中
//      B 收藏 - TODO
//          B1 点击某文件的[收藏]， 把文件从FILE_DIRNAME/fileId拷贝至FAVORITE_DIRNAME/fileID
//          B2 取消[收藏], 删除FAVORITE_DIRNAME/fileID
//
//  实现流程:
//  A 本地文件展示界面
//      A1 扫描<已下载或内容重组>文件列表
//         存在fileId/desc.json则读取，并转换格式为NSMutableDirecotry，添加至全局变量_data
//         不存在则忽略
//      A2 GridView样式展示，并读取_data，显示<文件缩略图/文件名称>
//      A3 文件顺序[编辑] - TODO
//      A4 文件移除 - TODO
//      A5 文件收藏 - TODO
//  B 文件页面 - 内容重组
//      B1 点击文件[详细]时，该文件ID写入CONFIG_DIRNAME/REORGANIZE_CONFIG_DIRNAME[@"DetailID"]
//      B2 读取DetailId/desc.json[@"order"]并按该顺序写入_data
//      B3 GridView样式展示，并读取_data，显示<fileId_pageId.gif>
//      B4 页面顺序 - 长按[页面]至颤动，搬动至指定位置，重置fileId/desc[@"order"]
//      B5 页面移除 - 点击导航栏中的[移除], 各页面左上角出现[x]按钮，点击[x]则会移除fileId_pageId.{html,gif}，并修改desc.json[@"order"]
//      B6 内容重组 - 点击导航栏中的[选择], 点击指定页面，页面会出现[V]表示选中，选择想要的页面后，再点击导航栏中的[保存] ->
//          弹出选择框有已经重组文件名称，选择指定文件名称，则会把页面拷贝至选择的fileId/下并修改desc.json[@"order"]
//          如果新建内容重组文件，则输入文件名称、文件描述，然后生成新的fileId(ryyMMddHHmmSS), 把页面拷贝至新的fileId/下，并创建desc.json
//
//  **TODO**
//  fileId.zip中desc.json{name,desc,id,order}写入后不会再变动，但服务器端用户会修改name/desc，
//  所以app每次启动时，读取CONTENT_DIRNAME/fileId.json并重置desc.json内容
//
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
