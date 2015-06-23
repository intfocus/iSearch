//
//  User.h
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_User_h
#define iSearch_User_h
#import <UIKit/UIKit.h>

@interface User: NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *employeeID;
@property (nonatomic, strong) NSString *deptID;
@property (nonatomic, strong) NSString *result;

// local fields
@property (nonatomic, strong) NSString *localUserName;
@property (nonatomic, strong) NSString *localPassword;
@property (nonatomic, nonatomic) BOOL localRememberPWD;
@property (nonatomic, strong) NSString *localLastLogin;
@end
#endif
