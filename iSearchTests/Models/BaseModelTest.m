//
//  BaseModelTest.m
//  iSearch
//
//  Created by lijunjie on 15/7/16.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BaseModel.h"

@interface TestModel:BaseModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, retain) NSString *age;
@end
@implementation TestModel
@end


@interface BaseModelTest : XCTestCase
@property (nonatomic, strong) TestModel *testModel;
@end

@implementation BaseModelTest

- (void)setUp {
    [super setUp];
    
    self.testModel      = [[TestModel alloc] init];
    self.testModel.name = @"test";
    self.testModel.age  = @"16";
}

- (void)tearDown {
    self.testModel = nil;
    
    [super tearDown];
}

- (void)testToS {
    XCTAssertEqualObjects([self.testModel to_s], @"#<TestModel name: test,age: 16>");
    XCTAssertEqualObjects([self.testModel to_s:NO], @"#<TestModel name: test,age: 16>");
    XCTAssertEqualObjects([self.testModel to_s:YES], @"#<TestModel name: test,\nage: 16>");
}

- (void)testInspect {
    XCTAssertEqualObjects([self.testModel inspect], @"#<TestModel name: test,age: 16>");
}

- (void)testDescription {
    XCTAssertEqualObjects([self.testModel description], @"name = test\nage = 16\n");
}
@end
