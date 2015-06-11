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
#define LOGIN_ERROR_USER_EMPTY @"用户名不可以空"
#define LOGIN_ERROR_PWD_EMPTY  @"登陆密码不可以空"
#define LOGIN_ERROR_LAST_TIMEOUT   @"距离上次在线登陆时过久，请重新登陆。\n上次登陆:"
#define LOGIN_ERROR_USER_NOT_MATCH @"本次登陆用户与上次不同"

// ERROR
#define ERROR_NO_NETWORK       @"无网络环境"

// Btn Label Text
#define BTN_CONFIRM @"确认"
#define LOGIN_BTN_SUBMIT @"登陆"
#define LOGIN_BTN_SUBMIT_WITHOUT_NETWORK @"离线登陆"

// Label Text
#define LOGIN_LABEL_USER @"用户名"
#define LOGIN_LABEL_PWD  @"密码"
#define LOGIN_REMEMBER_PWD  @"是否记住密码"

// Alert View Around
#define ALERT_TITLE_LOGIN_FAIL @"登陆失败"
#define ALERT_MSG_LOGIN_SERVER_ERROR @"请确认服务器正常运行"

#endif
