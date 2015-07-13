//
//  HttpResponse.h
//  iSearch
//
//  Created by lijunjie on 15/7/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpResponse : NSObject

@property (nonatomic, strong) NSData *received;          // 服务器返回原始内容
@property (nonatomic, strong) NSMutableDictionary *data; // response => json
@property (nonatomic, strong) NSMutableArray *errors;    // 服务器交互中出现错误

// instance methods
- (BOOL)isValid;
@end
