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
@property (nonatomic, strong) Url *url;

@end

@implementation UrlTest

- (void)setUp {
    [super setUp];
    
    self.url = [[Url alloc] init];
}

- (void)tearDown {
    self.url = nil;
    
    [super tearDown];
}

- (void)testEveryUrlNotNil {
    NSArray *methods = @[@"base", @"login", @"slides", @"categories", @"slideDownload", @"notifications", @"actionLog", @"slideList"];
    NSString *urlString;
    for(NSString *method in methods) {
        SuppressPerformSelectorLeakWarning(
            urlString = [self.url performSelector:NSSelectorFromString(method)];
        );

        XCTAssertNotNil(urlString);
        XCTAssertTrue([urlString containsString:BASE_URL]);
    }
}
@end
