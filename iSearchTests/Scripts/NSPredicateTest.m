//
//  NSPredicateTest.m
//  iSearch
//
//  Created by lijunjie on 15/7/29.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface NSPredicateTest : XCTestCase
@property (nonatomic, strong) NSArray *dataList;

@end

@implementation NSPredicateTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _dataList = @[
                  @{@"name": @"name1", @"type": @"notification", @"date": @"2015/08/19 00:00:00", @"num": @1 },
                  @{@"name": @"name2", @"type": @"notification", @"date": @"2015/08/19", @"num": @2 },
                  @{@"name": @"name3", @"type": @"notification", @"date": @"2015/08/30 00:00:00", @"num": @4 },
                  @{@"name": @"name4", @"type": @"notification", @"date": @"2015/08/30 00:00:00", @"num": @6 },
                  @{@"name": @"name5", @"type": @"notification", @"date": @"2015/08/19 00:00:00", @"num": @7 },
                  @{@"name": @"name6", @"type": @"notification", @"date": @"2015/08/19 00:00:00", @"num": @8 },
                  ];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEqual {
    NSString *predicateStr = [NSString stringWithFormat:@"(%@ == \"%@\")", @"name", @"name6"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateStr];
    NSArray *result = [self.dataList filteredArrayUsingPredicate:filter];
    XCTAssertEqual([result count], 1);
    NSDictionary *dict = [result firstObject];
    XCTAssertEqual(dict[@"date"], @"2015/08/19 00:00:00");
}

- (void)testBEGINSWITH {
    NSString *predicateStr = [NSString stringWithFormat:@"(%@ BEGINSWITH \"%@\")", @"date", @"2015/08/19"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateStr];
    NSArray *result = [self.dataList filteredArrayUsingPredicate:filter];
    XCTAssertEqual([result count], 4);
    NSDictionary *dict = [result firstObject];
    XCTAssertEqual(dict[@"name"], @"name1");
    XCTAssertEqual(dict[@"date"], @"2015/08/19 00:00:00");
}


@end
