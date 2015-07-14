//
//  Api.m
//  iSearch
//
//  Created by lijunjie on 15/7/14.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Url+Param.h"

@interface UrlTest : XCTestCase

@end

@implementation UrlTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUrlNotNil {
    NSArray *methods = @[@"base", @"login", @"slides", @"categories", @"slideDownload", @"notifications", @"actionLog", @"slideList"];
    Url *url = [[Url alloc] init];
    NSString *urlString;
    for(NSString *method in methods) {
        urlString = [url performSelector:NSSelectorFromString(method)];
        XCTAssertNotNil(urlString);
        XCTAssertTrue([urlString containsString:BASE_URL]);
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
