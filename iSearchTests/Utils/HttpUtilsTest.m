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
#import "HttpResponse.h"

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

- (void)testHttpGets {
    HttpResponse *result;
    result = [HttpUtils httpGet:@"http://www.baidu.com"];
    XCTAssertTrue([result.statusCode isEqual:@200]);
    result = [HttpUtils httpGet:@"http://www.baidu1234567890.com"];
    XCTAssertNil(result.statusCode);
}

- (void)testNetworkAvailable {
    NSDate *now = [NSDate date];
    BOOL isNetworkAvailable = [HttpUtils isNetworkAvailable:@"http://google.com"];
    NSTimeInterval interval = 0 - [now timeIntervalSinceNow];
    
    XCTAssertTrue(interval < 0.6);
    XCTAssertFalse(isNetworkAvailable);
    
    
    now = [NSDate date];
    isNetworkAvailable = [HttpUtils isNetworkAvailable2];
    interval = 0 - [now timeIntervalSinceNow];
    
    XCTAssertTrue(interval < 0.6);
    XCTAssertTrue(isNetworkAvailable);
    
}

@end
