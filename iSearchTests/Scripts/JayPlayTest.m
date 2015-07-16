//
//  JayPlayTest.m
//  iSearch
//
//  Created by lijunjie on 15/7/16.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface JayPlayTest : XCTestCase

@end

@implementation JayPlayTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - args
//1.参数类型是NSString类型,后面params是第一个参数,它后面跟着逗号和三个点(固定格式)
-(void)dynaArgs:(NSString*)params,...
{
    NSString* curStr;
    va_list list;
    if(params)
    {
        //1.取得第一个参数的值
        NSLog(@"%@", params);
        //2.从第2个参数开始，依此取得所有参数的值
        va_start(list, params);
        while ((curStr = va_arg(list, NSString*))){
            NSLog(@"%@", curStr);
        }
        va_end(list);
    }
}

- (void)testDynaArgs {
    //2.测试改函数
    [self  dynaArgs:@"1",@"2",@"3",nil];
    //3.注意,一定要写nil,不然改函数无法跳出while循环.
}

@end
