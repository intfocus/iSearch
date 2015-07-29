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
                  @{@"name": @"name1", @"type": @"typeone", @"date": @"2015/08/19 00:00:00", @"num": @1 },
                  @{@"name": @"name2", @"type": @"typetwo", @"date": @"2015/08/19", @"num": @2 },
                  @{@"name": @"name3", @"type": @"typethree", @"date": @"2015/08/30 11:00:01", @"num": @4 },
                  @{@"name": @"name4", @"type": @"typefour", @"date": @"2015/09/30 22:00:02", @"num": @6 },
                  @{@"name": @"name5", @"type": @"typefive", @"date": @"2015/10/19 33:00:03", @"num": @7 },
                  @{@"name": @"name6", @"type": @"typesix", @"date": @"2015/12/19 44:00:04", @"num": @8 },
                  ];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEqual {
    NSString *predicateStr = [NSString stringWithFormat:@"(%@ == \"%@\")", @"name", @"name1"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateStr];
    NSArray *result = [self.dataList filteredArrayUsingPredicate:filter];
    XCTAssertEqual([result count], 1);
    NSDictionary *dict = [result firstObject];
    XCTAssertEqual(dict[@"date"], @"2015/08/19 00:00:00");
}

// BEGINSWITH：检查某个字符串是否以另一个字符串开头。
// ENDSWITH：检查某个字符串是否以另一个字符串结尾。
// CONTAINS：检查某个字符串是否以另一个字符串内部。
// [c] 不区分大小写 [d] 不区分发音符号即没有重音符号 [cd] 既不区分大小写，又不区分发音符号。
- (void)testBEGINSWITH {
    NSString *predicateStr = [NSString stringWithFormat:@"(%@ BEGINSWITH \"%@\")", @"date", @"2015/08/19"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:predicateStr];
    NSArray *result = [self.dataList filteredArrayUsingPredicate:filter];
    XCTAssertEqual([result count], 2);
    NSDictionary *dict = [result firstObject];
    XCTAssertEqual(dict[@"name"], @"name1");
    XCTAssertEqual(dict[@"date"], @"2015/08/19 00:00:00");
}

- (void)testBETWEEN {
    NSPredicate *filter = [NSPredicate predicateWithFormat: @"num BETWEEN %@", @[@3, @5]];
    NSArray *result = [self.dataList filteredArrayUsingPredicate:filter];
    XCTAssertEqual([result count], 1);
    XCTAssertEqual([result firstObject][@"name"], @"name3");
}

- (void)testLIKE {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"type LIKE[cd] '*eon*'"];//* 代表通配符 Like 还接受 [cd].
    NSArray *result = [self.dataList filteredArrayUsingPredicate: filter];
    XCTAssertEqual([result count], 1);
    XCTAssertEqual([result firstObject][@"name"], @"name1");
    
    filter = [NSPredicate predicateWithFormat:@"type LIKE[cd] '????six'"];//? 只匹配一个字符并且还可以接受 [cd].
    result = [self.dataList filteredArrayUsingPredicate: filter];
    XCTAssertEqual([result count], 1);
    XCTAssertEqual([result firstObject][@"name"], @"name6");
}

- (void)testIN {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name IN %@", @[@"name1", @"name2"]];
    NSArray *result = [self.dataList filteredArrayUsingPredicate: filter];
    XCTAssertEqual([result count], 2);
    XCTAssertEqualObjects(result, [self.dataList subarrayWithRange:NSMakeRange(0, 2)]);
}

- (void)testCompare {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"num == %@", @4];
    NSArray *result = [self.dataList filteredArrayUsingPredicate: filter];
    XCTAssertEqualObjects(result[0], self.dataList[2]);
    
    
    filter = [NSPredicate predicateWithFormat:@"num > %@", @7];
    result = [self.dataList filteredArrayUsingPredicate: filter];
    XCTAssertEqualObjects(result[0], [self.dataList lastObject]);
    
    
    filter = [NSPredicate predicateWithFormat:@"num < %@", @2];
    result = [self.dataList filteredArrayUsingPredicate: filter];
    XCTAssertEqualObjects(result[0], [self.dataList firstObject]);
}
@end
