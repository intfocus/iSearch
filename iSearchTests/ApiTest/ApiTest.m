//
//  iSearchTests.m
//  iSearchTests
//
//  Created by lijunjie on 15/5/29.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Url.h"
#import "ApiHelper.h"
#import "ExtendNSLogFunctionality.h"

#define PART_RESPONSE @"response"
#define PART_RESULT   @"result"

@interface iSearchTests : XCTestCase

@end

@implementation iSearchTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAPIHeader {
    // This is an example of a functional test case.
    NSString *urlString = @"http://tsa-china.takeda.com.cn/uat/api/Categories_Api.php?lang=zh-CN&did=150&pid=1";
    NSURLResponse *response = [self getResponse:urlString Param:[NSDictionary dictionary]];
    XCTAssertEqual([response.MIMEType lowercaseString], @"application/json", @"服务器响应数据格式不正确");
    XCTAssertEqual([response.textEncodingName lowercaseString], @"utf-8", @"服务器响应数据编码不正确");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - assistant methods
- (NSURLResponse *)getResponse:(NSString *)urlString Param:(NSDictionary *)parameters {
    return (NSURLResponse *)[self get:PART_RESPONSE Url:urlString Param:parameters];
}
- (id)get:(NSString *)partName Url:(NSString *)urlString Param:(NSDictionary *)parameters {
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", urlString);
    NSURL *url            = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:10];
    NSError *error;
    NSURLResponse *response;
    NSData *received      = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSErrorPrint(error, @"Http#get %@", urlString);
    if([partName isEqualToString:PART_RESPONSE]) {
        return response;
    }
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:received options:kNilOptions error:&error];
    NSErrorPrint(error, @"NSData convert to NSDictionary");
    return result;
}
@end
