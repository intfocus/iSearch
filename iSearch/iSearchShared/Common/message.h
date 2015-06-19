//
//  message.h
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iLogin_message_h
#define iLogin_message_h


// login error
#define LOGIN_ERROR_USER_EMPTY     @"用户名不可以空"
#define LOGIN_ERROR_PWD_EMPTY      @"登陆密码不可以空"
#define LOGIN_ERROR_LAST_TIMEOUT   @"距离上次在线登陆时过久，请重新登陆。\n上次登陆:"
#define LOGIN_ERROR_USER_NOT_MATCH @"本次登陆用户与上次不同"
#define LOGIN_ERROR_PWD_NOT_MATCH @"本次登陆密码错误"
#define LOGIN_ERROR_LAST_GT_CURRENT @"上次登陆日期大于当前日期"
#define LOGIN_ERROR_EXPIRED_OUT_N_HOURS @"距离上次登陆时间超出12小时"

// ERROR
#define ERROR_NO_NETWORK @"无网络环境"

// Btn Label Text
#define BTN_CONFIRM      @"确认"
#define LOGIN_BTN_SUBMIT @"登陆"
#define LOGIN_BTN_SUBMIT_WITHOUT_NETWORK @"离线登陆"

// Label Text
#define LOGIN_LABEL_USER    @"用户名"
#define LOGIN_LABEL_PWD     @"密码"
#define LOGIN_REMEMBER_PWD  @"是否记住密码"

// Alert View Around
#define ALERT_TITLE_LOGIN_FAIL @"登陆失败"
#define ALERT_MSG_LOGIN_SERVER_ERROR @"请确认服务器正常运行"

// 目录中按钮标题
#define SLIDE_BTN_DOWNLOAD     @"下载"
#define SLIDE_BTN_DOWNLOADING  @"下载中..."
#define SLIDE_BTN_DISPLAY      @"演示"
#define SLIDE_BTN_DETAIL       @"详细"

#define BTN_SUBMIT @"提交"
#define BTN_CANCEL @"取消"
#define BTN_EDIT   @"编辑"
#define BTN_SAVE   @"保存"
#define BTN_REMOVE @"移除"
#define BTN_BACK   @"返回"
#define BTN_SURE   @"确定"
#define BTN_RESTORE @"恢复"

// 公告通知
#define NOTIFICATION_I18N_CREATEDDATE @"今天"


#define ALERT_TITLE_CONTENT_FAIL @"加载失败"
#define ALERT_MSG_CONTENT_SERVER_ERROR @"加载服务器目录失败,请确认网络良好，服务运行正常"

#endif
