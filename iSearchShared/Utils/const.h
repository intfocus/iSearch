//
//  const.h
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_const_h
#define iSearch_const_h

// 主界面左侧导航按钮Tag
typedef NS_ENUM(NSInteger, EntryButtonTag){
    EntryButtonIndex=0,
    EntryButtonFavorite=1,
    EntryButtonNotification=2,
    EntryButtonDownload=3,
    EntryButtonSetting=4,
    EntryButtonLogout=5,
};

// Global
#define DEBUG                  1
#define PARAM_LANG             @"lang" // 传递给服务器的语言key
#define APP_LANG               @"zh-CN" // 应用系统的语言
#define BASE_URL               @"http://192.168.0.115" //
#define BASE_URL1               @"http://demo.solife.us"  // 服务器url
#define CONFIG_DIRNAME         @"isearch_config" // 所有配置档放置在些文件夹下
#define DATE_FORMAT            @"yyyy/MM/dd HH:mm:SS" // 用户验证时，用到时间字符串时的存储格式
#define DATE_SIMPLE_FORMAT     @"yyyy/MM/dd" // 公告通知api使用及日历控件
#define REORGANIZE_FORMAT      @"yyMMddHHMMSS" // 内容重组后新文件名称格式
#define LOCAL_OR_SERVER_LOCAL  @"local" // 获取服务器信息或本地缓存
#define LOCAL_OR_SERVER_SREVER @"server"// 获取服务器信息或本地缓存
#define DATABASE_DIRNAME         @"Database" // 数据库文件存放的文件夹名称
#define DATABASE_FILEAME         @"iSearch.sqlite3" // 数据库实体存放的文件名称（后缀.sqlite3）

// ActionLogger
#define ACTION_LOGGER_URL_PATH @"/phptest/api/logjson.php"

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

// 目录相关(_FILE与获取文件相关，默认获取分类)
#define CONTENT_URL_PATH        @"/uat/api/Categories_Api.php" // 请求目录的url路径
#define CONTENT_FILE_URL_PATH   @"/uat/api/Files_Api.php" // 请求目录的url路径
#define CONTENT_DOWNLOAD_URL_PATH @"/uat/api/Filedown_Api.php"
#define CONTENT_DIRNAME         @"Content" // [目录]成功取得后，写入本地缓存文件夹
#define DOWNLOAD_DIRNAME        @"Download"// [目录]中[文件]压缩包下载文件夹
#define FILE_DIRNAME            @"Files"   // [目录]中[文件]压缩包下载成功解压至该文件夹
#define CONTENT_CONFIG_FILENAME @"content.json" // 目录同步功能中，界面切换传递参数使用plist配置档
#define FILE_DISPLAY_FILENAME   @"display.json" // 目录中文件已经下载，点击[演示];
// 目录API参数
#define CONTENT_TYPE_FILE       @"File"
#define CONTENT_TYPE_CATEGORY   @"Category"
#define CONTENT_PARAM_DEPTID    @"did" // 部门ID
#define CONTENT_PARAM_PARENTID  @"pid" // 分类父ID
#define CONTENT_PARAM_FILE_CATEGORYID @"cid" // 待加载分类ID
#define CONTENT_PARAM_FILE_DWONLOADID @"fid" // 下载文件ID
// 目录API字段
#define CONTENT_FIELD_DATA      @"data" // 数据数组
#define CONTENT_FIELD_ID        @"Id" // 分类ID
#define CONTENT_FIELD_NAME      @"Name" // 分类名称
#define CONTENT_FIELD_CREATEDATE @"EditTime" // 创建时间
#define CONTENT_FIELD_TYPE      @"Type" // 类型: 0为目录，1为文件
#define CONTENT_FIELD_URL       @"DownloadUrl" // 文件下载链接，代码拼接而成

