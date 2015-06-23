//
//  User.m
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

#import "const.h"
#import "FileUtils.h"
#import "DateUtils.h"

@implementation User

- (User *)init {
    self = [super init];
    
    NSString *configPath = [FileUtils getPathName:CONFIG_DIRNAME FileName:LOGIN_CONFIG_FILENAME];
    NSMutableDictionary *userDict =[FileUtils readConfigFile:configPath];
    self.ID         = userDict[USER_ID];
    self.name       = userDict[USER_NAME];
    self.email      = userDict[USER_EMAIL];
    self.deptID     = userDict[USER_DEPTID];
    self.employeeID = userDict[USER_EMPLOYEEID];

    // local fields
    self.localUserName    = userDict[USER_LOGIN_USERNAME];
    self.localPassword    = userDict[USER_LOGIN_PASSWORD];
    self.localRememberPWD = [userDict[USER_LOGIN_REMEMBER_PWD] isEqualToString:@"1"];
    self.localLastLogin   = userDict[USER_LOGIN_LAST];

    return self;
}

@end
