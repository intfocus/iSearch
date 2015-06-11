//
//  const.h
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iLogin_const_h
#define iLogin_const_h

// Global
#define APP_LANG               @"zh-CN" // 应用系统的语言
#define BASE_URL1               @"http://localhost:3000" //
#define BASE_URL               @"http://demo.solife.us"  // 服务器url
#define CONFIG_DIRNAME         @"config"

// 登陆相关
#define LOGIN_URL_PATH         @"/demo/isearch/login" // 用户身份验证的url路径
#define LOGIN_CONFIG_FILENAME  @"login" // 用户验证成功后，信息写入该配置档
#define LOGIN_KEEP_HOURS       12 // 用户在线登陆成功后，可LOGIN_KEEP_HOURS小时内[离线登陆]
#define LOGIN_DATE_FORMAT      @"yyyy/MM/dd HH:mm:SS" // 用户验证时，用到时间字符串时的存储格式
#define LOGIN_LAST_DEFAULT     @"1970/01/01 00:00:00" // 用户登陆前的默认登陆成功时间

// 目录相关
#define CONTENT_URL_PATH       @"/demo/isearch/content" // 请求目录的url路径
#define CONTENT_DIRNAME        @"content" // [目录]成功取得后，写入本地缓存文件夹
#define DOWNLOAD_DIRNAME       @"download"// [目录]中[文件]压缩包下载文件夹
#define FILE_DIRNAME           @"files"   // [目录]中[文件]压缩包下载成功解压至该文件夹
#define CONTENT_CONFIG_FILENAME @"content" // 目录同步功能中，界面切换传递参数使用plist配置档



#endif
