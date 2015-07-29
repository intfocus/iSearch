//
//  ApiHelper.m
//  iSearch
//
//  Created by lijunjie on 15/7/15.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ApiHelper.h"
#import "HttpResponse.h"

@interface ApiHelperTest : XCTestCase

@end

@implementation ApiHelperTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPostActionLog {
    NSDictionary *params =  @{@"UserId":@"UserId001logapi",
                              @"FunctionName":@"FunctionName002logapi",
                              @"ActionName":@"ActionName002logapi",
                              @"ActionTime":@"2015-06-1 18:18:18",
                              @"ActionReturn":@"ActionReturn--092logapi",
                              @"ActionObject":@"ActionObject--003logapi"};
    
    HttpResponse *httpResonse = [ApiHelper actionLog:[NSMutableDictionary dictionaryWithDictionary:params]];
    XCTAssertEqual([httpResonse.statusCode intValue], 200);
    XCTAssertGreaterThanOrEqual((int)httpResonse.data[@"status"], 0);
    XCTAssertEqualObjects(httpResonse.chartset, @"utf-8");
    XCTAssertEqualObjects(httpResonse.contentType, @"application/json");
}
@end
