//
//  HttpResponse.h
//  iSearch
//
//  Created by lijunjie on 15/7/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface HttpResponse : BaseModel

@property (nonatomic, strong) NSData *received;          // 服务器返回原始内容
@property (nonatomic, strong) NSMutableDictionary *data; // response => json
@property (nonatomic, strong) NSMutableArray *errors;    // 服务器交互中出现错误
@property (nonatomic, strong) NSURLResponse *response;   // 响应头部信息

// parse response
@property (nonatomic, strong) NSNumber  *statusCode;
@property (nonatomic, strong) NSString  *mimeType;
@property (nonatomic, strong) NSString  *encodingName;

// instance methods
- (BOOL)isValid;
- (NSString *)receivedString;
@end
