//
//  const.h
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_const_h
#define iSearch_const_h

// Global
#define DEBUG                  1
#define APP_LANG               @"zh-CN" // 应用系统的语言
#define BASE_URL1               @"http://localhost:3000" //
#define BASE_URL               @"http://demo.solife.us"  // 服务器url
#define CONFIG_DIRNAME         @"isearch_config" // 所有配置档放置在些文件夹下
#define DATE_FORMAT            @"yyyy/MM/dd HH:mm:SS" // 用户验证时，用到时间字符串时的存储格式
#define REORGANIZE_FORMAT      @"yyMMddHHMMSS" // 内容重组后新文件名称格式

#define SIZE_GRID_VIEW_CELL_WIDTH     120 // GridView Cell‘s width
#define SIZE_GRID_VIEW_CELL_HEIGHT    80 // GridView Cell‘s width
//  w:427  h:375 间距:20
#define SIZE_GRID_VIEW_PAGE_WIDTH     213 // 文档页面编辑时GridView Cell width
#define SIZE_GRID_VIEW_PAGE_HEIGHT    237 // 文档页面编辑时GridView Cell height
#define SIZE_GRID_VIEW_PAGE_MARGIN    20/2 // 文档页面编辑时GridView Cell 间距

#define GRID_VIEW_DELETE_BTN_OFFSET_X -15 // GridView Delete按钮平移位置
#define GRID_VIEW_DELETE_BTN_OFFSET_Y -15 // GridView Delete按钮平移位置
#define GRID_VIEW_DELETE_BTN_IMAGE    @"close_x.png" // GridView Delete按钮背影图片

// 登陆相关
#define LOGIN_URL_PATH         @"/demo/isearch/login" // 用户身份验证的url路径
#define LOGIN_CONFIG_FILENAME  @"login.plist" // 用户验证成功后，信息写入该配置档
#define LOGIN_KEEP_HOURS       12 // 用户在线登陆成功后，可LOGIN_KEEP_HOURS小时内[离线登陆]
#define LOGIN_DATE_FORMAT      @"yyyy/MM/dd HH:mm:SS" // 用户验证时，用到时间字符串时的存储格式
#define LOGIN_LAST_DEFAULT     @"1970/01/01 00:00:00" // 用户登陆前的默认登陆成功时间

// 目录相关
#define CONTENT_URL_PATH        @"/demo/isearch/content" // 请求目录的url路径
#define CONTENT_DIRNAME         @"content" // [目录]成功取得后，写入本地缓存文件夹
#define DOWNLOAD_DIRNAME        @"download"// [目录]中[文件]压缩包下载文件夹
#define FILE_DIRNAME            @"files"   // [目录]中[文件]压缩包下载成功解压至该文件夹
#define CONTENT_CONFIG_FILENAME @"content" // 目录同步功能中，界面切换传递参数使用plist配置档

// 离线搜索
#define DATABASE_DIRNAME         @"database" // 数据库文件存放的文件夹名称
#define DATABASE_FILEAME         @"iSearch.sqlite3" // 数据库实体存放的文件名称（后缀.sqlite3）
#define OFFLINE_SEARCH_TABLENAME @"offline_search" // 离线搜索时数据存储的数据库名称
#define OFFLINE_URL_PATH         @"/demo/isearch/offline" // 在线时获取服务器端文件列表数据，以备离线时搜索使用

// 内容重组
#define REORGANIZE_CONFIG_FILENAME @"reorganize"
#define REORGANIZE_DIRNAME         @"save" // 内容重组后，放置些文件夹中
#define FAVORITE_DIRNAME           @"favorite"
#define FILE_CONFIG_FILENAME       @"desc.json" // 文件的配置档名称
#define FILE_CONFIG_SWP_FILENAME  @"desc.json.swp" // 文件页面编辑时的配置档拷贝
// FILE_DIRNAME/fileId/{fileId_pageId.html,desc.json, fileId_pageId/fileId_pageId{.pdf, .gif}}
#define PAGE_HTML_FORMAT           @"html"
#define PAGE_IMAGE_FORMAT          @"gif"
#define PAGE_IMAGE_NOT_FOUND       @"not_found.png"

// 公告通知
#define NOTIFICATION_URL_PATH     @"/demo/isearch/notifications"
#define NOTIFICATION_CACHE        @"notifications.json"
#define NOTIFICATION_DIRNAME      @"notifications"
#define NOTIFICATION_OCCUR_DATE   @"occur_date" // 通告与预告的区分字段
#define NOTIFICATION_DATE_FORMAT  @"yyyy/MM/dd" // 预告精确到天，格式化日历控件
#define NOTIFICATION_TITLE_FONT   14.0f // 公告标题字体大小
#define NOTIFICATION_MSG_FONT     12.0f // 公告内容字体大小
#define NOTIFICATION_DATE_FONT    14.0f // 公告日期字体大小

#endif
