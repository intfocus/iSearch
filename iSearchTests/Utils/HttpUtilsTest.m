//
//  HttpUtilsTest.m
//  iSearch
//
//  Created by lijunjie on 15/7/24.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HttpUtils.h"

@interface HttpUtilsTest : XCTestCase

@end

@implementation HttpUtilsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSDictionary *result;
    result = [HttpUtils httpGet2:@"www.baidu.com"];
    XCTAssertNil(result[@"error"]);
    result = [HttpUtils httpGet2:@"www.baidu2.com"];
    XCTAssertNil(result[@"error"]);
}

@end