// 离线搜索/批量下载
#define OFFLINE_URL_PATH         @"/uat/api/filelist_api.php" // 在线时获取服务器端文件列表数据，以备离线时搜索使用
// API参数
#define OFFLINE_PARAM_DEPTID     @"did"
// API字段
#define OFFLINE_FIELD_DATA       @"data"
#define OFFLINE_FIELD_ID         @"Id"
#define OFFLINE_FIELD_TYPE       @"Type"
#define OFFLINE_FIELD_DESC       @"Desc"
#define OFFLINE_FIELD_TAGS       @"Tags"
#define OFFLINE_FIELD_NAME       @"Name"
#define OFFLINE_FIELD_TITLE      @"Title"
#define OFFLINE_FIELD_CATEGORYNAME @"CategoryName"
#define OFFLINE_FIELD_ZIPSIZE    @"ZipSize"
#define OFFLINE_FIELD_PAGENUM    @"PageNo"
// 数据库表字段
#define OFFLINE_TABLE_NAME       @"offline" // 离线搜索时数据存储的数据库名称
#define OFFLINE_COLUMN_FILEID    @"file_id"
#define OFFLINE_COLUMN_NAME      @"file_name"
#define OFFLINE_COLUMN_TYPE      @"file_type"
#define OFFLINE_COLUMN_DESC      @"desc"
#define OFFLINE_COLUMN_TAGS      @"tags"
#define OFFLINE_COLUMN_CATEGORYNAME @"category_name"
#define OFFLINE_COLUMN_PAGENUM   @"page_num"
#define OFFLINE_COLUMN_ZIPURL    @"zip_url"
#define OFFLINE_COLUMN_ZIPSIZE   @"zip_size"


// 内容重组
#define REORGANIZE_CONFIG_FILENAME @"reorganize.json"
#define REORGANIZE_DIRNAME         @"Save" // 内容重组后，放置些文件夹中
#define FAVORITE_DIRNAME           @"Favorite"
#define FILE_CONFIG_FILENAME       @"desc.json" // 文件的配置档名称
#define FILE_CONFIG_SWP_FILENAME  @"desc.json.swp" // 文件页面编辑时的配置档拷贝
// FILE_DIRNAME/fileId/{fileId_pageId.html,desc.json, fileId_pageId/fileId_pageId{.pdf, .gif}}
#define PAGE_HTML_FORMAT           @"html"
#define PAGE_IMAGE_FORMAT          @"gif"
#define PAGE_IMAGE_NOT_FOUND       @"not_found.png"

// 公告通知
#define NOTIFICATION_URL_PATH     @"/uat/api/News_api.php"
#define NOTIFICATION_CACHE        @"notifications.json"
#define NOTIFICATION_DIRNAME      @"notifications"
#define NOTIFICATION_OCCUR_DATE   @"occur_date" // 通告与预告的区分字段
#define NOTIFICATION_TITLE_FONT   14.0f // 公告标题字体大小
#define NOTIFICATION_MSG_FONT     12.0f // 公告内容字体大小
#define NOTIFICATION_DATE_FONT    14.0f // 公告日期字体大小
// 公告API参数
#define NOTIFICATION_PARAM_DEPTID     @"did" // 部门ID
#define NOTIFICATION_PARAM_DATESTR    @"strdate" // 当前日期
// 公告API响应字段
#define NOTIFICATION_FIELD_STATUS     @"status"
#define NOTIFICATION_FIELD_COUNT      @"count"
#define NOTIFICATION_FIELD_GGDATA     @"ggdata" // 公告数据
#define NOTIFICATION_FIELD_HDDATA     @"hddata" // 预告活动
#define NOTIFICATION_FIELD_TITLE      @"Title"  // 标题
#define NOTIFICATION_FIELD_MSG        @"Msg"     // 内容
#define NOTIFICATION_FIELD_CREATEDATE @"EditTime" // 创建日期
#define NOTIFICATION_FIELD_OCCURDATE  @"OccurTime"// 发生日期（公告为空)


#endif
