//
//  User.h
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_User_h
#define iSearch_User_h
#import "BaseModel.h"

@interface User: BaseModel

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *employeeID;
@property (nonatomic, strong) NSString *deptID;
@property (nonatomic, strong) NSString *result;

// local fields
@property (nonatomic, strong) NSString *loginUserName;
@property (nonatomic, strong) NSString *loginPassword;
@property (nonatomic, strong) NSString *loginLast;
@property (nonatomic, nonatomic) BOOL loginRememberPWD;

// attribute fields
@property (nonatomic, strong) NSString *configPath;
@property (nonatomic, strong) NSMutableDictionary *configDict;
@property (nonatomic, strong) NSString *personalPath;

// instance methods
- (void)save;
- (void)writeInToPersonal;

// class methods
/**
 *  快捷获取用户ID
 *
 *  @return 用户ID
 */
+ (NSString *)userID;
/**
 *  快捷获取部门ID
 *
 *  @return 部门ID
 */
+ (NSString *)deptID;
@end
#endif
