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
    NSMutableDictionary *configDict =[FileUtils readConfigFile:configPath];
    
    _configPath = configPath;
    _configDict = configDict;
    
    _ID         = configDict[USER_ID];
    _name       = configDict[USER_NAME];
    _email      = configDict[USER_EMAIL];
    _deptID     = configDict[USER_DEPTID];
    _employeeID = configDict[USER_EMPLOYEEID];

    // local fields
    _loginUserName    = configDict[USER_LOGIN_USERNAME];
    _loginPassword    = configDict[USER_LOGIN_PASSWORD];
    _loginRememberPWD = [configDict[USER_LOGIN_REMEMBER_PWD] isEqualToString:@"1"];
    _loginLast   = configDict[USER_LOGIN_LAST];

    return self;
}

#pragma mark - instance methods

- (void)save {
    // server info
    _configDict[USER_ID]         = self.ID;
    _configDict[USER_NAME]       = self.name;
    _configDict[USER_EMAIL]      = self.email;
    _configDict[USER_DEPTID]     = self.deptID;
    _configDict[USER_EMPLOYEEID] = self.employeeID;
    
    // local info
    _configDict[USER_LOGIN_USERNAME]     = self.loginUserName;
    _configDict[USER_LOGIN_PASSWORD]     = self.loginPassword;
    _configDict[USER_LOGIN_REMEMBER_PWD] = (self.loginRememberPWD ? @"1" : @"0");
    _configDict[USER_LOGIN_LAST]         = self.loginLast;
    
    [FileUtils writeJSON:self.configDict Into:self.configPath];
}

- (NSString *)inspect {
    return [NSString stringWithFormat:@"#<%@ ID: %@, name: %@, email: %@, deptID: %@, employeeID: %@, loginUserName: %@, loginPassword: %@, loginRememberPWD: %d, loginLast: %@>", self.class, self.ID, self.name, self.email, self.deptID, self.employeeID,self.loginUserName,self.loginPassword,self.loginRememberPWD, self.loginLast];
}

- (NSString *)to_s {
    return [self inspect];
}

@end
